import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      SLCFlushbar.show(
        context: context,
        message: "Password reset instructions have been sent to $email.",
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
    String message = "An unexpected authentication error occurred.";
    switch (errorCode) {
      case 'invalid-email':
        message = 'Invalid email format.';
        break;
      case 'email-already-in-use':
        message = 'An account with this email already exists.';
        break;
      case 'weak-password':
        message = 'The password is too weak.';
        break;
      case 'user-not-found':
      case 'wrong-password':
        message = 'Invalid credentials. Please try again.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Check your connection.';
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
}
