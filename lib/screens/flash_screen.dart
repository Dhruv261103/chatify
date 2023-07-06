import 'dart:developer';

import 'package:chatify/screens/auth/Login_Screen.dart';
import 'package:chatify/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../api/apis.dart';

class flashscreen extends StatefulWidget {
  const flashscreen({super.key});

  @override
  State<flashscreen> createState() => _flashscreenState();
}

class _flashscreenState extends State<flashscreen> {


  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2),() {

      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white,systemNavigationBarColor: Colors.white));

      if(APIs.auth.currentUser !=null)
        {
          log('\n User:${APIs.auth.currentUser}');
          //navigator to home screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(),));
        }
      else {
        //navigator to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const loginScreen(),));
      }
    },);
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Positioned(
            top:mq.height*.15,
            width: mq.width*.5,
            right: mq.width*.25,
            child: Image.asset('assets/images/applogo.png')),
        Positioned(
            bottom: mq.height*.15,
            width: mq.width,
          child: Text('MADE IN INDIA WITH ♥',textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
              color: Colors.black87,
            letterSpacing: 3
          ),),
            )
      ],),

    );
  }
}
