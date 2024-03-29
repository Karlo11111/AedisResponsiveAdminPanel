// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:admin/models/RecentReservations.dart';
import 'package:admin/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  bool isLoading = false;
  //funciton that fetches reservations from firebase
  Stream<List<UserReservation>> streamReservations() {
    return FirebaseFirestore.instance
        .collection('UsersReservation')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserReservation.fromMap(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? secondaryColor
        : lightSecondaryColor;

    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;

    return Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Container(
                padding: EdgeInsets.all(defaultPadding),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Reservations",
                      style: TextStyle(color: mainPrimaryTextColor),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: StreamBuilder<List<UserReservation>>(
                        stream: streamReservations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                            var dateA =
                                a.checkInDate?.toDate() ?? DateTime(9999);
                            var dateB =
                                b.checkInDate?.toDate() ?? DateTime(9999);
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
                                      DataColumn(
                                          label: Text("Full Name",
                                              style: TextStyle(
                                                  color:
                                                      mainPrimaryTextColor))),
                                      DataColumn(
                                          label: Text("Check-in Date",
                                              style: TextStyle(
                                                  color:
                                                      mainPrimaryTextColor))),
                                      DataColumn(
                                          label: Text("Country",
                                              style: TextStyle(
                                                  color:
                                                      mainPrimaryTextColor))),
                                      DataColumn(
                                          label: Text("Check-In",
                                              style: TextStyle(
                                                  color:
                                                      mainPrimaryTextColor))),
                                      DataColumn(
                                          label: Text("More Info",
                                              style: TextStyle(
                                                  color:
                                                      mainPrimaryTextColor))),
                                    ],
                                    rows: reservations
                                        .map((reservation) => recentFileDataRow(
                                            context, reservation))
                                        .toList(),
                                  ),
                                )
                              : DataTable(
                                  columnSpacing: defaultPadding,
                                  columns: [
                                    DataColumn(
                                        label: Text("Full Name",
                                            style: TextStyle(
                                                color: mainPrimaryTextColor))),
                                    DataColumn(
                                        label: Text("Check-in Date",
                                            style: TextStyle(
                                                color: mainPrimaryTextColor))),
                                    DataColumn(
                                        label: Text("Country",
                                            style: TextStyle(
                                                color: mainPrimaryTextColor))),
                                    DataColumn(
                                        label: Text("Check-In",
                                            style: TextStyle(
                                                color: mainPrimaryTextColor))),
                                    DataColumn(
                                        label: Text("More Info",
                                            style: TextStyle(
                                                color: mainPrimaryTextColor))),
                                  ],
                                  rows: reservations
                                      .map((reservation) => recentFileDataRow(
                                          context, reservation))
                                      .toList(),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ));
  }

  //function for uploading the image when on the pc
  void _uploadImage() {
    setState(() {
      isLoading = true;
    });
    // Create an HTML file input element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';

    // Trigger the file input element to open the file selector
    uploadInput.click();

    // Listen for changes
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

            // Send the image to the Microblink API
            try {
              await sendImageToMicroblinkApi(base64Content);
            } finally {
              // Hide progress indicator regardless of success/failure
              setState(() {
                isLoading = false;
              });
            }
          }
        });
      }
    });

    // Remove the input element after file selection
    uploadInput.onChange.first.then((_) {
      uploadInput.remove();
    });
  }

  //function for alert dialog for choosing the upload or camera
  void uploadOrCaptureImage(BuildContext context) {
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

  DataRow recentFileDataRow(BuildContext context, UserReservation reservation) {
    bool isCheckedIn = reservation.isCheckedIn!;

    Color mainPrimaryColor = Theme.of(context).brightness == Brightness.dark
        ? primaryColor
        : lightPrimaryColor;

    Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? lightTextColor
        : lightTextColor;

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(reservation.title!,
                    style: TextStyle(color: mainPrimaryTextColor)),
              ),
            ],
          ),
        ),
        DataCell(Text(reservation.getFormattedCheckInDate(),
            style: TextStyle(color: mainPrimaryTextColor))),
        DataCell(Text(reservation.size ?? 'Unknown Size',
            style: TextStyle(color: mainPrimaryTextColor))),
        DataCell(isCheckedIn
            ? TextButton(
                onPressed: () {},
                //here is the check in button
                child: Text(
                  "User is already checked-in",
                  style: TextStyle(color: mainPrimaryColor),
                ),
              )
            : TextButton(
                onPressed: () {
                  uploadOrCaptureImage(context);
                },
                //here is the check in button
                child: Text(
                  "Check-In",
                  style: TextStyle(color: mainPrimaryColor),
                ),
              )),
        DataCell(IconButton(
          onPressed: () => showMoreInfoDialog(context, reservation),
          icon: Icon(
            Icons.more_horiz,
            color: mainPrimaryTextColor,
          ),
        )),
      ],
    );
  }
}

