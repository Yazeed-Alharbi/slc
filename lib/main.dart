import 'package:flutter/material.dart';
import 'package:slc/LLMTest.dart';
import 'package:slc/features/authentication/screens/forgotpassword.dart';
import 'package:slc/features/authentication/screens/login.dart';
import 'package:slc/features/authentication/screens/onborading.dart';
import 'package:slc/features/authentication/screens/register.dart';
import 'package:slc/features/authentication/screens/verifyemail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 14, 0, 103)),
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      home: Onborading(),
      routes: {
        '/onboardingscreen': (context) => const Onborading(),
        '/loginscreen': (context) =>  LoginScreen(),
        '/registerscreen': (context) =>  RegisterScreen(),
        '/forgotpassowrdscreen': (context) => ForgotPasswordScreen(),
        '/verifyemailscreen': (context) => VerifyEmailScreen(),
      },
    );
  }
}

