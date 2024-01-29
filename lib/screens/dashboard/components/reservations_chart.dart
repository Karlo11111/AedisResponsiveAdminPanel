import 'package:admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ReservationsChart extends StatelessWidget {
  final bool? animate;

  ReservationsChart({this.animate});

  @override
  Widget build(BuildContext context) {
    // Calculate the dates for 3 days before to 3 days after today
    List<DateTime> dateRange = List.generate(
        7, (index) => DateTime.now().subtract(Duration(days: 3 - index)));

    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Recent reservations graph",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: FutureBuilder<List<QuerySnapshot>>(
              future: Future.wait([
                FirebaseFirestore.instance
                    .collection('UsersReservation')
                    .where('checkInDate',
                        isGreaterThanOrEqualTo: dateRange.first,
                        isLessThanOrEqualTo: dateRange.last)
                    .get(),
                FirebaseFirestore.instance
                    .collection('DeletedReservations')
                    .where('checkInDate')
                    .get(),
              ]),
              builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error fetching reservations.');
                }
                
                // Combine data from both collections
                List<DocumentSnapshot> combinedDocs = [
                  ...snapshot.data![0].docs,
                  ...snapshot.data![1].docs,
                ];

                // Reset the count map
                Map<String, int> reservationsCountPerDay = {
                  for (var date in dateRange)
                    DateFormat('yyyy-MM-dd').format(date): 0,
                };

                // Update the map with actual counts from combined data
                for (var doc in combinedDocs) {
                  var reservationDate =
                      (doc['checkInDate'] as Timestamp).toDate();
                  var dateString =
                      DateFormat('yyyy-MM-dd').format(reservationDate);
                  if (reservationsCountPerDay.containsKey(dateString)) {
                    reservationsCountPerDay[dateString] =
                        reservationsCountPerDay[dateString]! + 1;
                  }
                }

                // Generate the data points for the chart
                List<charts.Series<ReservationCount, String>> seriesList = [
                  charts.Series<ReservationCount, String>(
                    id: 'Reservations',
                    colorFn: (_, __) =>
                        charts.MaterialPalette.blue.shadeDefault,
                    domainFn: (ReservationCount reservations, _) =>
                        reservations.date,
                    measureFn: (ReservationCount reservations, _) =>
                        reservations.count,
                    data: reservationsCountPerDay.entries
                        .map(
                            (entry) => ReservationCount(entry.key, entry.value))
                        .toList(),
                  )
                ];

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: charts.BarChart(
                    seriesList,
                    animate: animate,
                    primaryMeasureAxis: charts.NumericAxisSpec(
                      // Set the maximum y-axis value
                      viewport: charts.NumericExtents(0, 10),
                      renderSpec: charts.GridlineRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 11, // Adjust the font size as needed
                          color: charts.MaterialPalette
                              .white, // Set the text color to white
                        ),
                        lineStyle: charts.LineStyleSpec(
                          color: charts.MaterialPalette
                              .transparent, // Set line color to transparent to remove lines
                        ),
                      ),
                    ),
                    domainAxis: charts.OrdinalAxisSpec(
                      viewport:
                          charts.OrdinalViewport(dateRange[3].toString(), 7),
                      renderSpec: charts.SmallTickRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 11, // Adjust the font size as needed
                          color: charts.MaterialPalette
                              .white, // Set the text color to white
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationCount {
  final String date;
  final int count;

  ReservationCount(this.date, this.count);
}
