import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app/pages/chatting_page.dart';
import 'package:chat_app/services/authentication/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //instance of the auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  late String speech = '';
  bool _isListening = false;
  //logout user
  void logout() {
    //get auth service
    final _authService = Provider.of<AuthService>(context, listen: false);
    _authService.logout();
  }

  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize(
      onStatus: (status) {
        if (status.toString() == "notListening") {
          flutterTts.speak("Not Listening ...");
        }
      },
    );
    setState(() {});
  }

  Future<void> startListening() async {
    _isListening = true;
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    _isListening = !_isListening;
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) async {
    // setState(() {
    speech = result.recognizedWords;
    // });
    if (speech.contains("logout")) {
      await flutterTts.speak("Logging out ...");
      await Future.delayed(const Duration(seconds: 2));
      logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          //logout button
          IconButton(onPressed: logout, icon: const Icon(Icons.logout_rounded))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.red,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        endRadius: 75.0,
        child: FloatingActionButton(
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              await stopListening();
              print(speech);
            } else {
              initSpeechToText();
            }
          },
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: _buildUserList(),
    );
  }

  // build a list of users except the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!_isListening) {
          if (snapshot.hasError) {
            return const Text("Something went wrong ...");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading ...");
          }
        }
        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  //build individual user list
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    //display all users except current user
    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChattingPage(
                        endUserEmail: data['email'],
                        endUserId: data['uid'],
                      )));
        },
      );
    } else {
      return Container();
    }
  }
}
