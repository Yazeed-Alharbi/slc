import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcgooglesigninbutton.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/dartUtil/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;

  void _showFlushbar(String message, FlushbarType type) {
    SLCFlushbar.show(
      context: context,
      message: message,
      type: type,
    );
  }

  void _validateForm() {
    setState(() {
      _isFormValid = Validators.validateEmail(emailController.text) == null &&
          Validators.validatePassword(passwordController.text) == null;
    });
  }

  void _login() async {
    if (!_isFormValid) {
      _showFlushbar("Please fix the errors in red.", FlushbarType.error);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    bool success = await AuthenticationService().signin(
      context: context,
      email: emailController.text,
      password: passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (success) {
      // Home screen should go here as a route or something
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
      body: SafeArea(
          child: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: _isLoading
            ? const SLCLoadingIndicator(text: "Signing In...")
            : SingleChildScrollView(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 200, // Fixed width
                        height: 200, // Fixed height
                        child: Image.asset(
                          "assets/LoginIllustration.png",
                          fit: BoxFit
                              .contain, // Ensures it scales uniformly inside the container
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      SLCTextField(
                        labelText: "Email",
                        obscureText: false,
                        controller: emailController,
                        validator: Validators.validateEmail,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: "Password",
                        obscureText: true,
                        controller: passwordController,
                        validator: Validators.validatePassword,
                        onChanged: (_) => _validateForm(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              overlayColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, "/forgotpassowrdscreen");
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
                      SLCButton(
                        onPressed: _isFormValid ? _login : null,
                        text: "Sign In",
                        backgroundColor: SLCColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      SLCGoogleSignInButton(),
                      const SizedBox(height: 10),
                      TextButton(
                        style: TextButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, "/registerscreen");
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
      )),
    );
  }
}
