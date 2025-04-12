import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/common/widgets/slcbutton.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/models/Student.dart';

class SLCGoogleSignInButton extends StatelessWidget {
  final Function(bool) setLoading;
  final Function(Student?) onGoogleSignInSuccess;

  const SLCGoogleSignInButton({
    Key? key,
    required this.setLoading,
    required this.onGoogleSignInSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get localized strings
    final l10n = AppLocalizations.of(context);
    final buttonText = l10n?.continueWithGoogle ?? "Continue with Google";

    // Determine text direction
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SLCButton(
      onPressed: () async {
        setLoading(true);
        Student? student = await AuthenticationService().googleSignIn(context);
        setLoading(false);

        onGoogleSignInSuccess(student);
      },
      text: buttonText,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      foregroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      // Add the Google logo icon with proper RTL support
      icon: Padding(
        padding: EdgeInsets.only(
          right: isRTL ? 0 : 8,
          left: isRTL ? 8 : 0,
        ),
        child: Image.asset("assets/GoogleLogo.png", width: 25, height: 25),
      ),
    );
  }
}
