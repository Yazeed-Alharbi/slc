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
import 'package:slc/dartUtil/validators.dart';
import 'package:slc/repositories/student_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Student.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final StudentRepository _studentRepository = StudentRepository(
    firestoreUtils: FirestoreUtils(),
  );
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

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _validateForm() {
    setState(() {
      _isFormValid = Validators.validateEmail(emailController.text) == null &&
          Validators.validatePasswordSimple(passwordController.text) == null;
    });
  }

  void _login() async {
    // Get localized strings for errors
    final l10n = AppLocalizations.of(context);
    final pleaseFixErrors =
        l10n?.pleaseFixErrors ?? "Please fix the errors in red.";
    final failedToLoadUserData =
        l10n?.failedToLoadUserData ?? "Failed to load user data";

    if (!_isFormValid) {
      _showFlushbar(pleaseFixErrors, FlushbarType.error);
      return;
    }
    _setLoading(true);
    bool success = await _authService.signin(
      context: context,
      email: emailController.text,
      password: passwordController.text,
    );

    if (success) {
      bool isVerified = await _authService.isEmailVerified();
      if (!mounted) return;
      if (isVerified) {
        // Use repository instead of direct Firestore access
        Student? student = await _studentRepository.getOrCreateStudent();
        if (student != null) {
          Navigator.pushReplacementNamed(
            context,
            "/homescreen",
            arguments: student,
          );
        } else {
          _showFlushbar(failedToLoadUserData, FlushbarType.error);
        }
      } else {
        Navigator.pushNamed(
          context,
          "/verifyemailscreen",
          arguments: emailController.text,
        );
      }
    }
    _setLoading(false);
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final validators = Validators.of(context);

    // Use localized strings with fallbacks
    final loginTitle = l10n?.login ?? "Login";
    final emailLabel = l10n?.email ?? "Email";
    final passwordLabel = l10n?.password ?? "Password";
    final forgotPassword = l10n?.forgotPassword ?? "Forgot Password?";
    final signIn = l10n?.signIn ?? "Sign In";
    final createNewAccount = l10n?.createNewAccount ?? "Create new account";
    final signingIn = l10n?.signingIn ?? "Signing In...";

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: SpacingStyles(context).defaultPadding,
        child: _isLoading
            ? SLCLoadingIndicator(text: signingIn)
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
                          "assets/LoginIllustration.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loginTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      SLCTextField(
                        labelText: emailLabel,
                        obscureText: false,
                        controller: emailController,
                        validator: validators.validateEmail,
                        onChanged: (_) => _validateForm(),
                      ),
                      const SizedBox(height: 15),
                      SLCTextField(
                        labelText: passwordLabel,
                        obscureText: true,
                        controller: passwordController,
                        validator: validators
                            .validatePasswordSimple, // Use the simple validator here
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
                              forgotPassword,
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
                        text: signIn,
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
                              context, "/registerscreen");
                        },
                        child: Text(
                          createNewAccount,
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
