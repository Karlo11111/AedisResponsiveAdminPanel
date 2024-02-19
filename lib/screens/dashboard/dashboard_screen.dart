// ignore_for_file: deprecated_member_use

import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/my_reservations.dart';
import 'package:admin/screens/dashboard/components/reservations_chart.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/header.dart';

import 'components/recent_reservations.dart';
import 'components/activity_overview.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(headerName: "Dashboard",),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      
                      MyFiles(),
                      SizedBox(height: defaultPadding),
                      RecentReservations(),
                      SizedBox(height: defaultPadding),
                      ReservationsChart(),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) ActivityOverview(),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we don't want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: ActivityOverview(),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
