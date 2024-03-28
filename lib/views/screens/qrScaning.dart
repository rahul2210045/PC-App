import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pc_app/main.dart';
import 'package:pc_app/models/qr_scann_model.dart';
import 'package:pc_app/repository/qr_scann_repo.dart';
import 'package:pc_app/views/screens/homeScreen/home_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class QrViewExample extends StatefulWidget {
  const QrViewExample({super.key});

  @override
  State<QrViewExample> createState() => _QrViewExampleState();
}

class _QrViewExampleState extends State<QrViewExample> {
  String qrResult = 'Scanned Data will appear here';
  bool _isLoading = false;
  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;
      setState(() {
        this.qrResult = qrCode.toString();
      });
    } on PlatformException {
      qrResult = 'Fail to read Qr Code';
    }
  }
  // calling function for QR Fetch Api

  //  final QrFetchDataRepository _repository = QrFetchDataRepository();
  // List<QrScannModel>? _QrFetchData;

  // @override
  // void initState() {
  //   super.initState();
  //   _fetchQrInfoData();
  // }

//.............calling Qr Fetch Data repository ...................................//
  // Future<void> _fetchQrInfoData() async {
  //   List<QrScannModel>? attendanceDataList =
  //       await _repository.FetchQrData();

  // }

  Future<void> _savePayment() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.https('pc.anaskhan.site', '/api/make_payment');

    final Map<String, String> requestBody = {'qr_data': '${qrResult}'};
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

  Future<void> _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.https('pc.anaskhan.site', '/api/mark_attendance');

    final Map<String, String> requestBody = {'qr_data': '${qrResult}'};
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

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
            },
            icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text("QR Code Scanner"),
        elevation: 1,
        backgroundColor: Colors.red.shade100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              "$qrResult",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: scanQR, child: Text('Scan Code')),
            SizedBox(
              height: mq.height * .06,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                    onPressed: _savePayment, child: Text('Mark Payment')),
                ElevatedButton(
                    onPressed: _markAttendance, child: Text('Mark Attendance')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
