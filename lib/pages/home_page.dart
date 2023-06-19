import 'package:chat_app/pages/chatting_page.dart';
import 'package:chat_app/services/authentication/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //instance of the auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //logout user
  void logout() {
    //get auth service
    final _authService = Provider.of<AuthService>(context, listen: false);

    _authService.logout();
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
      body: _buildUserList(),
    );
  }

  // build a list of users except the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong ...");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading ...");
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
