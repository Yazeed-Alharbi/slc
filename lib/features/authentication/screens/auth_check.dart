import 'package:flutter/material.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';
import 'package:slc/firebaseUtil/auth_services.dart';
import 'package:slc/repositories/student_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/models/Student.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final StudentRepository _studentRepository = StudentRepository(
    firestoreUtils: FirestoreUtils(),
  );

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay to prevent flash of loading screen for quick checks
    await Future.delayed(const Duration(milliseconds: 500));

    final isSignedIn = _authService.getCurrentUser() != null;

    if (!mounted) return;

    if (isSignedIn) {
      final isVerified = await _authService.isEmailVerified();

      if (!mounted) return;

      if (isVerified) {
        final student = await _studentRepository.getOrCreateStudent();

        if (!mounted) return;

        if (student != null) {
          Navigator.pushReplacementNamed(
            context,
            '/homescreen',
            arguments: student,
          );
        } else {
          Navigator.pushReplacementNamed(context, '/onboardingscreen');
        }
      } else {
        // If email isn't verified, send to verify email screen
        final email = _authService.getCurrentUser()?.email ?? '';
        Navigator.pushReplacementNamed(
          context,
          '/verifyemailscreen',
          arguments: email,
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, '/onboardingscreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SLCLoadingIndicator(text: "Starting up..."),
      ),
    );
  }
}
