import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatify/helper/my_date_util.dart';
import 'package:chatify/screens/chatscreen.dart';
import 'package:chatify/widget/dialogs/profile_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatUserCard extends StatefulWidget {

  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  //last message info(if null --->no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*.03,vertical: 4),
      elevation: 1 ,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder: (_)=> ChatScreen(user: widget.user,)));
        },
        child:  StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {

            final data=snapshot.data?.docs;
            final list=data?.map((e) => Message.fromJson(e.data())).toList()??[];

            if(list.isNotEmpty)
              _message=list[0];

            return ListTile(
              // leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
              leading:  InkWell(
                onTap: (){
                  showDialog(context: context, builder: (context) => ProfileDialogs(user: widget.user,),);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    height: mq.height*.055,
                    fit: BoxFit.cover,
                    width: mq.width*.12,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
              ),
              title: Text(widget.user.name),

              //last message
              subtitle: Text(_message==null
                  ? widget.user.about:
                  _message!.type==Type.image?
                      'image':
              _message!.msg,maxLines: 1,),
              // trailing: Text('12:00 PM',style: TextStyle(color: Colors.black54),),

              //last message status
              trailing:_message ==null ? null // show nothing when no message is sent
                  : _message!.read.isEmpty && _message!.fromId!=APIs.user.uid
                  ?
                  //show for unread message
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(10)
                ),
                //message sent time
              ):Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),style: TextStyle(color: Colors.black54),),
            );
          },
        )
      ),);
  }
}
