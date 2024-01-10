import 'package:admin/models/RecentReservations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

  Stream<List<UserReservation>> streamReservations() {
    return FirebaseFirestore.instance
        .collection('UsersReservation')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                UserReservation.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Reservations",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: StreamBuilder<List<UserReservation>>(
              stream: streamReservations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  print(
                      "Error fetching data: ${snapshot.error}"); // Debugging line
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No Data Available");
                }
                var reservations = snapshot.data!;
                return DataTable(
                  columnSpacing: defaultPadding,
                  columns: [
                    DataColumn(label: Text("Full Name")),
                    DataColumn(label: Text("Check-in Date")),
                    DataColumn(label: Text("Country")),
                  ],
                  rows: reservations
                      .map((reservation) => recentFileDataRow(reservation))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow recentFileDataRow(UserReservation reservation) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(reservation.title!),
            ),
          ],
        ),
      ),
      DataCell(Text(reservation.getFormattedDate())),
      DataCell(Text(reservation.size ?? 'Unknown Size'))
    ],
  );
}
