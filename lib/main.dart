import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/firebase/firebase_options.dart';
import 'package:admin/screens/Authentication/authentiation.dart';
import 'package:admin/screens/authentication/components/auth_service.dart';
import 'package:admin/screens/dashboard/components/recent_reservations.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: MyApp()));
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      // Use Consumer to listen to ThemeProvider changes
      builder: (context, themeProvider, child) => MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthService(),
          ),
          ChangeNotifierProvider<MenuAppController>(
            create: (_) => MenuAppController(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Flutter Admin Panel',
          theme: themeProvider.isDarkMode
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: bgColor,
                  textTheme:
                      GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                          .apply(bodyColor: Colors.white),
                  canvasColor: secondaryColor,
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor:
                      lightBgColor, // Define a light background color
                  textTheme:
                      GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
                          .apply(bodyColor: Colors.black),
                  canvasColor:
                      lightSecondaryColor, // Define a light secondary color
                ),
          home: AuthenticationWrapper(),
        ),
      ),
    );
  }
}


class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return MainScreen();
          }
          return MainScreen();
        }
        return Center();
      },
    );
  }
}
