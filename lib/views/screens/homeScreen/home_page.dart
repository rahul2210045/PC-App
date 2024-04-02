import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pc_app/components/custom_action_CheckBox.dart';
import 'package:pc_app/components/custom_button.dart';
import 'package:pc_app/main.dart';
import 'package:pc_app/views/screens/qrScaning.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pc_app/models/qr_scann_model.dart';
import 'package:pc_app/repository/qr_scann_repo.dart';
import 'package:pc_app/views/screens/homeScreen/home_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../models/student_details_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StudentData studentData;
  int _selectedCheckboxIndex = -1;
  bool _isLoading = false;
  String qrResult = '';
  String _actionValue = '';

  //..............Api Intigration for TakeAction Api ...........................

  Future<void> _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.https('pc.anaskhan.site', '/api/action');

    final Map<String, String> requestBody = {
      'qr_data': '${qrResult}',
      'action': '${_actionValue}'
    };
    print('qrResult: ${qrResult}');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': '${PreferencesManager().token}'
        },
        body: jsonEncode(requestBody),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final Map<String, dynamic> responseData = json.decode(response.body);
        final message = responseData['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully : $message'),
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _isLoading = false;
        });
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final message = responseData['message'];
        print('Failed: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
    // if (isChecked) {
    //   final prefs = await SharedPreferences.getInstance();
    //   prefs.setString('username', _usernameController.text);
    //   prefs.setString('password', _passController.text);
    // }
  }

  //...............QR Scanning intigration......................................
  // Future<void> scanQR() async {
  //   try {
  //     final qrCode = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //     if (!mounted) return;
  //     setState(() {
  //       this.qrResult = qrCode.toString();
  //     });
  //     if (qrResult.isNotEmpty) {
  //       fetchAndParseQrData();
  //       showSuccessSnackbar('QR code scanned successfully ');
  //       print(qrResult);
  //     }
  //   } on PlatformException {
  //     showErrorSnackbar('Failed to read QR code');
  //   }
  // }

//   ...................... calling function for QR Fetch Api...................

  Future<String> fetchQrData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': '${PreferencesManager().token}',
    };
    var request =
        http.Request('GET', Uri.parse('https://pc.anaskhan.site/api/fetch_qr'));
    request.body = jsonEncode({'qr_data': '$qrResult'});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      return responseBody;
      // return await response.stream.bytesToString();
    } else if (response.statusCode == 400) {
      //     // Handle error code 400 separately
      getAccessToken();
      return 'Bad request: ${response.reasonPhrase}';
    } else {
      throw Exception('Failed to get access token: ${response.reasonPhrase}');
    }
  }

  void _fetchAndPrintQrData() async {
    try {
      String responseData = await fetchQrData();
      print(responseData);

//...........decode fetch data from API.........................
      Map<String, dynamic> jsonResponse = json.decode(responseData);
      String studentId = jsonResponse['student_id'];
      String studentName = jsonResponse['student_name'];
      bool isPaid = jsonResponse['isPaid'];
      bool isContestOnly = jsonResponse['isContestOnly'];
      bool day1Attendance = jsonResponse['day1_attendance'];
      bool day2Attendance = jsonResponse['day2_attendance'];
      bool contestAttendance = jsonResponse['contest_attendance'];
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return MyBottomSheet(
            studentId: studentId,
            studentName: studentName,
            isPaid: isPaid,
            isContestOnly: isContestOnly,
            day1Attendance: day1Attendance,
            day2Attendance: day2Attendance,
            contestAttendance: contestAttendance,
          );
        },
      );

