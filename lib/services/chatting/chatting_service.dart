import 'dart:io';
import 'dart:math';
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
      image: "",
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

  //upload image
  Future<void> uploadImageOnMobile(
      String filePath, String fileName, String userId, String endUserId) async {
    List<String> chatroom = [userId, endUserId];
    chatroom.sort();
    String chatroomId = chatroom.join("-");
    print(chatroomId);
    File file = File(filePath);
    try {
      await _firebaseStorage.ref('images/$chatroomId/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  //upload voice message
  Future<void> uploadVoiceMessage(
      String filePath, String fileName, String userId, String endUserId) async {
    List<String> chatroom = [userId, endUserId];
    chatroom.sort();
    String chatroomid = chatroom.join("-");
    print(chatroomid);
    String metadata = "audio/mpeg";
    File file = File(filePath);
    try {
      await _firebaseStorage
          .ref('voices/$chatroomid/$fileName.mp3')
          .putFile(file, SettableMetadata(contentType: metadata));
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> uploadImageOnWeb(dynamic fileBytes, String fileName,
      String userId, String endUserId) async {
    List<String> chatroom = [userId, endUserId];
    chatroom.sort();
    String chatroomId = chatroom.join("-");

    try {
      await _firebaseStorage
          .ref('images/$chatroomId/$fileName')
          .putData(fileBytes);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  List<ChatImage> downloadURLs = [];

  Future<String> getImageDownloadURL(String userId, String endUserId) async {
    List<String> chatroom = [userId, endUserId];
    chatroom.sort();
    String chatroomId = chatroom.join("-");
    print(chatroomId);
    try {
      final listRef = _firebaseStorage.ref('images/$chatroomId/');
      final res = await listRef.listAll();

      await Future.forEach(res.items, (itemRef) async {
        final downloadURL = await itemRef.getDownloadURL();
        final metadata = await itemRef.getMetadata();
        final created = metadata.timeCreated;

        final chatImage = ChatImage(downloadURL: downloadURL, created: created);
        downloadURLs.add(chatImage);
      });

      // Sort the download URLs based on creation date in descending order
      downloadURLs.sort((a, b) => a.created!.compareTo(b.created!));
    } catch (e) {
      print(e);
    }

    if (downloadURLs.length == 1) {
      return downloadURLs.first.downloadURL;
    } else {
      return downloadURLs.last.downloadURL;
    }
  }

  Future<void> getImages(String endUserId, String downloadUrl) async {
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
      message: "",
      image: downloadUrl,
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
}

class ChatImage {
  String downloadURL;
  DateTime? created;

  ChatImage({required this.downloadURL, required this.created});
}
