import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String endUserId;
  final String message;
  final Timestamp time;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.endUserId,
    required this.message,
    required this.time,
  });

  //convert datatype to map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'endUserId': endUserId,
      'message': message,
      'timestamp': time,
    };
  }
}
