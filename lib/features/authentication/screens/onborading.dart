import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/styles/spcaing_styles.dart';
import 'package:slc/common/widgets/slcbutton.dart';

class Onborading extends StatelessWidget {
  const Onborading({super.key});

  @override
  Widget build(BuildContext context) {
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
                  "Your Personal Study Assistant",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Text(
                  "Unlock a new approach to learning. Whether you’re preparing for exams or mastering new concepts, we’re here to help you stay organized and focused.",
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
                    text: "Sign In",
                    backgroundColor: SLCColors.primaryColor,
                    foregroundColor: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.35,
                  ),
                  SLCButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, "/registerscreen");
                    },
                    text: "Sign Up",
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
