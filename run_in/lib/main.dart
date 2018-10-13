import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:run_in/home.dart';
import 'package:run_in/introduction/tutorial.dart';
import 'package:run_in/login.dart';
import 'package:run_in/train.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;
import 'package:run_in/utils/GlobalState.dart';

final routes = <String, WidgetBuilder> {
  '/main': (BuildContext context) => new MyApp(),
  '/home': (BuildContext context) => new HomePage(),
  '/login': (BuildContext context) => new LoginPage(),
//  '/train': (BuildContext context) => new TrainPage(),
  '/tutorial': (BuildContext context) => new Tutorial()
};

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  FirebaseApp app;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // This widget is the root of your application.
    return new MaterialApp(
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white
        ),
        primaryColor: Colors.black
      ),
      home: new MainPageFrame(),
      routes: routes,
    );
  }
}

class MainPageFrame extends StatefulWidget {

  @override
  _MainPageFrameState createState() {
    return new _MainPageFrameState();
  }

}

class _MainPageFrameState extends State<MainPageFrame> {
  GlobalState _store;

  @override
  void initState() {
    _store = GlobalState.instance;
    fetchInfo();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text(_store.get(FirebaseService.TrainStatusKey) == null ? 'Nada' : _store.get(FirebaseService.TrainStatusKey)),
    );
  }

  void fetchInfo() async {
    await FirebaseService.fetchInfoFromFirebase();
    if(_store.get(FirebaseService.UserKey) == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
      return;
    }
    if(_store.get(FirebaseService.EvaluationStatusKey) == 'progress') {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/tutorial', (Route<dynamic> route) => false);
    }
    setState(() {});
  }


}

