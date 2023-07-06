

import 'dart:convert';
import 'dart:developer';

import 'package:chatify/models/chat_user.dart';
import 'package:chatify/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:http/http.dart';

class APIs{

  //for authentication
  static FirebaseAuth auth=FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore=FirebaseFirestore.instance;

  //to return current user
  static User get user=>auth.currentUser!;

  //for storing current user information
  static late ChatUser me;

  //for accessing firebase storage
  static FirebaseStorage storage=FirebaseStorage.instance;

  //for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase message token
  static Future<void> getFirebaseMessagingToken() async
  {
      await fMessaging.requestPermission();

      await fMessaging.getToken().then((t) {
        if(t!=null)
          {
            me.pushToken=t;
            log('Push Token : $t');
          }
      });
  }

  //for checking user is exit or not
  static Future<bool> userExits() async
  {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for adding chat user for our conversation
  static Future<bool> addChatUser(String email) async
  {
    final data= await firestore.collection('users').where('email' , isEqualTo: email).get();

    if(data.docs.isNotEmpty  && data.docs.first.id !=user.uid)
      {
        
        firestore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id).set({});

        //user exit
        return true;
      }
    else
      {

        // user doesn't exit
        return false;
      }

  }

  //for push notification
  static Future<void> pushNotification(ChatUser chatuser,String msg)async
  {

    try{
      final body=
      {
        "to":chatuser.pushToken,
        "notification":{
          "title":me.name,
          "body":msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data" : "User ID : ${me.id}",
        },
      };

      var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader:'application/json',
            HttpHeaders.authorizationHeader:'key=AAAA0sVjVpM:APA91bFpML-clENnfLYQNdEMICz5z8zdTbCiiNl69LhBI6zZBSzy0nOdIA-yu4dlJtVloHdpjwldOduC64tDP5BbXJJIyfQjJeic9uNHQMaeY6KKqJ8_SlgmPesfLQEKXNvula8nD-ci'
          },
          body: jsonEncode(body));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    }catch(e)
    {
      log('pushNotifiaction related : $e');
    }
  }


  //for accessing self information
  static Future<void> getSelfInfo() async
  {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
        if(user.exists)
          {
            me=ChatUser.fromJson(user.data()!);
            getFirebaseMessagingToken();
            //for setting user status to active
            await APIs.updateActiveStatus(true);
          }
        else
          {
            await createUser().then((value) => getSelfInfo());
          }
    });
  }

  //for create new user
  static Future<void> createUser() async
  {

    final time=DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser=ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I'm Using Chatify",
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        id: user.uid,
        email: user.email.toString(),
        pushToken: ''
    );

    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }


  //for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId()
  {
    return firestore.collection('users').doc(user.uid).collection('my_users').snapshots();
  }


  //for getting all user except our self from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds)
  {
    return firestore.collection('users').where('id',whereIn: userIds).snapshots();
  }

  //for adding an user to my_user when first message is send
  static Future<void> sendFirstMessage(ChatUser chatUser,String msg,Type type) async
  {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //for update user information
  static Future<void> updateUserinfo() async
  {
     await firestore.collection('users').doc(user.uid).update({'name': me.name,'about':me.about});
  }


  //update profile picture
  static Future<void> updateProfilePic(File file)async
  {

    //getting image file extension
    final ext=file.path.split('.').last;
    log('Extension : $ext');

    //storage file ref with path
    final ref=storage.ref().child('profile_picture/${user.uid}.$ext');

    //uploading image
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext'))
        .then((p0){
          log('Data Transferred : ${p0.bytesTransferred / 1000} kb');
    });

    //uploading image in firebase database
    me.image=await ref.getDownloadURL();

    await firestore.collection('users').doc(user.uid).update({'image' : me.image});

  }

  //for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatuser)
  {
    return firestore.collection('users').where('id',isEqualTo: chatuser.id).snapshots();
  }

  //update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline)async
  {
    firestore.collection('users').doc(user.uid).update({
      'is_online':isOnline ,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token' :me.pushToken
    });
  }

  // ***************************************ChatScreen Related API*********************************************//


  //chats(collection) -->conversation_id(doc) -->messages(collection)-->message(doc)


  //useful for getting conversation id
  static String getConversationId(String id) =>user.uid.hashCode <= id.hashCode
      ?'${user.uid}_$id' : '${id}_${user.uid}';


  //for getting all messages of specific conversation from firebase database
    static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user)
    {
      return firestore.collection('chats/${getConversationId(user.id)}/messages/')
          .orderBy('sent',descending: true).snapshots();
    }

  //for sending message
  static Future<void> sendMessage(ChatUser chatUser,String msg,Type type) async{

      //message sending time(also use as id)
      final time=DateTime.now().millisecondsSinceEpoch.toString();

      //message to send
      final Message message=Message(toId: chatUser.id, msg: msg, read: '', type:type, sent: time, fromId: user.uid);
      // final Message message=Message(toId: chatUser.id, msg: msg, read: '', sent: time, fromId: user.uid);

    final ref=firestore.collection('chats/${getConversationId(chatUser.id)}/messages/');
      await ref.doc(time).set(message.toJson()).then((value) => pushNotification(chatUser,type==Type.text ? msg : 'Image'));

  }

  //update read statue of message
  static Future<void> updateMessageReadStatus(Message message) async
  {
    firestore.collection('chats/${getConversationId(message.fromId)}/messages/').doc(message.sent)
    .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //delete  message
  static Future<void> deleteMessage(Message message) async
  {
    await firestore.collection('chats/${getConversationId(message.toId)}/messages/').doc(message.sent).delete();

    if(message.type==Type.image)
      {
        await storage.refFromURL(message.msg).delete();
      }

  }

  static Future<void> updateMessage(Message message,String mess) async
  {
    await firestore.collection('chats/${getConversationId(message.toId)}/messages/').doc(message.sent).update({'msg' : mess});

  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user)
  {
    return firestore.collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatuser,File file) async
  {
    //getting image file extension
    final ext=file.path.split('.').last;

    //storage file ref with path
    final ref=storage.ref().child('images/${getConversationId(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext'))
        .then((p0){
      log('Data Transferred : ${p0.bytesTransferred / 1000} kb');
    });

    //uploading image in firebase database
    final imageurl=await ref.getDownloadURL();
    await sendMessage(chatuser, imageurl, Type.image);
  }

}