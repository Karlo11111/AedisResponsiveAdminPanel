// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingSwitch extends StatelessWidget {
  final String title;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final bool value;
  final Function(bool value) onTap;
  const SettingSwitch(
      {super.key,
      required this.title,
      required this.bgColor,
      required this.iconColor,
      required this.icon,
      required this.onTap,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 25,
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            title,
            style: GoogleFonts.inter(
                fontSize: 16, color: Theme.of(context).colorScheme.secondary),
          ),
          const Spacer(),
          Text(
            value ? "On" : "Off",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(
            width: 15,
          ),
          CupertinoSwitch(value: value, onChanged: onTap)
        ],
      ),
    );
  }
}
