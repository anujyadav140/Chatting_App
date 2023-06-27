// import 'dart:html';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/services/chatting/chatting_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode(); // New FocusNode
  final SpeechToText speechToText = SpeechToText();
  late String speech = '';
  FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  bool isImage = false;
  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
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
    _messageFocusNode.requestFocus();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      speech = result.recognizedWords;
      _messageController.text = speech;
    });
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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chattingService.sendMessage(
          widget.endUserId, _messageController.text);
      //clear the controller
      _messageController.clear();
      _messageFocusNode.requestFocus();
      // Scroll to the bottom when a new message is sent
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    // _speech = stt.SpeechToText();
    String chatroomId = "${widget.endUserId}-${_firebaseAuth.currentUser!.uid}";
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.endUserEmail),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              onPressed: () async {
                var result = await flutterTts.speak("Hello World");
              },
              icon: const Icon(Icons.settings),
            ),
            IconButton(
              onPressed: () async {
                isImage = true;
                final results = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg'],
                );
                if (isAndroid()) {
                  if (results == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No file found :()"),
                      ),
                    );
                    return null;
                  }
                  final filePath = results.files.single.path!;
                  final fileName = results.files.single.name;
                  print(filePath);
                  print(fileName);
                  _chattingService
                      .uploadFileOnMobile(filePath, fileName, widget.endUserId,
                          _firebaseAuth.currentUser!.uid)
                      .then((value) => print("File Uploaded! :)"))
                      .whenComplete(() => _chattingService
                              .getImageDownloadURL(widget.endUserId,
                                  _firebaseAuth.currentUser!.uid)
                              .then((value) {
                            print(value);
                            _chattingService.getImages(
                                widget.endUserId, value.toString());
                          }));
                } else {
                  if (results != null && results.files.isNotEmpty) {
                    final fileBytes = results.files.first.bytes;
                    final fileName = results.files.first.name;
                    // print(fileBytes);
                    print(fileName);
                    _chattingService
                        .uploadFileOnWeb(fileBytes, fileName, widget.endUserId,
                            _firebaseAuth.currentUser!.uid)
                        .then((value) => print("File Uploaded! :)"))
                        .whenComplete(() => _chattingService
                            .getImageDownloadURL(widget.endUserId,
                                _firebaseAuth.currentUser!.uid)
                            .then((value) => _chattingService.getImages(
                                widget.endUserId, value.toString())));
                  }
                }
              },
              icon: const Icon(Icons.image),
            )
          ],
        ),
        //messages
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _displayMessageList(),
                ),
                _writeMessageInput(),
              ],
            ),
            if (_isListening)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.red,
                      size: 100.0,
                    ),
                    const Text(
                      " Listening ...",
                      style: TextStyle(fontSize: 25.0, color: Colors.red),
                    )
                  ],
                ),
              ),
          ],
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterTop,
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
        ));
    //user input
  }

  Widget _displayMessageList() {
    return StreamBuilder(
        stream: _chattingService.getMessages(
            widget.endUserId, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          //if statement for the speech to text button !---FIX THE PROBLEM OF THE FLICKERING
          if (!_isListening) {
            if (snapshot.hasError) {
              return Text('Error${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading ...");
            }
          }
          return SingleChildScrollView(
            reverse: true,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(snapshot.data!.docs[index]);
              },
            ),
          );
        });
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Color chatBubbleColor;
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
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            data['message'].toString().isNotEmpty
                ? ChatBubble(
                    message: data['message'],
                    image: null,
                    isImage: false,
                    chatBubbleColor:
                        data['senderId'] == _firebaseAuth.currentUser!.uid
                            ? chatBubbleColor = Colors.blueAccent
                            : chatBubbleColor = Colors.pinkAccent,
                  )
                : ChatBubble(
                    message: null,
                    image: data['image'],
                    isImage: true,
                    chatBubbleColor:
                        data['senderId'] == _firebaseAuth.currentUser!.uid
                            ? chatBubbleColor = Colors.blueAccent
                            : chatBubbleColor = Colors.pinkAccent,
                  )
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
          child: TextField(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSubmitted: (value) {
              sendMessage();
            },
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              fillColor: Colors.grey[200],
              filled: true,
              hintText: "Write a message ...",
              hintStyle: const TextStyle(color: Colors.black),
            ),
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

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // void _listen() async {
  //   // window.navigator.getUserMedia(audio: true).then((value) => {});
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (status) {
  //         setState(() {
  //           if (status.toString() == "notListening") {
  //             _isListening = false;
  //             String notListeningPrompt = "Exiting listening mode ...";
  //             var result = flutterTts.speak(notListeningPrompt);
  //           }
  //           print('onStatus: $status');
  //         });
  //       },
  //       onError: (status) => print('onError: $status'),
  //     );
  //     if (available) {
  //       setState(() {
  //         _isListening = true;
  //       });
  //       // _speech.listen(
  //       //   listenFor: const Duration(seconds: 20),
  //       //   onResult: (result) => setState(() {
  //       //     _text = result.recognizedWords;
  //       //     _messageController.text = _text;
  //       //     print(_text);
  //       //     // if (result.hasConfidenceRating && result.confidence > 0) {
  //       //     //   _confidence = result.confidence;
  //       //     // }
  //       //   }),
  //       // );
  //     }
  //   } else {
  //     setState(() {
  //       _isListening = !_isListening; // Toggle the flag
  //       // _speech.stop();
  //       _messageFocusNode.requestFocus();
  //     });
  //   }
  // }
}
