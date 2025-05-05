import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';

class Onborading extends StatelessWidget {
  const Onborading({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Safe way to access localized strings with fallbacks
    final personalAssistant = l10n?.personalStudyAssistant ?? 'Your Personal Study Assistant';
    final unlockLearning = l10n?.unlockLearning ?? 'Unlock a new approach to learning';
    final signIn = l10n?.signIn ?? 'Sign In';
    final signUp = l10n?.signUp ?? 'Sign Up';

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: SpacingStyles(context).defaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200, // Fixed width
                height: 200, // Fixed height
                child: Image.asset(
                  "assets/StudyIllustration.png",
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  personalAssistant,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Text(unlockLearning,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SLCButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/loginscreen");
                    },
                    text: signIn,
                    backgroundColor: SLCColors.primaryColor,
                    foregroundColor: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.35,
                  ),
                  SLCButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, "/registerscreen");
                    },
                    text: signUp,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    foregroundColor: SLCColors.primaryColor,
                    width: MediaQuery.of(context).size.width * 0.35,
                  )
                ],
              )
            ],
          ),
        )),
      ),
    );
  }
}