//...............BottomSheet function......................................
    } catch (e) {
      if (e is http.Response) {
        // Access response body
        String responseBody = e.body;

        // Decode response body as JSON
        try {
          Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
          print('Error response JSON: $jsonResponse');
        } catch (error) {
          print('Error decoding JSON: $error');
        }
      } else {
        // Handle other types of errors
        print('Error: $e');
      }
    }
  }

  Future<StudentData> fetchAndParseQrData() async {
    try {
      String responseData = await fetchQrData();
      print(responseData);

      // Decode fetch data from API
      Map<String, dynamic> jsonResponse = json.decode(responseData);
      studentData = StudentData.fromJson(jsonResponse);
      print(studentData);
      return studentData;

    } catch (e) {
      print('Error: $e');
      // Handle errors by returning null or throwing an exception
      throw e;
    }
  }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      setState(() {
        this.qrResult = qrCode.toString();
      });
      if (qrResult.isNotEmpty) {
        print("----------------------------------------------------------------------------------------------");
        await fetchAndParseQrData();
        print("----------------------------------------------------------------------------------------------");
        showSuccessSnackbar('QR code scanned successfully ');
        setState(() {

        });
        print(qrResult);
      }
    } on PlatformException {
      showErrorSnackbar('Failed to read QR code');
    }
  }

  //.................  function to call an Api ...........................

  Future<String> getAccessToken() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'GET', Uri.parse('https://pc.anaskhan.site/api/get_access_token'));
    request.body =
        jsonEncode({'refresh_token': '${PreferencesManager().refreshToken}'});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // Get the response body
      String responseBody = await response.stream.bytesToString();
      // Print the status code and response body
      Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
      PreferencesManager().token = jsonResponse['access_token'];
      print(' New Access Token: ${PreferencesManager().token}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');
      return responseBody;
      // return await response.stream.bytesToString();
    } else {
      throw Exception('Failed to get access token: ${response.reasonPhrase}');
    }
  }

  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Change color as needed
      ),
    );
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade500,
      ),
    );
  }

  // Show snackbar indicating that actionValue and qrResult must not be empty
  void _showSnackbarFunction() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Action value and QR result must not be empty."),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: const Text("Programming Club"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
        backgroundColor: Colors.red.shade100,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: mq.height * 0.06,
              ),
              (studentData.isPaid == true) ? Text("Payment Status:     Paid", style: TextStyle(fontSize: 20),)
              : LabeledCheckbox(
                label: 'Payment Status',
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                value: _selectedCheckboxIndex == 0,
                onChanged: (bool newValue) {
                  // setState(() {
                  //   _isSelected1 = newValue;
                  // });
                  setState(() {
                    if (newValue) {
                      _selectedCheckboxIndex = 0;
                      _actionValue = 'pay';
                    } else {
                      _selectedCheckboxIndex = -1;
                      _actionValue = '';
                    }
                  });
                },
              ),
              (studentData.day1Attendance == true)? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Day1 Attendance:", style: TextStyle(fontSize: 20),),
                  Text("Present", style: TextStyle(fontSize: 20),),
                ],
              )
              :LabeledCheckbox(
                label: 'Day1 Attendance',
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                // value: _isSelected2,
                value: _selectedCheckboxIndex == 1,
                onChanged: (bool newValue) {
                  setState(() {
                    if (newValue) {
                      _selectedCheckboxIndex = 1;
                      _actionValue = 'mark_day1';
                    } else {
                      _selectedCheckboxIndex = -1;
                      _actionValue = '';
                    }
                  });
                },
              ),
              (studentData.day2Attendance == true)? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Day2 Attendance:", style: TextStyle(fontSize: 20),),
                  Text("Present", style: TextStyle(fontSize: 20),),
                ],
              )
              :LabeledCheckbox(
                label: 'Day2 Attendance',
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                // value: _isSelected3,
                value: _selectedCheckboxIndex == 2,
                onChanged: (bool newValue) {
                  setState(() {
                    if (newValue) {
                      _selectedCheckboxIndex = 2;
                      _actionValue = 'mark_day2';
                    } else {
                      _selectedCheckboxIndex = -1;
                      _actionValue = '';
                    }
                  });
                },
              ),
              (studentData.contestAttendance == true)? Text("Contest Attendance:   Present", style: TextStyle(fontSize: 20),)
              :LabeledCheckbox(
                label: 'Contest Attendance',
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                // value: _isSelected4,
                value: _selectedCheckboxIndex == 3,
                onChanged: (bool newValue) {
                  setState(() {
                    if (newValue) {
                      _selectedCheckboxIndex = 3;
                      _actionValue = 'mark_contest';
                    } else {
                      _selectedCheckboxIndex = -1;
                      _actionValue = '';
                    }
                  });
                },
              ),
              SizedBox(
                height: mq.height * 0.06,
              ),
              CustomButton(
                text: "Update",
                color: Colors.red.shade200,
                textColor: Colors.black,
                function: (_actionValue.isNotEmpty && qrResult.isNotEmpty)
                    ? _markAttendance
                    : _showSnackbarFunction,
                // function: _markAttendance,
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),
              // CustomButton(
              //   text: "Participant Details",
              //   color: Colors.red.shade200,
              //   textColor: Colors.black,
              //   // function: _fetchAndPrintQrData,
              //   function: fetchAndParseQrData(),
              //   // function: _markAttendance,
              // ),
              CustomButton(
                text: "Participant Details",
                color: Colors.red.shade200,
                textColor: Colors.black,
                function: _fetchAndPrintQrData,

                // function: _markAttendance,
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4E82EA)),
                      strokeWidth: 5.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      //floating button to scan Qr
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.red.shade200,
          onPressed: scanQR,
          //  {
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (_) => const QrViewExample()));
          // },
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }
}

//////////////////////all set till now ..............................
/////..................now next step ................................
///
///
///

class MyBottomSheet extends StatelessWidget {
  final String studentId;
  final String studentName;
  final bool isPaid;
  final bool isContestOnly;
  final bool day1Attendance;
  final bool day2Attendance;
  final bool contestAttendance;

  const MyBottomSheet({
    required this.studentId,
    required this.studentName,
    required this.isPaid,
    required this.isContestOnly,
    required this.day1Attendance,
    required this.day2Attendance,
    required this.contestAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mq.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Participent Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.045),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Id : ${studentId}',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student name : ${studentName}',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Status : ${isPaid}',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WorkShop Attendance: ${day1Attendance}  ${day2Attendance}',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contest Attendance : ${contestAttendance}',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            SizedBox(height: mq.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Only Contest Attendance: ${isContestOnly}',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
