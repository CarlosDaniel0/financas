import 'package:financas/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/home.dart';

class VerificarLogin extends StatefulWidget {
  @override
  _VerificarLoginState createState() => _VerificarLoginState();
}

class _VerificarLoginState extends State<VerificarLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => user == null ? LoginPage() : Home()));
    });
    return Container();
  }
}
