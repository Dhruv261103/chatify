import 'dart:convert';
import 'dart:developer';

import 'package:chatify/models/chat_user.dart';
import 'package:chatify/screens/profile_screen.dart';
import 'package:chatify/widget/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //for storing all users
  List<ChatUser> _list=[];

  //for storing search users
  final List<ChatUser> _searchlist=[];

  //for storing search status
  bool _isSearching=false;

  @override
  void initState()
  {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    SystemChannels.lifecycle.setMessageHandler((message) {
      log(message!);

      if(APIs.auth.currentUser !=null)
        {
          if(message.toString().contains('resumed')) {APIs.updateActiveStatus(true);}
          if(message.toString().contains('paused')) {APIs.updateActiveStatus(false);}
        }

      return Future.value(message);
    });

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching)
            {
              setState(() {
                _isSearching =!_isSearching;
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
            title: _isSearching ? TextField(
              decoration: const InputDecoration(border: InputBorder.none,hintText: 'Name,Email..'),
              style: const TextStyle(fontSize:17,letterSpacing: 0.5),
              autofocus: true,
              onChanged: (value) {

                  _searchlist.clear();


                for(var i in _list)
                  {
                      if(i.name.toLowerCase().contains(value.toLowerCase()) || i.email.toLowerCase().contains(value.toLowerCase()) )
                        {
                          _searchlist.add(i);
                        }
                  }
                setState(() {
                  _searchlist;
                });
              },
            ) : const Text('Chatify'),
            leading: const Icon(CupertinoIcons.home),
            actions: [

              IconButton(onPressed: (){
                setState(() {
                  _searchlist.clear();
                  _isSearching =!_isSearching;
                });
              }, icon:  Icon( _isSearching ?  CupertinoIcons.clear_circled_solid:Icons.search)),


              IconButton(onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me)));
              }, icon: const Icon(Icons.more_vert)),

            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10,right: 10),
            child: FloatingActionButton(onPressed: () async{
              _addChatUserDialog();

            },child: const Icon(Icons.add_circle)),
          ),


          body: StreamBuilder(
            stream: APIs.getMyUserId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch(snapshot.connectionState)
              {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator(),);

                case ConnectionState.active:
                case ConnectionState.done:
                   return  StreamBuilder(

                    stream: APIs.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {

                      switch(snapshot.connectionState)
                      {
                        case ConnectionState.waiting:
                        case ConnectionState.none:

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data=snapshot.data?.docs;
                          _list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];

                          if(_list.isNotEmpty)
                          {
                            return ListView.builder(
                              padding: const EdgeInsets.only(top:4),
                              physics: const BouncingScrollPhysics(),
                              itemCount:  _isSearching ? _searchlist.length : _list.length,
                              itemBuilder:(context, index) {

                                // return Text('Name : ${list[index]}');
                                return  ChatUserCard(user: _isSearching ?_searchlist[index] :_list[index]);
                              },
                            );
                          }
                          else
                          {
                            return const Center(child: Text('No Connection Found',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300),),);
                          }
                      }
                    },
                  );
                }

                  return const Center(child: CircularProgressIndicator(strokeWidth: 2,),);
            },
          )

        ),
      ),
    );
  }
  void  _addChatUserDialog()
  {
    String email='';

    showDialog(context: context, builder: (_) {
      return  AlertDialog(
        contentPadding: EdgeInsets.only(left: 24,right: 24,top:20,bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person,color: Colors.blue,size: 28,),
            Text('Add User'),
          ],
        ),

        content: TextFormField(
          onChanged: (value) => email=value,
          maxLines: null,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email,color: Colors.blue,),
            hintText: 'Add User Email...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)))
          ,),

        actions: [
          MaterialButton(onPressed: (){
            Navigator.pop(context);
          } ,child: Text('Cancle' ,style: TextStyle(color: Colors.blue,fontSize: 16),),),
          MaterialButton(onPressed: () async{
            if(email.isNotEmpty)
              {
                await APIs.addChatUser(email).then((value){
                  if(!value)
                    {
                      Dialogs.showSnackbar(context, 'User does not Exit ');
                    }
                });
              }
            Navigator.pop(context);

            // APIs.updateMessage(widget.message, updateMessage);
          } ,child: Text('Add' ,style: TextStyle(color: Colors.blue,fontSize: 16),),),
        ],

      );
    },);
  }

}
