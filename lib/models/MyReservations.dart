import 'package:admin/constants.dart';
import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String? svgSrc, title;
  final int? numOfFiles, percentage;
  final Color? color;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.numOfFiles,
    this.percentage,
    this.color,
  });
}

List demoMyFiles = [
  CloudStorageInfo(
    title: "Reservations",
    numOfFiles: 1328,
    svgSrc: "assets/icons/Documents.svg",
    
    color: primaryColor,
    percentage: 35,
  ),
  CloudStorageInfo(
    title: "Tasks",
    numOfFiles: 1328,
    svgSrc: "assets/icons/Documents.svg",
    
    color: primaryColor,
    percentage: 35,
  ),
  CloudStorageInfo(
    title: "Total profit",
    numOfFiles: 1328,
    svgSrc: "assets/icons/google_drive.svg",
    color: Color(0xFFFFA113),
    percentage: 35,
  ),
  CloudStorageInfo(
    title: "Total cost",
    numOfFiles: 1328,
    svgSrc: "assets/icons/one_drive.svg",
    color: Color(0xFFA4CDFF),
    percentage: 10,
  ),
  
];
