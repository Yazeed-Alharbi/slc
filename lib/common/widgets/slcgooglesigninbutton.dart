import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/firebaseUtil/auth_services.dart';

class SLCGoogleSignInButton extends StatelessWidget {
  final Function(bool) setLoading;
  final Function(bool) onGoogleSignInSuccess; // Callback to notify LoginScreen

  const SLCGoogleSignInButton({
    Key? key,
    required this.setLoading,
    required this.onGoogleSignInSuccess, // Accepts success callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SLCButton(
      onPressed: () async {
        setLoading(true);
        bool success = await AuthenticationService().googleSignIn(context);
        setLoading(false);
        
        onGoogleSignInSuccess(success); // Notify LoginScreen about success
      },
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
