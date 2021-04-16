import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/verificar_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Finanças",
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: VerificarLogin()));
}
