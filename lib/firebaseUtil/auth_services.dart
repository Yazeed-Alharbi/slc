import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Student.dart';
import 'package:slc/repositories/student_repository.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final StudentRepository _studentRepository;
  AuthenticationService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    StudentRepository? studentRepository,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _studentRepository = studentRepository ??
            StudentRepository(
              firestoreUtils: FirestoreUtils(),
            );

  // Update the signup method - remove the signOut call
  Future<bool> signup({
    required BuildContext context,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create authentication account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create student profile using repository
      await _studentRepository.createStudent(
        email: email,
        name: fullName,
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      return true;
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
      return false;
    }
  }

  // Add this method to check verification status
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  // Add this method to resend verification email
  Future<void> resendVerificationEmail(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      await user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
    }
  }

  Future<bool> signin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
      return false;
    }
  }

  Future<Student?> googleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Use repository to get or create student
      return await _studentRepository.getOrCreateStudent();
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
      return null;
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Google sign-in failed. Please try again.",
        type: FlushbarType.error,
      );
      return null;
    }
  }

  Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      // Get localized message
      final l10n = AppLocalizations.of(context);
      final message = l10n != null
          ? l10n.passwordResetSent(email)
          : "Password reset instructions have been sent to $email.";

      SLCFlushbar.show(
        context: context,
        message: message,
        type: FlushbarType.success,
      );
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
    }
  }

  // Get the current user (or null if not authenticated)
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  void _showAuthError(BuildContext context, String errorCode) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);

    // Default message with fallback
    String message = l10n?.unexpectedAuthError ??
        "An unexpected authentication error occurred.";

    switch (errorCode) {
      case 'invalid-email':
        message = l10n?.invalidEmailFormat ?? 'Invalid email format.';
        break;
      case 'email-already-in-use':
        message = l10n?.emailAlreadyInUse ??
            'An account with this email already exists.';
        break;
      case 'weak-password':
        message = l10n?.weakPassword ?? 'The password is too weak.';
        break;
      case 'user-not-found':
      case 'wrong-password':
        message = l10n?.invalidCredentials ??
            'Invalid credentials. Please try again.';
        break;
      case 'too-many-requests':
        message =
            l10n?.tooManyAttempts ?? 'Too many attempts. Try again later.';
        break;
      case 'network-request-failed':
        message = l10n?.networkError ?? 'Network error. Check your connection.';
        break;
    }

    SLCFlushbar.show(
      context: context,
      message: message,
      type: FlushbarType.error,
    );
  }

  void _logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/loginscreen');
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Get localized strings
      final l10n = AppLocalizations.of(context);
      final errorMessage = l10n?.unexpectedAuthError ??
          "An unexpected authentication error occurred.";

      SLCFlushbar.show(
        context: context,
        message: errorMessage,
        type: FlushbarType.error,
      );
    }
  }

  // Add this method to force a reload of the current user
  Future<void> reloadCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      await user?.reload();
    } catch (e) {
      // Handle error silently - just checking status
    }
  }
}
