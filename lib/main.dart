import 'package:chat_app/components/voice_message.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/authentication/auth_gate.dart';
import 'package:chat_app/services/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthGate(),
      // home: const VoiceMessage(
      //   voiceUrl:
      //       'https://firebasestorage.googleapis.com/v0/b/chatting-app-cf41d.appspot.com/o/voices%2FFDBiGbllT9Y2ZKdBLvFCvlmrXWm2-jXD0BKuG8xeNMEPC0jYfi38rC483%2FjXD0BKuG8xeNMEPC0jYfi38rC483_137556.mp3?alt=media&token=823475db-809b-482f-8bcd-5f337a23389e.mp3',
      // ),
    );
  }
}
