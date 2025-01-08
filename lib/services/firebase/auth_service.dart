import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../pages/main/main_page.dart';
import '../../pages/signin/signin_page.dart';
import '../firebase/user_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  Future<void> signup(
      {required String userName,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _userService.add(userCredential.user!.uid, userName, email);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const MainPage()));
    } on FirebaseAuthException catch (e) {
      String message = 'error coy';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const MainPage()));
    } on FirebaseAuthException catch (e) {
      String message = 'error coy';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => SigninPage()));
  }
}
