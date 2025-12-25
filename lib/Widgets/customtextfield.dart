import 'package:flutter/material.dart';

Widget field(String s, Icon? i, bool t,TextEditingController tc) {
  return Container(
    width: 300,
    child: TextField(
      controller: tc,
      obscureText: t,
      keyboardType: t ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2.2),
          borderRadius: BorderRadius.circular(20),
        ),
        hintText: s,
        prefixIcon: i ,
          contentPadding: i == null
            ? EdgeInsets.symmetric(vertical: 15, horizontal: 20)
            : null,
      ),
    ),
  );
}
