// ignore_for_file: unused_field

import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/tasks/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Widget _currentBody = DashboardScreen(); // default screen

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _currentBody = _getBodyWidget(index); 
    });
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return TasksScreen();
      default:
        return DashboardScreen(); // or some other default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemSelected,
                ),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: _currentBody,
            ),
          ],
        ),
      ),
    );
  }
}
