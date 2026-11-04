import 'package:flutter/material.dart';
import 'package:planz/LandingPages/OnBoardingPage.dart';
import 'package:planz/LandingPages/landingmain.dart';
import 'package:planz/auth/login.dart';
import 'package:planz/auth/register.dart';
import 'package:planz/pages/PageNav.dart';

class Approuter {
  static const String landing = '/landing';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  // Firebase sign-in screens. Not part of the offline flow, kept for a
  // possible future sync feature (Firebase is not initialised in main()).
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings page) {
    switch (page.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingMain());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case home:
        return MaterialPageRoute(builder: (_) => const PageNave());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("No page found"))),
        );
    }
  }
}
