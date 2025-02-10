import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcgooglesigninbutton.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;

  void _showFlushbar(String message, FlushbarType type) {
    SLCFlushbar.show(
      context: context,
      message: message,
      type: type,
    );
  }

  void _validateAndRegister() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showFlushbar("Please fix the errors in red.", FlushbarType.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    bool success = await AuthenticationService().signup(
      context: context,
      email: emailController.text,
      password: passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushNamed(
        context,
        "/verifyemailscreen",
        arguments: emailController.text,
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required.";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required.";
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email address.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required.";
    }
    if (value.trim().length < 8) {
      return "Password must be at least 8 characters long.";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter.";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password must contain at least one lowercase letter.";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one number.";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must contain at least one special character.";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm Password is required.";
    }
    if (value.trim() != passwordController.text.trim()) {
      return "Passwords do not match.";
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _validateEmail(emailController.text) == null &&
          _validatePassword(passwordController.text) == null &&
          _validateConfirmPassword(confirmPasswordController.text) == null &&
          _validateName(nameController.text) == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(child:Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: _isLoading
            ? const SLCLoadingIndicator(text: "Creating Account...")
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
                          "assets/RegisterIllustration.png",
                          fit: BoxFit
                              .contain, // Ensures it scales uniformly inside the container
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      SLCTextField(
                        labelText: "Name",
                        obscureText: false,
                        controller: nameController,
                        validator: _validateName,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: "Email",
                        obscureText: false,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: "Password",
                        obscureText: true,
                        controller: passwordController,
                        validator: _validatePassword,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: "Confirm Password",
                        obscureText: true,
                        controller: confirmPasswordController,
                        validator: _validateConfirmPassword,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 30),
                      SLCButton(
                        onPressed: _isFormValid ? _validateAndRegister : null,
                        text: "Sign Up",
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
                              context, "/loginscreen");
                        },
                        child: Text(
                          "Already have an account",
                          style: TextStyle(
                            color: SLCColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      )),
    );
  }
}
