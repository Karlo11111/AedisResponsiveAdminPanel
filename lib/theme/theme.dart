// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Color.fromARGB(255, 242, 242, 242),
      primary: Colors.black,
      secondary: Color.fromARGB(255, 48, 88, 150),
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        background: Color.fromARGB(255, 33, 35, 50),
        primary: Colors.white,
        secondary: Color.fromARGB(255, 175, 197, 233)));
