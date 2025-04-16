import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/common/widgets/slcavatar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/repositories/student_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // First try to get name from Firebase Auth
      String name = user.displayName ?? '';

      // If empty, try to get it from Firestore
      if (name.isEmpty) {
        try {
          final studentRepository = StudentRepository(
            firestoreUtils: FirestoreUtils(),
          );

          final student = await studentRepository.getStudent(user.uid);
          if (student != null && student.name.isNotEmpty) {
            name = student.name;
          }
        } catch (e) {
          print('Error loading student data: $e');
        }
      }

      // Set the name from either source
      setState(() {
        _nameController.text = name;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<File?> compressImage(File file,
      {int maxSizeInBytes = 1024 * 1024}) async {
    // Get file size
    final fileSize = await file.length();

    // If already smaller than max size, return original
    if (fileSize <= maxSizeInBytes) {
      return file;
    }

    // Calculate required quality (lower quality = smaller file)
    // Start with 85% quality and adjust based on file size
    int quality = 85;
    if (fileSize > maxSizeInBytes * 4) {
      quality = 60; // Very large image, use lower quality
    } else if (fileSize > maxSizeInBytes * 2) {
      quality = 70; // Large image
    }

    // Get temp directory
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Compress file
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1000, // Reasonable size for profile pics
      minHeight: 1000,
      // Use JPEG format for better compression
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      return file; // Fallback to original if compression fails
    }

    // Check if we need another round of compression
    final compressedSize = await result.length();
    if (compressedSize > maxSizeInBytes) {
      // Delete the first compressed file
      await File(targetPath).delete();

      // Try again with lower quality
      final secondTargetPath =
          p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}_2.jpg');
      final secondResult = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        secondTargetPath,
        quality: quality ~/ 1.5, // Further reduce quality
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );

      return secondResult != null ? File(secondResult.path) : file;
    }

    return File(result.path);
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      SLCFlushbar.show(
        context: context,
        message: l10n?.nameRequired ?? "Name is required",
        type: FlushbarType.error,
      );
      return;
    }

    // Validate password if changing
    if (_changePassword) {
      if (_currentPasswordController.text.isEmpty) {
        SLCFlushbar.show(
          context: context,
          message:
              l10n?.currentPasswordRequired ?? "Current password is required",
          type: FlushbarType.error,
        );
        return;
      }

      if (_newPasswordController.text.isEmpty) {
        SLCFlushbar.show(
          context: context,
          message: l10n?.newPasswordRequired ?? "New password is required",
          type: FlushbarType.error,
        );
        return;
      }

      if (_newPasswordController.text.length < 6) {
        SLCFlushbar.show(
          context: context,
          message: l10n?.passwordTooShort ??
              "Password must be at least 6 characters long",
          type: FlushbarType.error,
        );
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        SLCFlushbar.show(
          context: context,
          message: l10n?.passwordsDontMatch ?? "Passwords don't match",
          type: FlushbarType.error,
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update display name if changed
      if (_nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(_nameController.text.trim());

        // Add this code to update Firestore:
        final studentRepository = StudentRepository(
          firestoreUtils: FirestoreUtils(),
        );

        await studentRepository.updateStudent(
          user.uid,
          {'name': _nameController.text.trim()},
        );
      }

      // Upload and update profile picture if selected
      if (_selectedImage != null) {
        try {
          // Compress the image
          final compressedImage = await compressImage(_selectedImage!);

          // Always use the same filename
          final fileName = 'profile.jpg';

          // Create a user-specific path
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(user.uid) // Add user folder level
              .child(fileName);

          // This will automatically overwrite any existing file with the same name
          final uploadTask = storageRef.putFile(compressedImage!);

          // Wait for upload to complete
          final snapshot = await uploadTask;

          // Get the URL with error handling
          final imageUrl = await snapshot.ref.getDownloadURL();
          print('Successfully got download URL: $imageUrl');

          // Update both Auth and Firestore with new URL
          await user.updatePhotoURL(imageUrl);

          final studentRepository = StudentRepository(
            firestoreUtils: FirestoreUtils(),
          );

          await studentRepository.updateStudent(
            user.uid,
            {'photoUrl': imageUrl},
          );
        } catch (e) {
          print('DETAILED ERROR UPLOADING IMAGE: $e');
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            SLCFlushbar.show(
              context: context,
              message: l10n?.errorUpdatingPicture ??
                  "Error updating profile picture",
              type: FlushbarType.error,
            );
          }
          return;
        }
      }

      // Update password if requested
      if (_changePassword) {
        // Re-authenticate user before changing password
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
      }

      if (mounted) {
        // Force refresh of Firebase user to get updated data
        await user.reload();

        // FIRST end the loading state
        setState(() {
          _isLoading = false;
        });

        // THEN show the success message
        SLCFlushbar.show(
          context: context,
          message: l10n?.profileUpdated ?? "Profile updated successfully",
          type: FlushbarType.success,
        );

        // After showing the message, navigate back
        Future.delayed(Duration(milliseconds: 1500), () {
          Navigator.pop(context, true);
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage =
          l10n?.errorUpdatingProfile ?? "Error updating profile";

      if (error is FirebaseAuthException) {
        if (error.code == 'wrong-password') {
          errorMessage = l10n?.wrongPassword ?? "Current password is incorrect";
        } else if (error.code == 'weak-password') {
          errorMessage = l10n?.weakPassword ?? "Password is too weak";
        }
      }

      if (mounted) {
        SLCFlushbar.show(
          context: context,
          message: errorMessage,
          type: FlushbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      // Add this gesture detector to unfocus when tapping outside
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: SLCLoadingIndicator(
                text: "Saving changes...",
              ))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button and title
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                          SizedBox(width: 8),
                          Text(
                            l10n?.editProfile ?? "Edit Profile",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 25),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Profile picture
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              _selectedImage != null
                                  ? SLCAvatar(
                                      size: 100,
                                      imageFile: FileImage(_selectedImage!),
                                    )
                                  : SLCAvatar(
                                      imageUrl: user?.photoURL,
                                      size: 100,
                                    ),
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: SLCColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 32),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email (non-editable)
                            Text(
                              l10n?.email ?? "Email",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildSettingTile(
                              icon: Icons.email_outlined,
                              title: user?.email ?? "",
                              enabled: false,
                            ),
                            SizedBox(height: 20),

                            // Full Name
                            Text(
                              l10n?.fullName ?? "Full Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildEditableTile(
                              controller: _nameController,
                              icon: Icons.person_outline,
                            ),

                            SizedBox(height: 32),

                            // Password change section
                            _buildSettingTile(
                              icon: Icons.lock_outline,
                              title: l10n?.changePassword ?? "Change Password",
                              trailing: Switch(
                                value: _changePassword,
                                onChanged: (value) {
                                  setState(() {
                                    _changePassword = value;
                                  });
                                },
                                activeColor: SLCColors.primaryColor,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor:
                                    const Color.fromARGB(60, 140, 140, 140),
                                trackOutlineColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                            ),

                            if (_changePassword) ...[
                              SizedBox(height: 16),

                              // Current password
                              Text(
                                l10n?.currentPassword ?? "Current Password",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildEditableTile(
                                controller: _currentPasswordController,
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),

                              SizedBox(height: 20),

                              // New password
                              Text(
                                l10n?.newPassword ?? "New Password",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildEditableTile(
                                controller: _newPasswordController,
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),

                              SizedBox(height: 20),

                              // Confirm password
                              Text(
                                l10n?.confirmPassword ?? "Confirm Password",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildEditableTile(
                                controller: _confirmPasswordController,
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                            ],

                            SizedBox(height: 40),

                            // Save button
                            SLCButton(
                              onPressed: _saveProfile,
                              text: l10n?.saveChanges ?? "Save Changes",
                              icon: Icon(Icons.save, color: Colors.white),
                              backgroundColor: SLCColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
            color: enabled
                ? SLCColors.primaryColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? SLCColors.primaryColor : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? null : Colors.grey,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        enabled: enabled,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildEditableTile({
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      padding: EdgeInsets.all(
          8), // Changed from padding to margin to match _buildSettingTile
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        // Remove validator
        style: TextStyle(
          fontSize: 16,
        ),
        minLines: 1,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: InputBorder.none,
          prefixIcon: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(left: 8, right: 12),
            decoration: BoxDecoration(
              color: SLCColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: SLCColors.primaryColor),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    );
  }
}
