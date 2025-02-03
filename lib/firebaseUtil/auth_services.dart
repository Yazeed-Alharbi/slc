import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AuthenticationService {
  Future<void> signup({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = 'the password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account with this email exists';
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR);
    } catch (e) {}
  }

  Future<void> signin({required String email, required String password}) async{
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Entered credentials are incorrect!';
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR);
    } catch (e) {}
  }
}
