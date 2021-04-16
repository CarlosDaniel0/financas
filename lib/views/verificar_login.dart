import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/home.dart';
import '../views/login_page.dart';

class VerificarLogin extends StatefulWidget {
  @override
  _VerificarLoginState createState() => _VerificarLoginState();
}

class _VerificarLoginState extends State<VerificarLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User user = _auth.currentUser;
    // print('${user.photoURL} \n ${user.uid}');
    if (user == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
    return Container();
  }
}
