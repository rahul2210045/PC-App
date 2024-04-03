import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pc_app/constants/constants.dart';
import 'package:pc_app/main.dart';
import 'package:pc_app/views/screens/homeScreen/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _userController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

// ........function to intigrate login api .....................
  Future<void> _saveItem() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.https('pc.anaskhan.site', '/api/login');

    final Map<String, String> requestBody = {
      'password': _passwordController.text,
      'username': _userController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        dynamic responseBody = json.decode(response.body);
        String? accessToken = responseBody['access_token'];
        print('Access Token: $accessToken');
        String? refreshToken = responseBody['refresh_token'];
        print('refresh Token: $refreshToken');
        String? name = responseBody['username'];
        print('username: $name');
        PreferencesManager().name = name!;
        PreferencesManager().token = accessToken!;
        PreferencesManager().refreshToken = refreshToken!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade500,
            content: Text("#PC Member"),
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
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

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome To Programming Club"),
        elevation: 1,
        backgroundColor: Colors.red.shade100,
      ),
      backgroundColor: backgroundColor,
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
              Image.asset(
                "assets/icons/pc_icon.png",
                scale: 2,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: mq.height * 0.06,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        textAlign: TextAlign.left,
                        "User Name",
                        style: GoogleFonts.dmSans(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                        hintText: "PcMember@24",
                        hintStyle: GoogleFonts.dmSans(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          // borderSide: BorderSide(color: HexColor("#EBEBF9")),
                          borderSide: BorderSide(color: Colors.red.shade100),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mq.height * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Password",
                        style: GoogleFonts.dmSans(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: (){
                            setState(() {
                              _obscureText= !_obscureText;
                            }
                            );
                          },
                          child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                        hintText: "Password",
                        hintStyle: GoogleFonts.dmSans(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: HexColor("#EBEBF9")),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mq.height * 0.07,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: mq.height * 0.065,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade100,
                                shape: const StadiumBorder(),
                                elevation: 1),
                            onPressed: () async {
                              await _saveItem();
                            },
                            icon: Image.asset(
                              'assets/icons/profile.png',
                              height: mq.height * .03,
                            ),
                            label: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    children: [
                                  TextSpan(text: 'Sign In '),
                                  TextSpan(
                                      text: 'PC Members',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))
                                ])),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      strokeWidth: 5.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
