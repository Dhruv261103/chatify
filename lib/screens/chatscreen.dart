import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/models/chat_user.dart';
import 'package:chatify/screens/auth/view_profile_screen.dart';
import 'package:chatify/widget/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/message.dart';
import 'dart:io';
class ChatScreen extends StatefulWidget {

  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  //for storing all messages
  List<Message> _list=[];

  //for handling message
  final _textsend=TextEditingController();
  bool _showemojis=false,_isload=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(

          onWillPop: () {
            if(_showemojis)
            {
              setState(() {
                _showemojis =!_showemojis;
              });
              return Future.value(false);
            }
            else
            {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(

                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {

                      switch(snapshot.connectionState)
                      {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: CircularProgressIndicator(),);

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data=snapshot.data?.docs;
                          _list=data?.map((e) => Message.fromJson(e.data())).toList()??[];

                          if(_list.isNotEmpty)
                          {
                            return ListView.builder(

                              padding: const EdgeInsets.only(top:4),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              reverse:true,
                              itemBuilder:(context, index) {

                                // return Text('Name : ${_list[index]}');
                                return MessageCard(message: _list[index],);
                              },
                            );
                          }
                          else
                          {
                            return const Center(child: Text('Say Hii! 🤝',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300),),);
                          }
                      }
                    },
                  ),
                ),
                if(_isload)
                Align(
                  alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )),
                _chatInput(),


                //for showing emojis
                if(_showemojis)
                SizedBox(
                  height: mq.height*.35,
                  child: EmojiPicker(
                    textEditingController: _textsend,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 234, 248, 255),
                      columns: 7,
                      emojiSizeMax: 32*(Platform.isIOS ? 1.30 : 1.0)
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar()
  {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => viewProfileScreen(user: widget.user,),));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {

          final data=snapshot.data?.docs;
          final list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];


        return Row(
          children: [
            IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back,color: Colors.black54,)),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CachedNetworkImage(
                height: mq.height*0.055,
                imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),
            SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(list.isNotEmpty ? list[0].name:widget.user.name,style: TextStyle(fontSize: 16,color: Colors.black87,fontWeight: FontWeight.w500),),
                SizedBox(height: 2,),
                Text(list.isNotEmpty ? list[0].isOnline ? 'Online' : MyDateUtil.lastActiveTime(context: context, lastActive: list[0].lastActive) : MyDateUtil.lastActiveTime(context: context, lastActive: widget.user.lastActive),style: TextStyle(fontSize: 13,color: Colors.black54),)
              ],)
          ],
        );
      },)
    );
  }

  Widget _chatInput()
  {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height*.01,horizontal: mq.width*.025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(onPressed: (){

                    setState(() {
                      FocusScope.of(context).unfocus();
                      _showemojis=!_showemojis;
                    });

                  }, icon: Icon(Icons.emoji_emotions,color: Colors.blueAccent,)),
                  Expanded(child: TextField(
                    controller: _textsend,
                    keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: (){
                      if(_showemojis) {
                        setState(() {
                          _showemojis=!_showemojis;
                        });
                      }
                      },
                      decoration: InputDecoration(
                          hintText: 'Type Something....',
                          hintStyle: TextStyle(color: Colors.blueAccent.shade100),
                          border: InputBorder.none
                      ))),
                  IconButton(onPressed: () async{
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);

                    for(var i in images)
                      {
                        log('Image Path : ${i.path}  --MineType : ${i.mimeType}');
                        setState(() {
                          _isload =true;
                        });
                        await APIs.sendChatImage(widget.user,File(i.path));
                        setState(() {
                          _isload=false;
                        });
                      }

                  }, icon: Icon(Icons.image,color: Colors.blueAccent,size: 26,)),
                  IconButton(onPressed: () async {

                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);

                        if(image!=null) {
                          log('Image Path : ${image.path}  --MineType : ${image.mimeType}');
                          setState(() {
                            _isload=true;
                          });
                          await APIs.sendChatImage(widget.user,File(image.path));
                          setState(() {
                            _isload=false;
                          });
                        }

                  }, icon: Icon(Icons.camera_alt_rounded,color: Colors.blueAccent,size: 26,)),
                ],
              ),
            ),
          ),
          MaterialButton(onPressed: (){
            if(_textsend.text.isNotEmpty)
              {

                if(_list.isEmpty)
                  {
                    //on first message (add user to my_user collection of chat user)
                    APIs.sendFirstMessage(widget.user, _textsend.text,Type.text);
                  }
                else {
                  //simply send messege
                  APIs.sendMessage(widget.user, _textsend.text, Type.text);
                }

                _textsend.text = '';
              }
          } ,
            shape: CircleBorder(),
            minWidth: 0,
            padding: EdgeInsets.only(top:10,bottom: 10,left: 10,right: 5),
            color: Colors.green,
            child: Icon(Icons.send,color: Colors.white,size: 28,),),
        ],
      ),
    );
  }
}
