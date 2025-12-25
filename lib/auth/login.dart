import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:planz/Widgets/customtextfield.dart';
import 'package:planz/router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  bool isLoading = false;

  Future<void> signin() async {
    try {
      setState(() => isLoading = true);

      UserCredential usercred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: pass.text.trim(),
      );
      final user = usercred.user;
      if (user != null) {
        await Hive.openBox("todo_${user.uid}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "Login Successful",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        Navigator.pushNamed(context, Approuter.home);
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Login Failed",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),
              Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/img3.svg",
                  height: size.height * 0.3,
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: Text(
                  "SignIn.",
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.006),
              Center(
                child: Text(
                  "Welcome Back..",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(child: field("Email", const Icon(Icons.email), false, email)),
              const SizedBox(height: 15),

              Center(
                child: field("Password", const Icon(Icons.password), true, pass),
              ),
              const SizedBox(height: 12),

              Center(
                child: Row(
                  children: [
                    SizedBox(width: size.width * 0.51),
                    Text(
                      "Forgot Password ?",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Sign In",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      "SignUp",
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, Approuter.register);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}