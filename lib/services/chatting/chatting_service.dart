import 'dart:io';

import 'package:chat_app/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChattingService extends ChangeNotifier {
  //get instance of auth and the firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //Send message
  Future<void> sendMessage(String endUserId, String message) async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    //create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      endUserId: endUserId,
      time: timestamp,
      message: message,
    );
    //construct chat room id from current user id and receiver id (sorted to uniqueness)
    List<String> chatroom = [currentUserId, endUserId];
    chatroom
        .sort(); //this ensures that chatroom id is always the same for any pair of users
    String chatroomId = chatroom
        .join("-"); //combine the two chatroom id into one as a unique chatroom
    //add new message to the db
    await _firestore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessages(String userId, String endUserId) {
    //construct chat room id from user ids (sorted to ensure it matches the id used when sending the message prior)
    List<String> chatroom = [userId, endUserId];
    chatroom.sort();
    String chatroomId = chatroom.join("-");

    return _firestore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  bool isAndroid() {
    if (kIsWeb) {
      // Running on the web
      return false;
    } else {
      // Running on Android
      return true;
    }
  }

  //upload image
  Future<void> uploadFileOnMobile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await _firebaseStorage.ref('images/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> uploadFileOnWeb(dynamic fileBytes, String fileName) async {
    try {
      await _firebaseStorage.ref('images/$fileName').putData(fileBytes);
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
