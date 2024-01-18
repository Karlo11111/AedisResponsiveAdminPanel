import 'package:admin/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gantt_chart/gantt_chart.dart';

class CalendarUtil extends StatefulWidget {
  const CalendarUtil({Key? key}) : super(key: key);

  @override
  State<CalendarUtil> createState() => _CalendarUtilState();
}

class _CalendarUtilState extends State<CalendarUtil> {
  final ScrollController _scrollController = ScrollController();
  double _dayWidth = 30;
  late DateTime ganttChartStartDate;

  @override
  void initState() {
    super.initState();
    ganttChartStartDate = DateTime.now().subtract(Duration(days: 7));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //stream that gets all of the data
  Stream<Map<int, List<GanttRelativeEvent>>>? getGroupedRoomEvents() {
    return FirebaseFirestore.instance
        .collection('AvailableRooms')
        .snapshots()
        .map((snapshot) {
      Map<int, List<GanttRelativeEvent>> roomEventsMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final roomNumber = data['roomNumber'];
        print(roomNumber);
        roomEventsMap[roomNumber] = []; // Initialize list for each room

        if (data['reservations'] != null) {
          final reservations = data['reservations'] as List<dynamic>;
          for (var reservation in reservations) {
            if (reservation['checkInDate'] != null &&
                reservation['checkOutDate'] != null) {
              DateTime checkInDate =
                  (reservation['checkInDate'].toDate()).toUtc();
              DateTime checkOutDate =
                  (reservation['checkOutDate'].toDate()).toUtc();

              // Normalize dates to midnight for consistent day calculations
              checkInDate = DateTime(
                  checkInDate.year, checkInDate.month, checkInDate.day);
              checkOutDate = DateTime(
                  checkOutDate.year, checkOutDate.month, checkOutDate.day);
              int startDay = checkInDate.difference(ganttChartStartDate).inDays + 1;
              if (startDay < 0) startDay = 0;

              // Calculate duration
              int duration = checkOutDate.difference(checkInDate).inDays + 1;

              // Add the event to the room's list
              roomEventsMap[roomNumber]!.add(GanttRelativeEvent(
                relativeToStart: Duration(days: startDay),
                duration: Duration(days: duration),
                displayName: "${reservation['name']}",
                roomNumber: roomNumber,
              ));
            }
          }
        }
      }
      return roomEventsMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, List<GanttRelativeEvent>>>(
      stream: getGroupedRoomEvents(), // Stream of grouped room events
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        // Flatten the grouped events into a single list while keeping track of the room numbers
        List<GanttRelativeEvent> allEvents = [];
        List<int> roomNumbers = [];
        snapshot.data!.forEach((roomNumber, events) {
          roomNumbers.add(roomNumber);
          allEvents.addAll(events);
        });

        return GanttChartView(
          scrollController: _scrollController,
          maxDuration: Duration(days: 180),
          startDate: ganttChartStartDate,
          dayWidth: _dayWidth,
          eventHeight: 60,
          stickyAreaWidth: 100,
          showStickyArea: true,
          startOfTheWeek: WeekDay.monday,
          weekEnds: const {},
          stickyAreaEventBuilder: (context, eventIndex, event, eventColor) {
            // Assuming GanttRelativeEvent now has a roomNumber property
            final roomNumber = event.roomNumber;

            // Find if this is the first event for this room
            final isFirstEventForRoom = eventIndex == 0 ||
                allEvents[eventIndex - 1].roomNumber != roomNumber;

            return isFirstEventForRoom
                ? Container(
                    width: 100,
                    color: primaryColor,
                    child: Center(
                      child: Text(
                        "Room $roomNumber",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                // Return an empty container for subsequent events of the same room
                : Container();
          },
          events: allEvents, // Use the flattened list of events
        );
      },
    );
  }
}
