import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';

class viewProfileScreen extends StatefulWidget {

  final ChatUser user;

  const viewProfileScreen({super.key, required this.user});

  @override
  State<viewProfileScreen> createState() => _viewProfileScreenState();
}

class _viewProfileScreenState extends State<viewProfileScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Joined On : ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 16),),
          Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),style: TextStyle(color: Colors.black54,fontSize: 16),),
        ],
      ),

      body:Padding(
        padding:  EdgeInsets.symmetric(horizontal: mq.width*.05),
        child: Column(
          children: [
            SizedBox(width: mq.width,height: mq.height*.03,),
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
            SizedBox(height: mq.height*.03,),
            Text(widget.user.email,style: TextStyle(color: Colors.black54,fontSize: 16),),
            SizedBox(height: mq.height*.03,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('About : ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500,fontSize: 16),),
                Text(widget.user.about,style: TextStyle(color: Colors.black54,fontSize: 16),),
              ],
            ),


          ],
        ),
      )

    );
  }

}
