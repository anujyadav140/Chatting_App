import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGPT {
  final String user;
  final String content;
  final Timestamp time;

  ChatGPT({
    required this.user,
    required this.content,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'content': content,
      'timestamp': time,
    };
  }
}
