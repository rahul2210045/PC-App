import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pc_app/main.dart';
import 'package:pc_app/views/screens/auth/login_screen.dart';
import 'package:pc_app/views/screens/homeScreen/home_page.dart';

import '../../services/storage.dart';
import '../../services/verify_access_token.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorage secureStorage = SecureStorage();

  Future<String> fetchAccessToken(String refreshTokenFromSecureStorage) async {
    final url = Uri.parse('https://pc.anaskhan.site/api/get_access_token?refresh_token=$refreshTokenFromSecureStorage');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final access = responseBody['access_token'];
      print('Access Token: ${response.body}');
      return access;
    } else {
      print('Failed to fetch access token. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return "";
    }
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () async{
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.transparent));


      String? accessToken = await secureStorage.readSecureData('accessToken');
      String? refreshToken = await secureStorage.readSecureData('refreshToken');
      print("--------------------------------------------------------------------------------------------------");
      print(accessToken);
      print("--------------------------------------------------------------------------------------------------");
      print(refreshToken);
      print("--------------------------------------------------------------------------------------------------");
      bool verify = await verifyAccessToken(accessToken);
      if(accessToken == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
      else if (verify) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
      else {
        String accessTokenFromRefreshToken = await fetchAccessToken(refreshToken!);
        if(accessTokenFromRefreshToken == "") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
        else {
          secureStorage.writeSecureData('accessToken', accessTokenFromRefreshToken);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
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
              child: Image.asset(
                "assets/icons/pc_icon.png",
                scale: 2,
              )),
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
