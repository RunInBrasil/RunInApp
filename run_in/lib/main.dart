import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:run_in/home.dart';
import 'package:run_in/introduction/tutorial.dart';
import 'package:run_in/login.dart';
import 'package:run_in/train.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final routes = <String, WidgetBuilder> {
  '/home': (BuildContext context) => new HomePage(),
  '/login': (BuildContext context) => new LoginPage(),
  '/train': (BuildContext context) => new TrainPage(),
  '/tutorial': (BuildContext context) => new Tutorial()
};

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This widget is the root of your application.
    var destination;
    if (_auth.currentUser() != null) {
      destination = HomePage();
//      destination = Tutorial();
    } else {
      destination = LoginPage();
//      destination = Tutorial();
    }

    return new MaterialApp(
      title: 'RunIn',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Colors.white
      ),
      routes: routes,
      home: destination,
    );
  }

}

