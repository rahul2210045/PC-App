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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      setState(() {
        this.qrResult = qrCode.toString();
      });
      if (qrResult.isNotEmpty) {
        showSuccessSnackbar('QR code scanned successfully ');
      }
    } on PlatformException {
      // qrResult = 'Fail to read Qr Code';
      showErrorSnackbar('Failed to read QR code');
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
              LabeledCheckbox(
                label: 'Registration Payment',
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
              LabeledCheckbox(
                label: 'Workshop Attendance D1',
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
              LabeledCheckbox(
                label: 'WorkShop Attendance D2',
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
              LabeledCheckbox(
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


//////////////rahul save here all //////////////////////
//////////////////////done bro////////////////////////