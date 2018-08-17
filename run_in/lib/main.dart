import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:run_in/home.dart';
import 'package:run_in/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final routes = <String, WidgetBuilder> {
  '/home': (BuildContext context) => new HomePage(),
  '/login': (BuildContext context) => new LoginPage(),
};

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This widget is the root of your application.
    var destination;
    if (_auth.currentUser() != null) {
      destination = HomePage();
    } else {
      destination = LoginPage();
    }

    return new MaterialApp(
      title: 'RunIn',
      color: Colors.blue,
      routes: routes,
      home: destination,
    );
  }

}

