import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _showFlushbar(String message, FlushbarType type) {
    SLCFlushbar.show(
      context: context,
      message: message,
      type: type,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required.";
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required.";
    }
    return null;
  }

  void _login() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showFlushbar("Please fix the errors in red.", FlushbarType.error);
      return;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey, // Attach the GlobalKey to the Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/LoginIllustration.png",
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
                const SizedBox(height: 40),

                Text(
                  "Login",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                /// Email TextFormField with validation
                SLCTextField(
                  labelText: "Email",
                  obscureText: false,
                  controller: emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 15),

                /// Password TextFormField with validation
                SLCTextField(
                  labelText: "Password",
                  obscureText: true,
                  controller: passwordController,
                  validator: _validatePassword,
                ),

                /// Forgot Password?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        overlayColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/forgotpassowrdscreen");
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: SLCColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                /// Sign In Button
                SLCButton(
                  onPressed: _login,
                  text: "Sign In",
                  backgroundColor: SLCColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 15),

                /// Create new account
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/registerscreen");
                  },
                  child: Text(
                    "Create new account",
                    style: TextStyle(
                      color: SLCColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
