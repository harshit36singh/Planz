import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planz/providers/user_provider.dart';
import 'package:planz/router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  Future<void> saveName() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your name",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ref
          .read(userProvider.notifier)
          .completeOnboarding(nameController.text);

      if (mounted) {
        Navigator.pushReplacementNamed(context, Approuter.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Something went wrong. Please try again.",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.05),

                  // Top Illustration
                  Center(
                    child: SvgPicture.asset(
                      "assets/img5.svg",
                      height: height * 0.25,
                    ),
                  ),
                  SizedBox(height: height * 0.05),

                  // Welcome text
                  Text(
                    "Welcome to Planz!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: height * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  Text(
                    "Let's get started by introducing yourself",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: height * 0.02,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: height * 0.05),

                  // Name input field
                  SizedBox(
                    width: width * 0.85,
                    child: TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's your name?",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF6C63FF),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => saveName(),
                    ),
                  ),

                  SizedBox(height: height * 0.05),

                  // Features list
                  Container(
                    width: width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          Icons.cloud_off,
                          "100% Offline",
                          "All data stored locally",
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          Icons.lock_outline,
                          "Private & Secure",
                          "Your data never leaves your device",
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem(
                          Icons.dark_mode_outlined,
                          "Dark Mode",
                          "Easy on your eyes",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.05),

                  // Start button
                  SizedBox(
                    width: width * 0.85,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: height * 0.022),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "Get Started",
                              style: GoogleFonts.inter(
                                fontSize: height * 0.022,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // Skip button
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(userProvider.notifier)
                                .completeOnboarding(UserNotifier.defaultName);
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              Approuter.home,
                            );
                          },
                    child: Text(
                      "Skip for now",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
