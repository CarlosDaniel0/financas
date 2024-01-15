import 'package:financas/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/verificar_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Finanças",
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          tabBarTheme: new TabBarTheme(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60),
          appBarTheme: new AppBarTheme(
              color: Colors.indigo,
              titleTextStyle: new TextStyle(color: Colors.white, fontSize: 18),
              iconTheme: new IconThemeData(color: Colors.white)),
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: VerificarLogin()));
}
