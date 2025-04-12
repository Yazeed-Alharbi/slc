import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:slc/common/providers/theme_provider.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/services/notifications_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      // No need to load dark mode here
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

    if (value) {
      final permissionGranted =
          await NotificationsService().requestNotificationPermissions();
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

    setState(() {
      _notificationsEnabled = value;
    });
    _saveSettings();
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
                Container(
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
                        imageUrl: user.photoURL,
                        size: 60,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? (l10n?.user ?? "User"),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            SizedBox(height: 4),
                            Text(
                              user.email ?? "",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            color: SLCColors.primaryColor),
                        onPressed: () {
                          // Navigate to profile edit
                        },
                      ),
                    ],
                  ),
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
                subtitle: l10n?.version ?? "Version 1.0.0",
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
}
