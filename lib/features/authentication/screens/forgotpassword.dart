import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/dartUtil/validators.dart'; // Add this for localized validators

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool _isFormValid = false;
  bool _isLoading = false;

  /// Calls Firebase to send reset password email
  void _resetPassword() async {
    // Get localized text for error message
    final l10n = AppLocalizations.of(context);
    final pleaseFixErrors =
        l10n?.pleaseFixErrors ?? "Please fix the errors in red.";

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      SLCFlushbar.show(
        context: context,
        message: pleaseFixErrors,
        type: FlushbarType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await AuthenticationService().resetPassword(
      context: context,
      email: emailController.text,
    );

    setState(() {
      _isLoading = false;
    });

    emailController.clear();
  }

  void _validateForm() {
    // Use localized validators
    final validators = Validators.of(context);

    setState(() {
      _isFormValid = validators.validateEmail(emailController.text) == null;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final validators = Validators.of(context);

    // Use localized strings with fallbacks
    final forgotPasswordText =
        l10n?.forgotPasswordQuestion ?? "Forgot Password?";
    final resetInstructions = l10n?.resetInstructions ??
        "No worries, we'll send you reset instructions.";
    final emailLabel = l10n?.email ?? "Email";
    final resetPasswordButton = l10n?.resetPassword ?? "Reset Password";
    final backToLogin = l10n?.backToLogin ?? "Back to login";
    final sendingInstructions =
        l10n?.sendingResetInstructions ?? "Sending reset instructions...";

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: _isLoading
            ? SLCLoadingIndicator(text: sendingInstructions)
            : SingleChildScrollView(
                reverse: true,
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          "assets/ForgotPasswordIllustration.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        forgotPasswordText,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        resetInstructions,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      SLCTextField(
                        labelText: emailLabel,
                        obscureText: false,
                        controller: emailController,
                        validator: validators.validateEmail,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 30),
                      SLCButton(
                        onPressed: _isFormValid ? _resetPassword : null,
                        text: resetPasswordButton,
                        backgroundColor: SLCColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      const SizedBox(height: 15),
                      TextButton(
                        style: TextButton.styleFrom(
                            overlayColor: Colors.transparent),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          backToLogin,
                          style: TextStyle(
                              color: SLCColors.primaryColor,
                              fontWeight: FontWeight.w700),
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
