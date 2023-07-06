import 'dart:developer';
import 'dart:io';

import 'package:chatify/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {

  bool _isanimate=false;

  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(milliseconds: 1500),() {
      setState(() {
        _isanimate=true;
      });
    },);
  }


  _handelGoogleBtnClick(){

    //for showing progressbar
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user) async {

      //for hiding progressbar
      Navigator.pop(context);
      if(user!=null)
        {
          log('\nUser : ${user.user}');
          log('\nUserAdditionalInformation : ${user.additionalUserInfo}');


          if((await APIs.userExits()))
            {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
            }
          else
            {
              await APIs.createUser().then((value){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen(),));
              });
            }


        }

    });
  }

  Future<UserCredential ?> _signInWithGoogle() async {

    try{

      await InternetAddress.lookup('google.com');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(e)
    {
        log('\n_signInWithGoogle : $e');
        Dialogs.showSnackbar(context,'Something went wrong (check internet)!');
        return null;
    }

  }

  //sign out function
  // _signOut() async{
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }


  @override
  Widget build(BuildContext context) {
    // mq=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Chatify'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(children: [
          AnimatedPositioned(
              top:mq.height*.15,
              width: mq.width*.5,
              right: _isanimate ? mq.width*.25: -mq.width*.5,
              duration: const Duration(seconds: 1),
              child: Image.asset('assets/images/applogo.png')),
        Positioned(
          bottom: mq.height*.15,
            height: mq.height*.07,
            left: mq.width*.05,
            width: mq.width*.9,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 218, 127).withOpacity(0.9),
                  shape: StadiumBorder(),
                  elevation: 1,
                ),
                onPressed: (){
                  _handelGoogleBtnClick();
                },
                icon: Image.asset('assets/images/googleicon.png',height: mq.height*.05,),
                label: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Color.fromARGB(37,37,53,109).withOpacity(0.9),fontSize: 16),
                    children: [
                      TextSpan(text: 'Log In With '),
                      TextSpan(text: 'Google',style: TextStyle(fontWeight: FontWeight.w500))
                    ]
                  ),
                )))
      ],),

    );
  }
}
