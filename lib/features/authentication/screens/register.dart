import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: SingleChildScrollView(
      child: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/RegisterIllustration.png",
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Create Account",
              style: TextStyle(
                  color: SLCColors.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            SLCTextField(
              labelText: "Name",
              obscureText: false,
              controller: nameController,
            ),
            const SizedBox(
              height: 15,
            ),
            SLCTextField(
              labelText: "Email",
              obscureText: false,
              controller: emailController,
            ),
            const SizedBox(
              height: 15,
            ),
            SLCTextField(
              labelText: "Password",
              obscureText: true,
              controller: passwordController,
            ),
            SizedBox(
              height: 15,
            ),
            SLCTextField(
              labelText: "Confirm Password",
              obscureText: true,
              controller: confirmPasswordController,
            ),
            SizedBox(
              height: 30,
            ),
            SLCButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/verifyemailscreen");
                },
                text: "Sign Up",
                backgroundColor: SLCColors.primaryColor,
                foregroundColor: Colors.white,
                
                ),
                
            SizedBox(
              height: 15,
            ),
            TextButton(
                style: TextButton.styleFrom(
                  overlayColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/loginscreen");
                },
                child: Text(
                  "Already have an account",
                  style: TextStyle(
                    color: SLCColors.primaryColor,
                  ),
                )),
          ],
        ),
      ),
    )));
  }
}
