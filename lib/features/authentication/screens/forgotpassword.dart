import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isFormValid = false;

  void _resetPassword() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      SLCFlushbar.show(
        context: context,
        message: "Please fix the errors in red.",
        type: FlushbarType.error,
      );
    } else {
      SLCFlushbar.show(
        context: context,
        message: "Reset instructions has been sent to ${emailController.text}",
        type: FlushbarType.success,
      );
      emailController.clear();
    }
    return;
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

  void _validateForm() {
    setState(() {
      _isFormValid = _validateEmail(emailController.text) == null;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 200, // Fixed width
                  height: 200, // Fixed height
                  child: Image.asset(
                    "assets/ForgotPasswordIllustration.png",
                    fit: BoxFit
                        .contain, // Ensures it scales uniformly inside the container
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Forgot Password?",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 15),
                const Text(
                  "No worries, we'll send you reset instructions.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                SLCTextField(
                  labelText: "Email",
                  obscureText: false,
                  controller: emailController,
                  validator: _validateEmail,
                  onChanged: (_) => _validateForm(),
                ),
                const SizedBox(height: 15),
                const SizedBox(height: 30),
                SLCButton(
                  onPressed: _isFormValid ? _resetPassword : null,
                  text: "Reset Password",
                  backgroundColor: SLCColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 15),
                TextButton(
                  style: TextButton.styleFrom(overlayColor: Colors.transparent),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Back to login",
                    style: TextStyle(
                        color: SLCColors.primaryColor,
                        fontWeight: FontWeight.w700),
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
