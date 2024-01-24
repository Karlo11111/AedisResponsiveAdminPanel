// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:admin/models/RecentReservations.dart';
import 'package:admin/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import '../../../constants.dart';

class RecentReservations extends StatefulWidget {
  const RecentReservations({
    Key? key,
  }) : super(key: key);

  @override
  State<RecentReservations> createState() => _RecentReservationsState();
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _RecentReservationsState extends State<RecentReservations> {
  

  //funciton that fetches reservations from firebase
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
                  return Center(
                    child: Text("Waiting for connection!"),
                  );
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
                // Sorting the reservations by check-in date
                reservations.sort((a, b) {
                  // Handle null dates by placing them at the end
                  var dateA = a.checkInDate?.toDate() ?? DateTime(9999);
                  var dateB = b.checkInDate?.toDate() ?? DateTime(9999);
                  return dateA.compareTo(dateB);
                });
                //the data table for users reservations
                return Responsive.isMobile(context) ||
                        Responsive.isTablet(context)
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: defaultPadding,
                          columns: [
                            DataColumn(label: Text("Full Name")),
                            DataColumn(label: Text("Check-in Date")),
                            DataColumn(label: Text("Country")),
                            DataColumn(label: Text("Check-In")),
                            DataColumn(label: Text("More Info")),
                          ],
                          rows: reservations
                              .map((reservation) =>
                                  recentFileDataRow(context, reservation))
                              .toList(),
                        ),
                      )
                    : DataTable(
                        columnSpacing: defaultPadding,
                        columns: [
                          DataColumn(label: Text("Full Name")),
                          DataColumn(label: Text("Check-in Date")),
                          DataColumn(label: Text("Country")),
                          DataColumn(label: Text("Check-In")),
                          DataColumn(label: Text("More Info")),
                        ],
                        rows: reservations
                            .map((reservation) =>
                                recentFileDataRow(context, reservation))
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

DataRow recentFileDataRow(BuildContext context, UserReservation reservation) {
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
      DataCell(Text(reservation.getFormattedCheckInDate())),
      DataCell(Text(reservation.size ?? 'Unknown Size')),
      DataCell(TextButton(
        onPressed: () {
          openCameraAndScanMRZ(context);
        },
        child: Text(
          "Check-In",
          style: TextStyle(color: primaryColor),
        ),
      )),
      DataCell(IconButton(
        onPressed: () => showMoreInfoDialog(context, reservation),
        icon: Icon(Icons.more_horiz),
      )),
    ],
  );
}

//dialog box for more info button on the data table
void showMoreInfoDialog(BuildContext context, UserReservation reservation) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("User Information"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              //all of the user data, from RecentReservations.dart
              Text("Full name: ${reservation.title}"),
              SizedBox(height: defaultPadding),
              Text("Check-in Date: ${reservation.getFormattedCheckInDate()}"),
              SizedBox(height: defaultPadding),
              Text("Check-Out Date: ${reservation.getFormattedCheckOutDate()}"),
              SizedBox(height: defaultPadding),
              Text("Country: ${reservation.size}"),
              SizedBox(height: defaultPadding),
              Text("Number of adults in the stay: ${reservation.adults}"),
              SizedBox(height: defaultPadding),
              Text("Number of children in the stay: ${reservation.children}"),
              SizedBox(height: defaultPadding),
              Text("Phone number of the guest: ${reservation.phone}"),
              SizedBox(height: defaultPadding),
              Text("Guests account email: ${reservation.email}"),
              SizedBox(height: defaultPadding),
              Text("Guests account password: ${reservation.password}"),
              SizedBox(height: defaultPadding),
              Text("Guests room number: ${reservation.roomNumber}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close",
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void openCameraAndScanMRZ(BuildContext context) {
  // Show an alert dialog with options
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Upload or Capture Image'),
        content: Text('Choose how you want to provide the image.'),
        actions: <Widget>[
          TextButton(
            child: Text('Upload Image'),
            onPressed: () {
              Navigator.of(context).pop();
              _uploadImage();
            },
          ),
          TextButton(
            child: Text('Capture Image'),
            onPressed: () {
              Navigator.of(context).pop();
              _captureImage();
            },
          ),
        ],
      );
    },
  );
}

