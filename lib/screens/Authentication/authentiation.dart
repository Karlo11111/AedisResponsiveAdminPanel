// ignore_for_file: non_constant_identifier_names

import 'package:admin/constants.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/authentication/components/button.dart';
import 'package:admin/screens/authentication/components/text_controller.dart';
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
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    // Try signing in
    try {
      //getting the employee document
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(emailTextController.text)
          .get();

      if (!mounted) return;

      // Dismiss the loading dialog in any case
      Navigator.pop(context);

      Map<String, dynamic>? employeeData =
          employeeDoc.data() as Map<String, dynamic>?;

      if (employeeData != null &&
          employeeData["employee"] == 'Admin' &&
          employeeData['password'] == passwordTextController.text) {
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
        body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(
                  "https://i.ibb.co/x1f0yp2/background-Image-Login.jpg"),
              fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(16)),
      child: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: Responsive.isMobile(context)
                  ? EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width / 9)
                  : EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width / 2.85),
              child: Column(
                children: [
                  Text(
                    "Aedis",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 45,
                        color: Color.fromRGBO(38, 151, 255, 1)),
                  ),
                  Text(
                    "The hotel of your dreams.",
                    style: TextStyle(
                        fontSize: 20, color: Color.fromRGBO(38, 151, 255, 1)),
                  ),
                  SizedBox(height: 25),
                  Container(
                    padding: EdgeInsets.only(
                        top: 50, bottom: 50, right: 50, left: 50),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(68, 77, 132, 1),
                        borderRadius: BorderRadius.circular(defaultPadding)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //text fields
                        MyTextField(
                          borderColor: Color.fromRGBO(53, 61, 121, 1),
                          controller: emailTextController,
                          hintText: "Email",
                          obscureText: false,
                        ),
                        SizedBox(height: 25),
                        MyTextField(
                          borderColor: Color.fromRGBO(53, 61, 121, 1),
                          controller: passwordTextController,
                          hintText: "Password",
                          obscureText: true,
                        ),

                        SizedBox(height: 25),

                        //continue button
                        MyButton(
                          buttonText: "Sign in",
                          ontap: SignIn,
                          height: 50,
                          width: 250,
                          decorationColor: primaryColor,
                          borderColor: Colors.transparent,
                          textColor: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }
}
