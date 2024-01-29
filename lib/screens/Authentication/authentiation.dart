import 'package:admin/constants.dart';
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
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    // Try signing in
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      // Check if the user is an employee
      FirebaseFirestore.instance
          .collection('Employees')
          .doc(userCredential.user!.email)
          .get()
          .then((doc) {
        if (doc.exists) {
          // User is an employee, navigate to employee page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          displayMessage("You are not authorized to join this website");
        }
      });
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      Navigator.pop(context);
      // Display if there's an error while logging in
      displayMessage(e.code);
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 600),
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
                  decorationColor: secondaryColor,
                  borderColor: primaryColor,
                  textColor: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )
              ],
            ),
          ),
        )
      ],
    )));
  }
}
