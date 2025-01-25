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
      resizeToAvoidBottomInset: true,
        body: Padding(
          padding: SpacingStyles(context).defaultPadding,
          child: SingleChildScrollView(
            reverse: true,
            physics: BouncingScrollPhysics(),
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
                 Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.titleLarge
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
                  keyboardType: TextInputType.emailAddress,
                  labelText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(
                  height: 15,
                ),
                SLCTextField(
                  keyboardType: TextInputType.visiblePassword,
                  labelText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                SizedBox(
                  height: 15,
                ),
                SLCTextField(
                  keyboardType: TextInputType.visiblePassword,
                  labelText: "Confirm Password",
                  obscureText: true,
                  controller: confirmPasswordController,
                ),
                SizedBox(
                  height: 30,
                ),
                SLCButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/verifyemailscreen");
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
        ));
  }
}
