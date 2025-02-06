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
      String message = "";
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account with this email exists';
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
        message: "An unexpected error occurred.",
        type: FlushbarType.error,
      );
      return false;
    }
  }

  Future<void> signin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Entered credentials are incorrect!';
      }
      SLCFlushbar.show(
        context: context,
        message: message,
        type: FlushbarType.error,
      );
    } catch (e) {
      SLCFlushbar.show(
        context: context,
        message: "An unexpected error occurred.",
        type: FlushbarType.error,
      );
    }
  }
}
