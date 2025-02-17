import 'package:flutter/material.dart';
import 'package:slc/common/layout/main_layout.dart';
import 'package:slc/features/authentication/screens/forgotpassword.dart';
import 'package:slc/features/authentication/screens/login.dart';
import 'package:slc/features/authentication/screens/onborading.dart';
import 'package:slc/features/authentication/screens/register.dart';
import 'package:slc/features/authentication/screens/verifyemail.dart';
import 'package:slc/common/styles/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/course management/screens/addcourse.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final mediaQueryData = MediaQuery.of(context);

        final scale = mediaQueryData.textScaler
            .clamp(maxScaleFactor: 1.5, minScaleFactor: 1.0);

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: lightMode,
            darkTheme: darkMode,
            home:
                MainLayout(), // Change to Onboarding() to return to the onboarding flow
            routes: {
              '/onboardingscreen': (context) => const Onborading(),
              '/loginscreen': (context) => LoginScreen(),
              '/registerscreen': (context) => RegisterScreen(),
              '/forgotpassowrdscreen': (context) => ForgotPasswordScreen(),
              '/verifyemailscreen': (context) => VerifyEmailScreen(),
              '/addcourse': (context) => AddCourseScreen(),
            },
          ),
        );
      },
    );
  }
}
