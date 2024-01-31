import 'package:admin/constants.dart';
import 'package:admin/screens/calendar/components/calendar_util.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //header
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Header(headerName: "Calendar"),
            ),
            //calendar
            Expanded(child: SingleChildScrollView(child: CalendarUtil()))
          ],
        ),
      ),
    );
  }
}
