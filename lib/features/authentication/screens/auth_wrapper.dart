import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slc/features/authentication/screens/onborading.dart';
import 'package:slc/common/layout/main_layout.dart';
import 'package:slc/features/authentication/screens/verifyemail.dart';
import 'package:slc/repositories/student_repository.dart';
import 'package:slc/firebaseUtil/firestore.dart';
import 'package:slc/common/widgets/slcloadingindicator.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to authentication state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: SLCLoadingIndicator(text: "Starting up..."),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
            // If email is verified, load student data and go to main layout
            return FutureBuilder(
              future: StudentRepository(firestoreUtils: FirestoreUtils())
                  .getOrCreateStudent(),
              builder: (context, studentSnapshot) {
                if (studentSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: SLCLoadingIndicator(text: "Loading your data..."),
                    ),
                  );
                }

                if (studentSnapshot.hasData && studentSnapshot.data != null) {
                  return MainLayout(student: studentSnapshot.data!);
                } else {
                  // Something went wrong with loading the student data
                  return const Onborading();
                }
              },
            );
          } else {
            // Email is not verified
            return Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => VerifyEmailScreen(),
                settings: RouteSettings(
                  arguments: FirebaseAuth.instance.currentUser?.email,
                ),
              ),
            );
          }
        }

        // User is not logged in
        return const Onborading();
      },
    );
  }
}
