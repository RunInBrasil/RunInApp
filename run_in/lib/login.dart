import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:run_in/home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: Text('RunIn'),
        ),
        body: new LoginPageFrame());
  }
}

class LoginPageFrame extends StatefulWidget {
  var title = 'RunIn';

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPageFrame> {
  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              onPressed: _signIn,
              color: Colors.blue,
              child: Text('Login'),
            ),
            new RaisedButton(
              onPressed: _logout,
              child: Text('Logout'),
            )
          ],
        ),
    );
  }

  void _signIn() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
    _signInWithGoogle().then((response) {
      print('LOG: veio');
      _navigateToMainPage(context);
    });
  }

  Future<String> _signInWithGoogle() async {
    print('Inicio');
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print("LOG: User signed in: $user");

    return 'signInWithGoogle succeeded: $user';
  }

  Future<String> _logout() async {
    await _auth.signOut();
    if (await _auth.currentUser() == null) {
      print("LOG: User signed out");
    } else {
      print("LOG: User not signed out");
    }
    return ("out");
  }

  void _navigateToMainPage(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home', (Route<dynamic> route) => false
    );
  }
}
