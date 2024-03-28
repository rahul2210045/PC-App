import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pc_app/views/screens/homeScreen/home_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrViewExample extends StatefulWidget {
  const QrViewExample({super.key});

  @override
  State<QrViewExample> createState() => _QrViewExampleState();
}

class _QrViewExampleState extends State<QrViewExample> {
  String qrResult = 'Scanned Data will appear here';
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

  @override
  Widget build(BuildContext context) {
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
            ElevatedButton(onPressed: scanQR, child: Text('Scan Code'))
          ],
        ),
      ),
    );
  }
}
