// ignore_for_file: prefer_const_constructors, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {this.enabled,
      required this.controller,
      required this.hintText,
      required this.borderColor,
      required this.obscureText});

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool? enabled;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(53, 61, 121, 1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color.fromRGBO(53, 61, 121, 1),
              width: 2.0,
            ),
          ),
          labelText: hintText,
          labelStyle: GoogleFonts.inter(
            color: Color.fromRGBO(38, 151, 255, 1),
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          contentPadding: EdgeInsets.only(left: 30, top: 20, bottom: 20)),
    );
  }
}
