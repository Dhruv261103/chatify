import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'auth/Login_Screen.dart';

class ProfileScreen extends StatefulWidget {

  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  final _formkey=GlobalKey<FormState>();

  String ? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chatify'),
        ),
        
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10,right: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent.withOpacity(0.9),

            onPressed: () async{

              //for showing progress dialogs
              Dialogs.showProgressbar(context);

              await APIs.updateActiveStatus(false);

              //signout from app
            await APIs.auth.signOut().then((value) async{
              await GoogleSignIn().signOut().then((value) {

                //for remove profile Screen to the stack
                Navigator.pop(context);

                //for remove home screen to the stack
                Navigator.pop(context);

                APIs.auth=FirebaseAuth.instance;

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const loginScreen()));
              });
            });

          },icon: Icon(Icons.logout),
            label: Text('Logout'),
          ),
        ),


        body:Form(
          key: _formkey,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: mq.width*.05),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(width: mq.width,height: mq.height*.03,),
                  Stack(
                    children: [

                      _image!=null ?
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height*.1),

                          child: Image.file(
                            File(_image!),
                              width: mq.width*.45,
                              height: mq.height*.2,
                              fit: BoxFit.cover,
                          ),

                        ):
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height*.1),
                          child: CachedNetworkImage(
                            width: mq.width*.45,
                            height: mq.height*.2,
                            fit: BoxFit.fill,
                            imageUrl: widget.user.image,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0 ,
                        child: MaterialButton(onPressed: (){

                          _showBottomSheet();
                        },
                          color: Colors.white,
                          elevation: 1,
                          shape: CircleBorder(),
                          child: Icon(Icons.edit,color: Colors.blue,),),
                      )
                    ],
                  ),
                  SizedBox(height: mq.height*.03,),
                  Text(widget.user.email,style: TextStyle(color: Colors.black54,fontSize: 16),),
                  SizedBox(height: mq.height*.05,),

                  //Name Input
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (newValue) => APIs.me.name=newValue!,
                    validator: (value) => value!=null && value.isNotEmpty ? null:'Required Filed',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Eg.Dhruv Tanti',
                      prefixIcon: Icon(Icons.person,color: Colors.blue,),
                      label: Text('Name',)

                    ),
                  ),
                  SizedBox(height: mq.height*.02,),

                  //About Input
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (newValue) => APIs.me.about=newValue!,
                    validator: (value) => value!=null && value.isNotEmpty ? null:'Required Filed',
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: 'Eg. You Are Using Chatify ',
                        prefixIcon: Icon(Icons.info_outline,color: Colors.blue,),
                        label: Text('About')

                    ),
                  ),
                  SizedBox(height: mq.height*.05,),

                  //Update Profile Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(mq.width*.5, mq.height*.06)
                    ),
                    onPressed: (){

                      if(_formkey.currentState!.validate())
                        {
                          _formkey.currentState!.save();
                          APIs.updateUserinfo();
                          Dialogs.showSnackbar(context, 'Profile Update Successfully');
                              // log('inside validator');
                        }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('UPDATE',style: TextStyle(fontSize: 16),),),

                ],
              ),
            ),
          ),
        )

      ),
    );
  }

  void _showBottomSheet()
  {
    showModalBottomSheet(context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        builder: (_){
          return ListView(
            padding: EdgeInsets.only(top: mq.height*.03,bottom: mq.width*.05),
            shrinkWrap: true,
            children: [
              Text('Pick Profile Picture',textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: CircleBorder(),
                      fixedSize: Size(mq.width*.3, mq.height*.15)
                    ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if(image!=null)
                          {
                            log('Image Path : ${image.path}  --MineType : ${image.mimeType}');
                            setState(() {
                              _image=image.path;
                            });

                            APIs.updateProfilePic(File(_image!));

                            //for hidding bottom sheet
                            Navigator.pop(context);
                          }
                      },
                      child: Image.asset('assets/images/image.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width*.3, mq.height*.15)
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);
                        if(image!=null)
                        {
                          log('Image Path : ${image.path}  --MineType : ${image.mimeType}');
                          setState(() {
                            _image=image.path;
                          });

                          APIs.updateProfilePic(File(_image!));


                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
