import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slcgooglesigninbutton.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/dartUtil/validators.dart'; // Import validators
import 'package:slc/models/Student.dart';

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

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _validateAndRegister() async {
    final l10n = AppLocalizations.of(context);
    final pleaseFixErrors =
        l10n?.pleaseFixErrors ?? "Please fix the errors in red.";

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showFlushbar(pleaseFixErrors, FlushbarType.error);
      return;
    }
    _setLoading(true);

    // First, create the user account (BUT DON'T SIGN OUT)
    bool success = await AuthenticationService().signup(
      context: context,
      email: emailController.text,
      password: passwordController.text,
      fullName: nameController.text,
    );

    _setLoading(false);

    // Now go to verification screen (user remains signed in)
    if (success) {
      Navigator.pushReplacementNamed(
        context,
        "/verifyemailscreen",
        arguments: emailController.text,
      );
    }
  }

  void _handleGoogleSignInSuccess(Student? student) {
    // Get localized string for error
    final l10n = AppLocalizations.of(context);
    final googleSignInFailed =
        l10n?.googleSignInFailed ?? "Google sign-in failed.";

    if (student != null) {
      Navigator.pushReplacementNamed(
        context,
        "/homescreen",
        arguments: student,
      );
    } else {
      _showFlushbar(googleSignInFailed, FlushbarType.error);
    }
  }

  void _validateForm() {
    // Use localized validators
    final validators = Validators.of(context);

    setState(() {
      _isFormValid = validators.validateEmail(emailController.text) == null &&
          validators.validatePassword(passwordController.text) == null &&
          validators.validateConfirmPassword(
                  confirmPasswordController.text, passwordController.text) ==
              null &&
          validators.validateName(nameController.text) == null;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final validators = Validators.of(context);

    // Use localized strings with fallbacks
    final createAccount = l10n?.createAccount ?? "Create Account";
    final nameLabel = l10n?.name ?? "Name";
    final emailLabel = l10n?.email ?? "Email";
    final passwordLabel = l10n?.password ?? "Password";
    final confirmPasswordLabel = l10n?.confirmPassword ?? "Confirm Password";
    final signUp = l10n?.signUp ?? "Sign Up";
    final alreadyHaveAccount =
        l10n?.alreadyHaveAccount ?? "Already have an account?";
    final creatingAccount = l10n?.creatingAccount ?? "Creating Account...";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: _isLoading
            ? SLCLoadingIndicator(text: creatingAccount)
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
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        createAccount,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      SLCTextField(
                        labelText: nameLabel,
                        obscureText: false,
                        controller: nameController,
                        validator: validators.validateName,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: emailLabel,
                        obscureText: false,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validators.validateEmail,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: passwordLabel,
                        obscureText: true,
                        controller: passwordController,
                        validator: validators.validatePassword,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: confirmPasswordLabel,
                        obscureText: true,
                        controller: confirmPasswordController,
                        validator: (value) =>
                            validators.validateConfirmPassword(
                                value, passwordController.text),
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 30),
                      SLCButton(
                        onPressed: _isFormValid ? _validateAndRegister : null,
                        text: signUp,
                        backgroundColor: SLCColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      SLCGoogleSignInButton(
                        setLoading: _setLoading,
                        onGoogleSignInSuccess: _handleGoogleSignInSuccess,
                      ),
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
                          alreadyHaveAccount,
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
