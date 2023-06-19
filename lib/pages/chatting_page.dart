import 'dart:html';

import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/login_textfield.dart';
import 'package:chat_app/services/chatting/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChattingPage extends StatefulWidget {
  final String endUserEmail;
  final String endUserId;
  const ChattingPage(
      {super.key, required this.endUserEmail, required this.endUserId});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChattingService _chattingService = ChattingService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chattingService.sendMessage(
          widget.endUserId, _messageController.text);
      //clear the controller
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.endUserEmail),
        ),
        //messages
        body: Column(
          children: [
            Expanded(
              child: _displayMessageList(),
            ),
            _writeMessageInput(),
          ],
        ));
    //user input
  }

  //display message list
  Widget _displayMessageList() {
    return StreamBuilder(
      stream: _chattingService.getMessages(
          widget.endUserId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading ...");
        }
        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the end user messages to left and send user message to the right
    var align = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? MainAxisAlignment.end
          :MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            ChatBubble(message: data['message'])
          ],
        ),
      ),
    );
  }

  //write message input
  Widget _writeMessageInput() {
    return Row(
      children: [
        Expanded(
          child: LoginTextfield(
            controller: _messageController,
            hintText: "Write a message ...",
            obscureText: false,
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(Icons.send),
          iconSize: 40,
        ),
      ],
    );
  }
}
