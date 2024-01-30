import 'package:admin/constants.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';

class EmployersPage extends StatelessWidget {
  const EmployersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Header(headerName: "Employers",),
          ),
        ],
      ),
    );
  }
}