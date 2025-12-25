import 'package:flutter/material.dart';
import 'package:planz/LandingPages/landingmain.dart';
import 'package:planz/auth/login.dart';
import 'package:planz/auth/register.dart';
import 'package:planz/pages/PageNav.dart';
import 'package:planz/pages/voice.dart';
import 'package:planz/providers/task_notifier.dart';

class Approuter {
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String voice = "/voice";
  static const String schedule = "/schedule";

  static Route<dynamic> generateRoute(RouteSettings page) {
    switch (page.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => LandingMain());
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => PageNave());
      

      // case schedule:
      // return MaterialPageRoute(builder: (_)=>);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Text("No Page found")),
        );
    }
  }
}
