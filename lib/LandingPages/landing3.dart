import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:planz/router.dart';

class LandingPage3 extends StatelessWidget {
  final PageController controller;
  const LandingPage3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Screen size
    final height = size.height;
    final width = size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color.fromARGB(255, 255, 255, 255)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.07,
            vertical: height * 0.07,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Illustration
              Center(
                child: SvgPicture.asset(
                  "assets/img5.svg",
                  height: height * 0.3, // 35% of screen height
                ),
              ),
              SizedBox(height: height * 0.07),

              // Title + Subtitle
              Column(
                children: [
                  Text(
                    "Plan smarter,\nDo more",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: height * 0.035, // scales with screen height
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: height * 0.025),
                  Text(
                    "Stay organized, achieve goals, and\n"
                    "make the most of your day with our\n"
                    "easy-to-use task manager.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: height * 0.02,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.08),

              // Bottom Button
              SizedBox(
                width: width * 0.85, // 85% of screen width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Approuter.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  ),
                  child: Text(
                    "Start planning",
                    style: TextStyle(
                      fontSize: height * 0.022, // scales with screen height
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
