import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/screens/auth/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/chat_user.dart';
class ProfileDialogs extends StatelessWidget {
  final ChatUser user;

  const ProfileDialogs({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: IconButton(icon: Icon(Icons.info_outline,size: 26,), onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => viewProfileScreen(user: user),));},),
      content: SizedBox(
        height: mq.height*.30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(mq.width*.25),
              child: CachedNetworkImage(
                imageUrl: user.image,
                // height: mq.height*.055,
                fit: BoxFit.cover,
                width: mq.width*.5,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),
            SizedBox(height: mq.height*.02,),
            Text(user.name,style: TextStyle(fontSize: 25,fontWeight: FontWeight.w300),),
          ],
        ),
      ),
    );
  }
}
