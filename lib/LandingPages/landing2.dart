import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LandingPage2 extends StatelessWidget {
  final PageController controller;
  const LandingPage2({super.key, required this.controller});

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
            horizontal: width * 0.07, // responsive horizontal padding
            vertical: height * 0.04,  // responsive vertical padding
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Illustration
              Center(
                child: SvgPicture.asset(
                  "assets/img4.svg",
                  height: height * 0.3, // 35% of screen height
                ),
              ),
              SizedBox(height: height * 0.07),

              // Title + Subtitle
              Column(
                children: [
                  Text(
                    "Maintain a To-Do List,\nStay on Track",
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
                    "Easily add tasks, check them off,\n"
                    "and keep track of your daily goals\n"
                    "with our simple task manager.",
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
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  ),
                  child: Text(
                    "Next",
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
