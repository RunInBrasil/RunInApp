import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

final String passwordInvalid =
    'PlatformException(exception, The password is invalid or the user does not have a password., null)';
final String userAlreadyExist =
    'PlatformException(exception, The email address is already in use by another account., null)';

final incorrectPasswordSnackBar = SnackBar(content: Text('Senha Incorreta'));
final userAlreadExistSnackbar =
    SnackBar(content: Text('Este usuário já esta cadastrado'));
final errorOnRetrieveEvaluation =
    SnackBar(content: Text('Houve um erro ao recuperar suas informações'));

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//        appBar: new AppBar(
//          title: Text('RunIn'),
//        ),
        body: new LoginPageFrame());
  }
}

class LoginPageFrame extends StatefulWidget {
  var title = 'RunIn';
  FirebaseApp app;

  @override
  _LoginPageState createState() {
    configureFirebaseApp();
    return new _LoginPageState();
  }

  Future configureFirebaseApp() async {
    app = await FirebaseApp.configure(
      options: Platform.isIOS
          ? const FirebaseOptions(
              googleAppID: '1:808188414561:ios:a1f5c1e0a4427dd3',
              gcmSenderID: '808188414561',
              apiKey: 'AIzaSyCPVxFP42DTFixgO9mTDoTep_OW-LTIA18',
              projectID: 'runin-d30a7',
              databaseURL: 'https://runin-d30a7.firebaseio.com',
            )
          : const FirebaseOptions(
              googleAppID: '1:808188414561:android:0354ca0c79b55f65',
              apiKey: 'AIzaSyAAWl2MXOnpAUca6lly3wEru1ZoyCu3yFw',
              databaseURL: 'https://runin-d30a7.firebaseio.com',
            ),
    );
  }
}

class _LoginPageState extends State<LoginPageFrame> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var toRegister = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!toRegister) {
      return new Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 124.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Container(
                  decoration: new BoxDecoration(
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(32.0)),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: new TextFormField(
                      style: new TextStyle(color: Colors.black),
                      controller: emailController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Email',
                        labelStyle: new TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Container(
                  decoration: new BoxDecoration(
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(32.0)),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: new TextFormField(
                      style: new TextStyle(color: Colors.black),
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Senha',
                        labelStyle: new TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Container(
                      width: 128.0,
                      child: new OutlineButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                        ),
                        onPressed: () {
                          setState(() {
                            toRegister = true;
                          });
                        },
                        child: Text(
                          'Cadastrar',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Container(
                      width: 128.0,
                      child: new OutlineButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                        ),
                        onPressed: _signInEmail,
                        child: Text(
                          'Entrar',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new OutlineButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(32.0),
                  ),
                  onPressed: _signInGoogle,
                  child: ListTile(
//                    leading: const Icon(Icons.email),
                    leading: const Image(
                      image: AssetImage('assets/icons/google_icon.png'),
                      height: 24.0,
                    ),

                    title: const Text('Entrar com Google'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return new Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 64.0, right: 64.0, top: 21.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              new TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha'),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: new OutlineButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(32.0),
                  ),
                  onPressed: _registerEmail,
                  child: Text('Cadastrar'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new OutlineButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(32.0),
                  ),
                  onPressed: () {
                    setState(() {
                      toRegister = false;
                    });
                  },
                  child: ListTile(
                    leading: const Image(
                      image: AssetImage('assets/icons/gmail_icon.png'),
                      height: 24.0,
                    ),
                    title: const Text('Entrar com email'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new OutlineButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(32.0),
                  ),
                  onPressed: _signInGoogle,
                  child: ListTile(
                    leading: const Image(
                      image: AssetImage('assets/icons/google_icon.png'),
                      height: 24.0,
                    ),
                    title: const Text('Entrar com Google'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(LoginPageFrame oldWidget) {}

  void _signInGoogle() {
    setState(() {});
    _showDialog();
    _signInWithGoogle().then((response) {
      _getEvaluationStatus().then((response) {
        Navigator.pop(context);
        if (response == 'progress') {
          _navigateToMainPage(context);
        } else {
          _navigateToTutorialPage(context);
        }
      }).catchError((onError) {
        Scaffold.of(context).showSnackBar(errorOnRetrieveEvaluation);
      });
    }).catchError((onError) {
      Navigator.pop(context);
    });
  }

  void _signInEmail() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
    _showDialog();
    _signInWithEmail().then((responseA) {
      _getEvaluationStatus().then((responseB) {
        Navigator.pop(context);
        if (responseB == 'progress') {
          _navigateToMainPage(context);
        } else {
          _navigateToTutorialPage(context);
        }
      }).catchError((onError) {
        Scaffold.of(context).showSnackBar(errorOnRetrieveEvaluation);
      });
    }).catchError((onError) {
      Navigator.pop(context);
      print('LOG: ');
      print(onError.toString());
      if (onError.toString() == passwordInvalid) {
        Scaffold.of(context).showSnackBar(incorrectPasswordSnackBar);
      }
    });
  }

  void _registerEmail() {
    _showDialog();
    _registerWithEmail().then((response) {
      _getEvaluationStatus().then((response) {
        Navigator.pop(context);
        if (response == 'progress') {
          _navigateToMainPage(context);
        } else {
          _navigateToTutorialPage(context);
        }
      }).catchError((onError) {
        Scaffold.of(context).showSnackBar(errorOnRetrieveEvaluation);
      });
    }).catchError((onError) {
      Navigator.pop(context);
      print(onError.hashCode);
      print(onError.toString());
      if (onError.toString() == userAlreadyExist) {
        Scaffold.of(context).showSnackBar(userAlreadExistSnackbar);
      }
    });
  }

  Future<String> _signInWithGoogle() async {
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

    return 'signInWithGoogle succeeded: $user';
  }

  Future<String> _signInWithEmail() async {
    final FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim());
    assert(user.email != null);
//    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  Future<String> _registerWithEmail() async {
    print('Inicio refgistro');
    print('LOG: ${emailController.text}');
    print('LOG: ${passwordController.text}');

    final FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim());

    assert(user.email != null);
//    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    print("LOG: User registered in: $user");

    return 'register succeeded: $user';
  }

  void _navigateToMainPage(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  void _navigateToTutorialPage(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/tutorial', (Route<dynamic> route) => false);
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Aguarde um momento...'),
            content: new CircularProgressIndicator(),
          );
        });
  }

  Future<String> _getEvaluationStatus() async {
    FirebaseUser user = await _auth.currentUser();
    DatabaseReference _evaluationRef = FirebaseDatabase.instance
        .reference()
        .child('trains')
        .child(user.uid)
        .child('status');


    DataSnapshot snapshot = await _evaluationRef.once();
    return snapshot.value;
  }
}
