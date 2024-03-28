import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pc_app/views/screens/qrScaning.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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

      //floating button to scan Qr
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.red.shade200,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const QrViewExample()));
          },
          child: Icon(Icons.qr_code_scanner_rounded),
        ),
      ),
    );
  }
}
