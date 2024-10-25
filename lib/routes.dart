import 'package:flutter/material.dart';
import 'package:rental_tax_port/screens/auth/login_screen.dart';
import 'package:rental_tax_port/screens/auth/register_screen.dart';
import 'package:rental_tax_port/screens/home/home_screen.dart';
import 'package:rental_tax_port/screens/onboarding_screen.dart';
import 'package:rental_tax_port/screens/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case '/onboarding':
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
  }
}