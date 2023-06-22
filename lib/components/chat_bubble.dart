import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  String? message;
  String? image;
  Color chatBubbleColor;
  bool isImage;
  ChatBubble({
    super.key,
    this.message,
    this.image,
    required this.isImage,
    required this.chatBubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: chatBubbleColor,
      ),
      child: isImage
          ? SizedBox(
              child: Image.network(
                image!,
                fit: BoxFit.cover,
              ),
            )
          : Text(
              message!,
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}
