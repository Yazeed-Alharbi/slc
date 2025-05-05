import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:slc/common/providers/language_provider.dart';
import 'package:slc/common/providers/theme_provider.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/services/notifications_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/features/settings/screens/profile_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slc/models/student.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Setting values
  bool _notificationsEnabled = false;
  // No longer need _darkMode as a local variable

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserData();
  }

  Future<void> _loadSettings() async {
    final notificationService = NotificationsService();

    setState(() {
      _notificationsEnabled = notificationService.isEnabled;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final l10n = AppLocalizations.of(context);

    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    // No need to save dark mode here

    SLCFlushbar.show(
      context: context,
      message: l10n?.settingsSaved ?? "Settings saved successfully",
      type: FlushbarType.success,
    );
  }

  Future<void> _handleNotificationToggle(bool value) async {
    final l10n = AppLocalizations.of(context);
    final notificationService = NotificationsService();

    if (value) {
      final permissionGranted =
          await notificationService.requestNotificationPermissions();
      if (!permissionGranted) {
        if (mounted) {
          SLCFlushbar.show(
            context: context,
            message: l10n?.notificationPermissionsRequired ??
                "Notification permissions required to enable notifications",
            type: FlushbarType.warning,
          );
        }
        return;
      }
    }

    // Update the notification service
    await notificationService.setNotificationsEnabled(value);

    // Update the UI
    setState(() {
      _notificationsEnabled = value;
    });

    // Show success message
    SLCFlushbar.show(
      context: context,
      message: l10n?.settingsSaved ?? "Settings saved successfully",
      type: FlushbarType.success,
    );
  }

  Future<void> _logoutUser() async {
    final l10n = AppLocalizations.of(context);

    final shouldLogout = await NativeAlertDialog.show(
      context: context,
      title: l10n?.logOut ?? "Log Out",
      content: l10n?.logOutConfirmation ?? "Are you sure you want to log out?",
      confirmText: l10n?.logOut ?? "Log Out",
      cancelText: l10n?.cancel ?? "Cancel",
      confirmTextColor: Colors.red,
    );

    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/loginscreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final padding = SpacingStyles(context).defaultPadding;

    // Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
              SizedBox(height: 7),
              Text(
                l10n?.settings ?? "Settings",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 25),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 20),

              // User profile section
              if (user != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('students')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildUserProfileSection(
                          null); // Show loading state
                    }

                    // Create student object from Firestore data
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final student = Student.fromJson(data);

                    // Build UI with latest data
                    return _buildUserProfileSection(student);
                  },
                ),

              // App Settings
              Text(
                l10n?.appSettings ?? "App Settings",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: l10n?.notifications ?? "Notifications",
                subtitle:
                    l10n?.receiveNotifications ?? "Receive push notifications",
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _handleNotificationToggle,
                  activeColor: SLCColors.primaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color.fromARGB(60, 140, 140, 140),
                  trackOutlineColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
              ),
              SizedBox(height: 8),
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: l10n?.darkMode ?? "Dark Mode",
                subtitle: l10n?.useDarkTheme ?? "Use dark theme",
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    // Use the provider to change theme
                    themeProvider.toggleTheme(value);
                    // No need for setState as the provider notifies listeners
                  },
                  activeColor: SLCColors.primaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color.fromARGB(60, 140, 140, 140),
                  trackOutlineColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
              ),

              SizedBox(height: 24),

              // Language section
              Text(
                l10n?.language ?? "Language",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.language,
                title: l10n?.selectLanguage ?? "Select Language",
                subtitle: _getLanguageName(context),
                onTap: _showLanguageSelector,
              ),

              SizedBox(height: 24),

              // About section
              Text(
                l10n?.about ?? "About",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: l10n?.helpAndSupport ?? "Help & Support",
                onTap: () {
                  // Navigate to help screen
                },
              ),
              SizedBox(height: 8),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: l10n?.aboutSLC ?? "About SLC",
                subtitle: l10n?.version ?? "Version 1.0.1",
                onTap: () {
                  // Navigate to about screen
                },
              ),

              SizedBox(height: 32),

              // Logout button
              SLCButton(
                  onPressed: _logoutUser,
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  text: l10n?.logOut ?? "Log Out",
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SLCColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: SLCColors.primaryColor),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  String _getLanguageName(BuildContext context) {
    final String currentLanguage = Localizations.localeOf(context).languageCode;
    switch (currentLanguage) {
      case 'ar':
        return 'العربية 🇸🇦';
      case 'en':
      default:
        return 'English 🇺🇸';
    }
  }

  void _showLanguageSelector() {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Row(
                  children: [
                    Text("English"),
                    SizedBox(
                      width: 5,
                    ),
                    Text("🇺🇸")
                  ],
                ),
                trailing: Localizations.localeOf(context).languageCode == 'en'
                    ? Icon(Icons.check, color: SLCColors.primaryColor)
                    : null,
                onTap: () {
                  languageProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Text("العربية"),
                    SizedBox(
                      width: 5,
                    ),
                    Text("🇸🇦")
                  ],
                ),
                trailing: Localizations.localeOf(context).languageCode == 'ar'
                    ? Icon(Icons.check, color: SLCColors.primaryColor)
                    : null,
                onTap: () {
                  languageProvider.setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Add this method to manually refresh user data
  void _loadUserData() {
    setState(() {
      // This forces a refresh of the user data
    });
  }

  // Add this method to refresh user data
  Future<void> _refreshUserData() async {
    if (mounted) {
      setState(() {
        // Force refresh UI
      });
    }
  }

  Widget _buildUserProfileSection(Student? student) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = student?.name ?? user?.displayName ?? 'User';
    final email = student?.email ?? user?.email ?? '';
    final photoUrl = student?.photoUrl ?? user?.photoURL;

    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SLCAvatar(
            imageUrl: photoUrl,
            size: 60,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: SLCColors.primaryColor),
            onPressed: () async {
              // Navigate to profile edit and wait for result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );

              // If successfully edited, refresh the UI
              if (result == true) {
                await _refreshUserData();
              }
            },
          ),
        ],
      ),
    );
  }
}
