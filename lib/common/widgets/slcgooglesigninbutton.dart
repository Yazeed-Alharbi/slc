import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/firebaseUtil/auth_services.dart';

class SLCGoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SLCButton(
      onPressed: () => AuthenticationService().googleSignIn(context),
      text: "Continue with Google",
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      foregroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      icon: Image.asset("assets/GoogleLogo.png", width: 25, height: 25),
    );
  }
}