void _uploadImage() {
  // Create an HTML file input element
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
    ..accept = 'image/*';

  // Trigger the file input element to open the file selector
  uploadInput.click();

  // Listen for changes (i.e., when a file is selected)
  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();

      // Read the file as a data URL
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) async {
        if (reader.result != null) {
          final String base64String = reader.result as String;
          final String base64Content = base64String.split(',')[1];

          // Send the image to the Microblink API or your backend
          await sendImageToMicroblinkApi(
              base64Content); // Or your own function for handling the image
        }
      });
    }
  });

  // Remove the input element after file selection
  uploadInput.onChange.first.then((_) {
    uploadInput.remove();
  });
}

void _captureImage() {
  // Create an HTML file input element
  html.FileUploadInputElement input = html.FileUploadInputElement()
    ..accept = 'image/*';

  // Set the capture attribute to use the camera
  input.setAttribute('capture', 'environment');

  // Add the input element to the body to ensure events are triggered properly
  html.document.body!.children.add(input);

  // Trigger the file input element to open the camera
  input.click();

  // Listen for changes (i.e., when an image is captured)
  input.onChange.listen((e) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();

      // Read the file as a data URL
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) async {
        if (reader.result != null) {
          final String base64String = reader.result as String;
          final String base64Content = base64String.split(',')[1];

          // Send the image to the Microblink API or your backend
          await sendImageToMicroblinkApi(
              base64Content); // Replace with your function
        }
      });
    }
  });

  // Remove the input element after file selection
  input.onChange.first.then((_) {
    input.remove();
  });
}

Future<void> sendImageToMicroblinkApi(String base64Image) async {
  const String microblinkApiUrl =
      'https://api.microblink.com/v1/recognizers/mrtd';

  const String authorizationHeader =
      "Bearer NDk2ZGQxOTVlYTYxNDM1Y2IwNDVlOTEyYTZhNDg2M2M6ZTY4MjU0NjAtMDJiOC00ZjJmLWFkMGMtM2FkOTFjNmRhMjJl";

  // Construct the body according to the Microblink MRTDRequest schema
  final body = jsonEncode({
    'returnFullDocumentImage': false,
    'returnFaceImage': false,
    'returnSignatureImage': false,
    'allowBlurFilter': false,
    'allowUnparsedMrzResults': false,
    'allowUnverifiedMrzResults': true,
    'validateResultCharacters': true,
    'anonymizationMode': 'FULL_RESULT',
    'anonymizeImage': true,
    'ageLimit': 0,
    'imageSource': base64Image,
  });

  try {
    final response = await http.post(
      Uri.parse(microblinkApiUrl),
      headers: {
        'Authorization': authorizationHeader,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Process the data
      print(data);
      // TODO: Implement your logic to handle the scanned data.
      processScanResult(data);
    } else {
      print('Failed to scan MRZ: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending image to Microblink API: $e');
  }
}

void processScanResult(Map<String, dynamic> scanResult) {
  // Extract information from the scanResult map
  String firstName = scanResult['result']['firstName'] ?? 'Not available';
  String lastName = scanResult['result']['lastName'] ?? 'Not available';

  // Assuming dateOfBirth is a map with day, month, and year keys
  Map<String, dynamic> dobMap =
      scanResult['result']['dateOfBirth'] as Map<String, dynamic>;
  String dateOfBirth = "${dobMap['day']}/${dobMap['month']}/${dobMap['year']}";

  // Same for dateOfExpiry
  Map<String, dynamic> doeMap =
      scanResult['result']['dateOfExpiry'] as Map<String, dynamic>;
  String dateOfExpiry = "${doeMap['day']}/${doeMap['month']}/${doeMap['year']}";

  String nationality = scanResult['result']['nationality'] ?? 'Not available';
  String gender = scanResult['result']['sex'] ?? 'Not available';

  // Call the function to show the confirmation dialog
  showConfirmationDialog(
      firstName, lastName, dateOfBirth, dateOfExpiry, nationality, gender);
}

void showConfirmationDialog(
  String firstName,
  String lastName,
  String dateOfBirth,
  String dateOfExpiry,
  String nationality,
  String gender,
  // ...other parameters
) {
  showDialog(
    context: navigatorKey.currentState!.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Information'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('First Name: $firstName'),
              Text('Last Name: $lastName'),
              Text('Date of birth: $dateOfBirth'),
              Text('Date of expiry: $dateOfExpiry'),
              Text('Nationality: $nationality'),
              Text('Gender: $gender'),
              // ...other information
            ],
          ),
        ),
        actions: [
          //CONFIRM BUTTON
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          //CANCEL BUTTON
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
