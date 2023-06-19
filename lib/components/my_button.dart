import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String buttonText;
  const MyButton({super.key, this.onTap, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: 40, vertical: 16), // Button padding
        textStyle: const TextStyle(fontSize: 20), // Text style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Button border radius
        ));
    return ElevatedButton(
      onPressed: onTap,
      style: style,
      child: Text(buttonText),
    );
  }
}
