import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //login user
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      //login
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firestore.collection('users').doc(userCredential.user!.uid).set(
          ({
            'uid': userCredential.user!.uid,
            'email': email,
          }),
          SetOptions(merge: true));
      return userCredential;
      //catch any errors
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //create a new user
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //after user creation create a doc on firestore
      _firestore.collection('users').doc(userCredential.user!.uid).set(({
            'uid': userCredential.user!.uid,
            'email': email,
          }));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //logout user
  Future<void> logout() async {
    return await FirebaseAuth.instance.signOut();
  }

  int tokenCounterValue = 0;
  bool tokenAuth = true;
  Future<int> tokenCounter() async {
    tokenCounterValue++;
    if (tokenCounterValue >= 5) {
      tokenAuth = false;
    }
    notifyListeners();
    return tokenCounterValue;
  }
}
