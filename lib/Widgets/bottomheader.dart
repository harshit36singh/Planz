import 'package:flutter/material.dart';

Widget bottomsheetheader() {
  return Padding(
    padding: EdgeInsetsGeometry.symmetric(vertical: 4),
    child: Center(
      child: Container(
        width: 60,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );
}