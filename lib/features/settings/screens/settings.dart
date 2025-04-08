import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:slc/services/notifications_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Setting values
  bool _notificationsEnabled = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode', _darkMode);

    SLCFlushbar.show(
      context: context,
      message: "Settings saved successfully",
      type: FlushbarType.success,
    );
  }

  Future<void> _handleNotificationToggle(bool value) async {
    if (value) {
      final permissionGranted =
          await NotificationsService().requestNotificationPermissions();
      if (!permissionGranted) {
        if (mounted) {
          SLCFlushbar.show(
            context: context,
            message:
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
    final shouldLogout = await NativeAlertDialog.show(
      context: context,
      title: "Log Out",
      content: "Are you sure you want to log out?",
      confirmText: "Log Out",
      cancelText: "Cancel",
      confirmTextColor: Colors.red,
    );

    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/loginscreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final padding = SpacingStyles(context).defaultPadding;

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
                "Settings",
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
                              user.displayName ?? "User",
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
                "App Settings",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                subtitle: "Receive push notifications",
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
                title: "Dark Mode",
                subtitle: "Use dark theme",
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    _saveSettings();
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
                "About",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: "Help & Support",
                onTap: () {
                  // Navigate to help screen
                },
              ),
              SizedBox(height: 8),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: "About SLC",
                subtitle: "Version 1.0.0",
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
                  text: "Log Out",
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
