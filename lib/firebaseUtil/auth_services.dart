import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcflushbar.dart';

class AuthenticationService {
  Future<bool> signup({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      String message = "An unexpected authentication error occurred."; // Default error message

      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'email-already-in-use':
          message = 'An account with this email already exists.';
          break;
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password sign-in is disabled for this project.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = e.message ?? message; // Use Firebase's message if available
      }

      SLCFlushbar.show(
        context: context,
        message: message,
        type: FlushbarType.error,
      );

      return false;
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "An unexpected error occurred. Please try again.",
        type: FlushbarType.error,
      );
      return false;
    }
  }

  Future<bool> signin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      String message = "An unexpected authentication error occurred."; // Default error message

      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid credentials. Please try again.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled by an administrator.';
          break;
        case 'user-not-found':
        case 'wrong-password':
          message = 'Invalid credentials. Please try again.';
          break;
        case 'too-many-requests':
          message = 'Too many unsuccessful login attempts. Try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = e.message ?? message; // Use Firebase's message if available
      }

      SLCFlushbar.show(
        context: context,
        message: message,
        type: FlushbarType.error,
      );

      return false;
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "An unexpected error occurred. Please try again.",
        type: FlushbarType.error,
      );
      return false;
    }
  }
}
