import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_svg/svg.dart';
import 'package:planz/Widgets/customtextfield.dart';
import 'package:planz/auth/login.dart';
import 'package:planz/router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController name=TextEditingController();
    final TextEditingController email=TextEditingController();
  final TextEditingController pass=TextEditingController();
  bool isLoading=false;

Future<void> signup() async{
  try{
    setState(()=>isLoading=true);
  UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: email.text.trim(), password: pass.text.trim());

    await FirebaseFirestore.instance
        .collection('users') // make sure collection is 'users'
        .doc(userCredential.user!.uid) // doc = uid
        .set({
      'name': name.text.trim(),
      'email': email.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

   ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Registered Succesfully",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 117, 216, 115),
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)
          ),
         
        ),
      );
  Navigator.pushNamed(context, Approuter.home);
  }on FirebaseException catch(e){
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Registration Failed",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(20),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)
          ),
         
        ),
      );

  }
  finally{
    setState(() =>isLoading=false);
  }

  
}
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( 
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.06),
              Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/img6.svg",
                  height: size.height * 0.25, 
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Center(
                child: Text(
                  "SignUp.",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                ),
              ),
              Center(
                child: Text(
                  "Start Organizing..",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Center(child: field("Name", Icon(Icons.person), false,name)),
              SizedBox(height: size.height * 0.02),
              Center(child: field("Email", Icon(Icons.email), false,email)),
              SizedBox(height: size.height * 0.02),
              Center(child: field("Password", Icon(Icons.password), true,pass)),
              SizedBox(height: size.height * 0.03),

              Center(
                child: Container(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      signup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text("SignUp", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    child: Text(
                      "SignIn",
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ responsive reusable field
