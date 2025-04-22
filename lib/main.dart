import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:slc/common/layout/main_layout.dart';
import 'package:slc/features/authentication/screens/forgotpassword.dart';
import 'package:slc/features/authentication/screens/login.dart';
import 'package:slc/features/authentication/screens/onborading.dart';
import 'package:slc/features/authentication/screens/register.dart';
import 'package:slc/features/authentication/screens/verifyemail.dart';
import 'package:slc/common/styles/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slc/features/course%20management/screens/addcourse.dart';
import 'package:slc/models/Student.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slc/features/authentication/screens/auth_wrapper.dart';
import 'package:slc/services/notifications_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slc/common/styles/locale_theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:slc/common/providers/theme_provider.dart';
import 'package:slc/common/providers/language_provider.dart';

// Create a session manager class to handle session checks
class SessionManager {
  static void checkForActiveSession() {
    // Implement session checking logic here
    final currentUser = FirebaseAuth.instance.currentUser;
    // Add your session validation logic here
  }
}

// Define a global key to access the home screen state
final GlobalKey<State> homeScreenKey = GlobalKey<State>();

// Navigation observer to detect screen changes - fix the implementation
class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    // When returning to any screen, check if the HomeScreen is visible
    // Use a microtask to ensure it runs AFTER the current build phase completes
    Future.microtask(() {
      if (homeScreenKey.currentState != null) {
        // Use a try-catch to prevent errors
        try {
          final state = homeScreenKey.currentState as dynamic;
          if (state.checkForActiveSession != null) {
            state.checkForActiveSession();
          }
        } catch (e) {
          print('Error checking active session: $e');
        }
      }
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv BEFORE any code that uses it
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications service
  await NotificationsService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // any other providers you have
      ],
      child: const MyApp(),
    ),
  );
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

        // Get theme provider to access current theme mode
        final themeProvider = Provider.of<ThemeProvider>(context);
        final languageProvider = Provider.of<LanguageProvider>(context);

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: scale),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: lightMode,
            darkTheme: darkMode,
            themeMode: themeProvider.themeMode, // Use provider's theme mode
            home: AuthWrapper(),
            navigatorObservers: [AppNavigationObserver()],
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale:
                languageProvider.locale, // Use the language provider's locale
            builder: (context, child) {
              // Get the current locale
              final isArabic =
                  Localizations.localeOf(context).languageCode == 'ar';

              // Use the theme provider's dark mode state
              final isDarkMode = themeProvider.isDarkMode;

              // Get the appropriate theme based on provider's state and locale
              final themeData = isDarkMode
                  ? getThemeForLocale(darkMode, isArabic)
                  : getThemeForLocale(lightMode, isArabic);

              return Theme(
                data: themeData,
                child: child ?? const SizedBox(),
              );
            },
            routes: {
              '/onboardingscreen': (context) => const Onborading(),
              '/loginscreen': (context) => LoginScreen(),
              '/registerscreen': (context) => RegisterScreen(),
              '/forgotpassowrdscreen': (context) => ForgotPasswordScreen(),
              '/verifyemailscreen': (context) => VerifyEmailScreen(),
              '/addcourse': (context) => AddCourseScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/homescreen') {
                final student = settings.arguments as Student;
                return MaterialPageRoute(
                  builder: (context) => MainLayout(student: student),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
