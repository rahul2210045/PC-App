import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pc_app/main.dart';
import 'package:pc_app/views/screens/auth/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome To Programming Club"),
        backgroundColor: Colors.red.shade100,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * 0.15,
              right: mq.width * 0.25,
              width: mq.width * .5,
              child: Image.asset("assets/icons/chat.png")),
          Positioned(
              bottom: mq.height * .15,
              height: mq.height * 0.06,
              left: mq.width * 0.05,
              width: mq.width * .9,
              child: const Text(
                'MADE BY PC WITH ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: .5),
              )),
        ],
      ),
    );
  }
}
