import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Padding(
              padding: SpacingStyles(context).defaultPadding,
              child: SingleChildScrollView(
                reverse: true,
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/ForgotPasswordIllustration.png", width: MediaQuery.of(context).size.width*0.6,),
                    
                    const SizedBox(
                      height: 40,
                    ),
                    
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: SLCColors.primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "No worries, we'll send you reset instructions.",
                      style: TextStyle(
                          
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    SLCTextField(
                      labelText: "Email",
                      obscureText: false,
                      controller: emailController,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    
                  
                    SizedBox(
                      height: 30,
                    ),
                    SLCButton(
                        onPressed: () {},
                        text: "Reset Password",
                        backgroundColor: SLCColors.primaryColor,
                        foregroundColor: Colors.white),
                        SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Back to login",
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
