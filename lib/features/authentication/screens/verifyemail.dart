import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import Timer
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/common/widgets/slctextfield.dart';
import 'package:slc/common/widgets/slcflushbar.dart';
import 'package:slc/features/authentication/screens/register.dart';
import 'package:slc/firebaseUtil/auth_services.dart'; // Import the new CustomFlushbar class

class VerifyEmailScreen extends StatefulWidget {
  VerifyEmailScreen({super.key});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late List<TextEditingController> _codeControllers;
  late Timer _resendTimer;
  late Timer _checkVerificationTimer;
  bool _isCodeValid = false;
  bool _isResendEnabled = false;
  int _resendTimeout = 30;
  final AuthenticationService _authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startResendTimer();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    _checkVerificationTimer.cancel();
    super.dispose();
  }

  void _initializeControllers() {
    _codeControllers = List.generate(4, (_) => TextEditingController());
  }

  void _startVerificationCheck() {
    // Check every 3 seconds if the email has been verified
    _checkVerificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        if (await _authService.isEmailVerified()) {
          timer.cancel();
          if (mounted) {
            SLCFlushbar.show(
              context: context,
              message: "Email verified successfully!",
              type: FlushbarType.success,
            );
            // Navigate to your home screen or next screen
            Navigator.pushReplacementNamed(context, "/homescreen");
          }
        }
      },
    );
  }

  void _disposeControllers() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout > 0) {
        setState(() {
          _resendTimeout--;
          _isResendEnabled = _resendTimeout == 0;
        });
      } else {
        timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }

  void _resendCode() async {
    if (_isResendEnabled) {
      await _authService.resendVerificationEmail(context);
      setState(() {
        _isResendEnabled = false;
        _resendTimeout = 30;
      });
      _startResendTimer();

      SLCFlushbar.show(
        context: context,
        message: "Verification email has been resent.",
        type: FlushbarType.success,
      );
    }
  }

  void _verifyCode() {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 4) {
      SLCFlushbar.show(
        context: context,
        message: "Please enter a 4-digit code.",
        type: FlushbarType.error,
      );
    } else if (code != "1234") {
      SLCFlushbar.show(
        context: context,
        message: "Invalid code. Please try again.",
        type: FlushbarType.error,
      );
      _clearInputFields();
    } else {
      SLCFlushbar.show(
        context: context,
        message: "Email verified successfully!",
        type: FlushbarType.success,
      );
    }
  }

  void _clearInputFields() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    setState(() {
      _isCodeValid = false;
    });
  }

  void _validateCodeForm() {
    setState(() {
      _isCodeValid = _codeControllers.every((controller) =>
          controller.text.isNotEmpty &&
          RegExp(r'^\d$').hasMatch(controller.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ??
        'No email provided';
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: SpacingStyles(context).defaultPadding,
      child: SingleChildScrollView(
        reverse: true,
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200, // Fixed width
              height: 200, // Fixed height
              child: Image.asset(
                "assets/VerifyEmailIllustration.png",
                fit: BoxFit
                    .contain, // Ensures it scales uniformly inside the container
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Text("Check Your Email",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(
              height: 15,
            ),
            const Text(
              textAlign: TextAlign.center,
              "We sent a verification code to",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              textAlign: TextAlign.center,
              email,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 40,
            ),
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    height: 68,
                    width: 64,
                    child: SLCTextField(
                      controller: _codeControllers[index],
                      onChanged: (value) {
                        if (value.length == 1) {
                          if (index < 3) {
                            FocusScope.of(context).nextFocus();
                          } else {
                            FocusScope.of(context).unfocus();
                          }
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                        _validateCodeForm();
                      },
                      textAlign: TextAlign.center,
                      labelText: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 15),
            SLCButton(
                onPressed: _isCodeValid
                    ? () {
                        HapticFeedback.heavyImpact();
                        _verifyCode();
                      }
                    : null,
                text: "Verify Email",
                backgroundColor: SLCColors.primaryColor,
                foregroundColor: Colors.white),
            const SizedBox(height: 15),
            TextButton(
                style: TextButton.styleFrom(
                  overlayColor: Colors.transparent,
                ),
                onPressed: _isResendEnabled ? _resendCode : null,
                child: Text(
                  _isResendEnabled
                      ? "Resend code"
                      : "Resend in $_resendTimeout seconds",
                  style: TextStyle(
                    color:
                        _isResendEnabled ? SLCColors.primaryColor : Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    )));
  }
}
