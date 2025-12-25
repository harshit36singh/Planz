import 'package:flutter/material.dart';
import 'package:planz/LandingPages/landing.dart';
import 'package:planz/LandingPages/landing2.dart';
import 'package:planz/LandingPages/landing3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LandingMain extends StatefulWidget {
  const LandingMain({super.key});

  @override
  State<LandingMain> createState() => _LandingMainState();
}

class _LandingMainState extends State<LandingMain> {
  final PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: controller,
            
           
            children: [
             LandingPage1(controller: controller,),
             LandingPage2(controller:controller),
             LandingPage3(controller:controller),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 70),
            child: SmoothPageIndicator(controller: controller, count: 3
            ,
            
          
            effect:ExpandingDotsEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: Color(0xFF6C63FF)
            ),),
            
          ),
        ],
      ),
    );
  }
}