//dialog box for more info button on the data table
void showMoreInfoDialog(BuildContext context, UserReservation reservation) {
  Color mainPrimaryColor = Theme.of(context).brightness == Brightness.dark
      ? primaryColor
      : lightPrimaryColor;

  Color backgroundColor = Theme.of(context).brightness == Brightness.dark
      ? secondaryColor
      : lightSecondaryColor;

  Color mainPrimaryTextColor = Theme.of(context).brightness == Brightness.dark
      ? lightTextColor
      : lightTextColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: backgroundColor,
        title: Text("User Information",
            style: TextStyle(color: mainPrimaryTextColor)),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              //all of the user data, from RecentReservations.dart
              Text("Full name: ${reservation.title}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Check-in Date: ${reservation.getFormattedCheckInDate()}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Check-Out Date: ${reservation.getFormattedCheckOutDate()}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Country: ${reservation.size}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Number of adults in the stay: ${reservation.adults}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Number of children in the stay: ${reservation.children}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Phone number of the guest: ${reservation.phone}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Guests account email: ${reservation.email}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Guests account password: ${reservation.password}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Guests room number: ${reservation.roomNumber}",
                  style: TextStyle(color: mainPrimaryTextColor)),
              SizedBox(height: defaultPadding),
              Text("Is checked in: ${reservation.isCheckedIn}",
                  style: TextStyle(color: mainPrimaryTextColor)),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "Close",
              style: TextStyle(color: mainPrimaryColor),
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

//function for capturing an image when on the phone
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

//function for sending the id to the mrz api
Future<void> sendImageToMicroblinkApi(String base64Image) async {
  const String microblinkApiUrl =
      'https://api.microblink.com/v1/recognizers/mrtd';

  const String authorizationHeader =
      "Bearer MjQzMTRhYTY1NWIyNDZlYjgzZWVhNzNmOTk1NGMxMjE6YzBlNzQxZDEtNzI3ZC00OGI0LTgzYjAtYWM3ZWZiZjZlMjk2";

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
      processScanResult(data);
    } else {
      print('Failed to scan MRZ: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending image to Microblink API: $e');
  }
}

//function for processing scan result
void processScanResult(Map<String, dynamic> scanResult) async {
  // Extract information from the scanResult map
  String firstName = formatFirstAndLastName(
      scanResult['result']['firstName'] ?? 'Not available');
  String lastName = formatFirstAndLastName(
      scanResult['result']['lastName'] ?? 'Not available');

  // Assuming dateOfBirth is a map with day, month, and year keys
  Map<String, dynamic> dateOfBirthMap =
      scanResult['result']['dateOfBirth'] as Map<String, dynamic>;
  String dateOfBirth =
      "${dateOfBirthMap['day']}/${dateOfBirthMap['month']}/${dateOfBirthMap['year']}";

  // Same for dateOfExpiry
  Map<String, dynamic> dateOfExpiryMap =
      scanResult['result']['dateOfExpiry'] as Map<String, dynamic>;
  String dateOfExpiry =
      "${dateOfExpiryMap['day']}/${dateOfExpiryMap['month']}/${dateOfExpiryMap['year']}";

  String nationality = scanResult['result']['nationality'] ?? 'Not available';
  String gender = scanResult['result']['sex'] ?? 'Not available';

  // Find the reservation ID based on the unique identifier
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('UsersReservation')
      .where('firstName', isEqualTo: firstName)
      .where('lastName', isEqualTo: lastName)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    String reservationId = querySnapshot.docs.first.id;
    // Call the function to show the confirmation dialog
    showConfirmationDialog(
      firstName,
      lastName,
      dateOfBirth,
      dateOfExpiry,
      nationality,
      gender,
      reservationId,
    );
  } else {
    displayMessage("FUCKING HELL ERROR");
  }
}

//shows the comfirmation dialog after the mrz scan
void showConfirmationDialog(
  String firstName,
  String lastName,
  String dateOfBirth,
  String dateOfExpiry,
  String nationality,
  String gender,
  String reservationId,
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
              updateCheckIn(reservationId);
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

//function that displays a message
void displayMessage(String message) {
  showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) => AlertDialog(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(message),
            ),
          ));
}

//function that updates the reservation id with the checkedIn field to true
void updateCheckIn(String reservationId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference reservationRef =
      firestore.collection('UsersReservation').doc(reservationId);

  try {
    await reservationRef.update({'checkedIn': true});
    displayMessage('Reservation check-in updated successfully');
  } catch (e) {
    displayMessage('Error updating reservation check-in: $e');
  }
}

//function for formatting the mrz scan text
String formatFirstAndLastName(String text) {
  if (text.isEmpty) return text;
  return text
      .toLowerCase()
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
