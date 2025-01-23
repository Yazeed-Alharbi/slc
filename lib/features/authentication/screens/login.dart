import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
            const Text(
              "Login",
              style: TextStyle(
                  color: SLCColors.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(
              height: 40,
            ),
            
            Image.asset("assets/LoginIllustration.png", width: MediaQuery.of(context).size.width*0.6,),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            SLCTextField(
              labelText: "Email",
              obscureText: false,
              controller: emailController,
            ),
            const SizedBox(
              height: 30,
            ),
            SLCTextField(
              labelText: "Password",
              obscureText: true,
              controller: passwordController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: Colors.transparent,
                    ),
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: SLCColors.primaryColor),
                    )),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            SLCButton(
                onPressed: () {},
                text: "Sign In",
                backgroundColor: SLCColors.primaryColor,
                foregroundColor: Colors.white),
                SizedBox(
              height: 15,
            ),
            TextButton(
                style: TextButton.styleFrom(
                  overlayColor: Colors.transparent,
                ),
                onPressed: () {},
                child: Text(
                  "Create new account",
                  style:
                      TextStyle(color: SLCColors.primaryColor,),
                )),
                SizedBox(
              height: 30,
            ),
            

          ],
        ),
      ),
    )));
  }
}
