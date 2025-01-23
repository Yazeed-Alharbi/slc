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
                   SvgPicture.asset(
                    "assets/StudyIllustration.svg",
                    semanticsLabel: 'Study Illustration',
                  ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Your Personal Study Assistant",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: SLCColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Text(
                  "Unlock a new approach to learning. Whether you’re preparing for exams or mastering new concepts, we’re here to help you stay organized and focused.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SLCButton(
                      onPressed: (){}, 
                      text: "Sign In", 
                      backgroundColor: SLCColors.primaryColor, 
                      foregroundColor: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    SizedBox(
                      width: 20,
                    ),
                    SLCButton(
                      onPressed: (){}, 
                      text: "Sign Up", 
                      backgroundColor: Colors.white, 
                      foregroundColor: SLCColors.primaryColor,
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.05
                      ),
                  ],
                )
              ],
            ),
          
        )),
      ),
    );
  }
}
