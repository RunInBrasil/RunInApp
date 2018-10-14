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
import 'package:run_in/utils/constants.dart' as constants;


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
          bodyColor: constants.primaryColor,
          displayColor: Colors.white,
        ),
        primaryColor: constants.primaryColor
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
    if(await FirebaseService.isAuthenticated() == false) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
      return;
    }
    await FirebaseService.getInitialInfo();
    if(_store.get(_store.TRAIN_ARRAY_KEY) != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/tutorial', (Route<dynamic> route) => false);
    }
    setState(() {});
  }


}

