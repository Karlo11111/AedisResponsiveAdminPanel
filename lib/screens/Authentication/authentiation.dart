// ignore_for_file: non_constant_identifier_names

import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/Authentication/components/button.dart';
import 'package:admin/screens/Authentication/components/text_controller.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();

  //sing in function
  void SignIn() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => Center(),
    );
    // Try signing in
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      //getting the employee document
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(userCredential.user!.email)
          .get();

      if (!mounted) return;

      // Dismiss the loading dialog in any case
      Navigator.pop(context);

      Map<String, dynamic>? employeeData =
          employeeDoc.data() as Map<String, dynamic>?;

      if (employeeData != null && employeeData["employee"] == 'admin') {
        // User is an admin, navigate to MainScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // User is not an admin
        displayMessage("You are not authorized to join this website");
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Dismiss the loading dialog if an exception occurs
      Navigator.pop(context);
      // Display the error message
      displayMessage("Login failed: ${e.message}");
    }
  }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: Responsive.isDesktop(context)
                ? EdgeInsets.symmetric(horizontal: 600)
                : EdgeInsets.symmetric(horizontal: 100),
            child: Container(
              padding:
                  EdgeInsets.only(top: 80, bottom: 80, right: 20, left: 20),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(defaultPadding)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //sign in text

                  //text fields
                  MyTextField(
                    controller: emailTextController,
                    hintText: "Your Admin Email",
                    obscureText: false,
                  ),
                  SizedBox(height: defaultPadding),
                  MyTextField(
                    controller: passwordTextController,
                    hintText: "Your Admin Password",
                    obscureText: false,
                  ),

                  SizedBox(height: defaultPadding),

                  //continue button
                  MyButton(
                    buttonText: "Sign in",
                    ontap: SignIn,
                    height: 50,
                    width: double.infinity,
                    decorationColor: primaryColor,
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )
                ],
              ),
            ),
          ),
        )
      ],
    )));
  }
}
