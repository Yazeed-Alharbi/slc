import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:slc/common/widgets/slcflushbar.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> signup({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
      return false;
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

  Future<bool> googleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      _showAuthError(context, e.code);
      return false;
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "Google sign-in failed. Please try again.",
        type: FlushbarType.error,
      );
      return false;
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
}
