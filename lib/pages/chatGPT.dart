import 'dart:async';
import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/services/authentication/auth_service.dart';
import 'package:chat_app/services/chatting/chatting_service.dart';
import 'package:chat_app/services/chatting/open_ai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ChatGPT extends StatefulWidget {
  const ChatGPT({super.key});

  @override
  State<ChatGPT> createState() => _ChatGPTState();
}

class _ChatGPTState extends State<ChatGPT> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ChattingService _chattingService = ChattingService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isTimerRunning = false;

  late Timer _timer;
  int _start = 30;

  void startTimer() {
    isTimerRunning = true;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void sendGPTMessage() async {
    startTimer();
    if (_messageController.text.isNotEmpty) {
      String prompt = _messageController.text;
      await _chattingService.sendMessageChatGPT(prompt, "");
    }
  }

  void generateGPTMessage() async {
    if (_messageController.text.isNotEmpty) {
      String prompt = _messageController.text;
      final speech = await OpenAiService().isArtPromptAPI(prompt);
      await _chattingService.sendMessageChatGPT("", speech);
      print(speech);
      setState(() {
        _messageController.clear();
        _messageFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myTokenCounterState =
        Provider.of<AuthService>(context, listen: false);

    void tokenCounterState() {
      myTokenCounterState.tokenCounter();
    }

    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "CHATGPT & DALL-E",
            style: TextStyle(fontSize: 12),
          ),
          Text(
            "Timer: $_start",
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            "Tokens used: ${myTokenCounterState.tokenCounterValue}/5",
            style: const TextStyle(fontSize: 12),
          )
        ],
      )),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _displayGPTMessageList()),
              _writeMessageInput(tokenCounterState, myTokenCounterState),
            ],
          )
        ],
      ),
    );
  }

  Widget _displayGPTMessageList() {
    return StreamBuilder(
        stream:
            _chattingService.getMessagesFromGPT(_firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          //if statement for the speech to text button !---FIX THE PROBLEM OF THE FLICKERING
          if (!isTimerRunning) {
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
                return _displayGPT(snapshot.data!.docs[index]);
              },
            ),
          );
        });
  }

  //display the response
  Widget _displayGPT(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var align = (data['user'].toString().isNotEmpty)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //GPT container
            (data['content'].toString().isNotEmpty)
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          child: Lottie.asset(
                            'assets/robot.json',
                            height: 50,
                          ),
                        ),
                      ),
                      (data['content'].toString().contains("https"))
                          ? Flexible(
                              child: ChatBubble(
                              isImage: true,
                              chatBubbleColor: Colors.red,
                              message: null,
                              image: data['content'],
                            ))
                          : Flexible(
                              child: ChatBubble(
                              isImage: false,
                              chatBubbleColor: Colors.red,
                              message: data['content'],
                            )),
                    ],
                  )
                : //User Container
                ChatBubble(
                    isImage: false,
                    chatBubbleColor: Colors.blue,
                    message: data['user'],
                  )
          ],
        ),
      ),
    );
  }

//write message input
  Widget _writeMessageInput(
      Function tokenFunction, AuthService myTokenCounterState) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            enabled: myTokenCounterState.tokenAuth,
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSubmitted: (value) {
              tokenFunction();
              sendGPTMessage();
              generateGPTMessage();
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
              hintText: myTokenCounterState.tokenAuth
                  ? "Write a message ..."
                  : "You have reached the limit!! Try again tomorrow",
              hintStyle: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            sendGPTMessage();
            generateGPTMessage();
          },
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
}
