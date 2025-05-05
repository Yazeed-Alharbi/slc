import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import this
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/repositories/student_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Student.dart';

class VerifyEmailScreen extends StatefulWidget {
  VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final StudentRepository _studentRepository = StudentRepository(
    firestoreUtils: FirestoreUtils(),
  );

  late Timer _checkVerificationTimer;
  late Timer _resendTimer;
  bool _isResendEnabled = false;
  int _resendTimeout = 60;

  @override
  void initState() {
    super.initState();
    _loadResendCooldown();
    _sendVerificationEmailIfNeeded();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _checkVerificationTimer.cancel();
    _resendTimer.cancel();
    super.dispose();
  }

  void _loadResendCooldown() async {
    String? lastSentTimeString =
        await _secureStorage.read(key: 'last_verification_email');
    int lastSentTime = int.tryParse(lastSentTimeString ?? '0') ?? 0;
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    int elapsedTime = (currentTime - lastSentTime) ~/ 1000; // Convert ms to sec
    int remainingTime = _resendTimeout - elapsedTime;

    if (remainingTime > 0) {
      setState(() {
        _resendTimeout = remainingTime;
        _isResendEnabled = false;
      });
      _startResendTimer();
    } else {
      setState(() {
        _isResendEnabled = true;
        _resendTimeout = 0;
      });
    }
  }


  void _sendVerificationEmailIfNeeded() async {
    String? lastSentTimeString =
        await _secureStorage.read(key: 'last_verification_email');
    int lastSentTime = int.tryParse(lastSentTimeString ?? '0') ?? 0;
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - lastSentTime > _resendTimeout * 1000) {
      await _authService.resendVerificationEmail(context);
      await _secureStorage.write(
          key: 'last_verification_email', value: currentTime.toString());
      setState(() {
        _resendTimeout = 60;
        _isResendEnabled = false;
      });
      _startResendTimer();
    }
  }

  void _startResendTimer() {
    if (_resendTimeout <= 0) return;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout > 0) {
        setState(() {
          _resendTimeout--;
          _isResendEnabled = (_resendTimeout == 0);
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// Periodically checks if the user has verified their email
  void _startVerificationCheck() {
  _checkVerificationTimer = Timer.periodic(
    const Duration(seconds: 3),
    (timer) async {
      // Check if user is signed in first, sign in if needed
      if (_authService.getCurrentUser() == null) {
        // Skip this check cycle if not signed in
        return;
      }
      
      // Force reload the user to get latest emailVerified status
      await _authService.reloadCurrentUser();
      
      if (await _authService.isEmailVerified()) {
        timer.cancel();
        if (mounted) {
          // Get localized success message
          final l10n = AppLocalizations.of(context);
          final successMessage = l10n?.emailVerified ?? "Email verified successfully!";

          SLCFlushbar.show(
            context: context,
            message: successMessage,
            type: FlushbarType.success,
          );

          // Use repository instead of direct FirestoreUtils access
          Student? student = await _studentRepository.getOrCreateStudent();
          if (student != null) {
            Navigator.pushReplacementNamed(
              context,
              "/homescreen",
              arguments: student,
            );
          } else {
            final errorMessage = l10n?.failedToLoadUserData ?? "Failed to load user data";
            SLCFlushbar.show(
              context: context,
              message: errorMessage,
              type: FlushbarType.error,
            );
          }
        }
      }
    },
  );
}

  /// Manually resend the verification email
  void _resendVerificationEmail() async {
    if (_isResendEnabled) {
      await _authService.resendVerificationEmail(context);
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      await _secureStorage.write(
          key: 'last_verification_email', value: currentTime.toString());

      setState(() {
        _resendTimeout = 60; // Reset cooldown
        _isResendEnabled = false;
      });
      _startResendTimer();

      SLCFlushbar.show(
        context: context,
        message: "Verification email has been resent.",
        type: FlushbarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ??
        'No email provided';

    // Get localized strings
    final l10n = AppLocalizations.of(context);

    // Using localized strings with fallbacks
    final checkEmailText = l10n?.checkEmail ?? "Check Your Email";
    final sentVerificationLinkText =
        l10n?.sentVerificationLink ?? "We sent a verification link to";
    final clickVerificationLinkText = l10n?.clickVerificationLink ??
        "Please click on the verification link in the email to verify your account. Once verified, you'll be automatically redirected to the home screen.";
    final resendEmailText = l10n?.resendEmail ?? "Resend Email";
    final resendInSecondsText = l10n?.resendInSeconds(_resendTimeout) ??
        "Resend in $_resendTimeout seconds";
    final backToLoginText = l10n?.backToLogin ?? "Back to login";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: SpacingStyles(context).defaultPadding,
          child: SingleChildScrollView(
            reverse: true,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    "assets/VerifyEmailIllustration.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  checkEmailText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 15),
                Text(
                  sentVerificationLinkText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Text(
                  clickVerificationLinkText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: _isResendEnabled ? _resendVerificationEmail : null,
                  child: Text(
                    _isResendEnabled ? resendEmailText : resendInSecondsText,
                    style: TextStyle(
                      color: _isResendEnabled
                          ? SLCColors.primaryColor
                          : Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Add a Back to Login button
                const SizedBox(height: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: () async {
                    // Sign out the user and navigate back to login
                    await _authService.signOut(context);
                    Navigator.pushReplacementNamed(
                        context, '/onboardingscreen');
                  },
                  child: Text(
                    backToLoginText,
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
      ),
    );
  }
}
