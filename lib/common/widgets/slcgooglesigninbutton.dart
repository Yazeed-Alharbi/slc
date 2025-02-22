import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/models/Student.dart';

class SLCGoogleSignInButton extends StatelessWidget {
  final Function(bool) setLoading;
  final Function(Student?) onGoogleSignInSuccess; 

  const SLCGoogleSignInButton({
    Key? key,
    required this.setLoading,
    required this.onGoogleSignInSuccess, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SLCButton(
      onPressed: () async {
        setLoading(true);
        Student? student = await AuthenticationService().googleSignIn(context);
        setLoading(false);
        
        onGoogleSignInSuccess(student);
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
