import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;


final String passwordInvalid =
    'PlatformException(exception, The password is invalid or the user does not have a password., null)';
final String userAlreadyExist =
    'PlatformException(exception, The email address is already in use by another account., null)';

final incorrectPasswordSnackBar = SnackBar(content: Text('Senha Incorreta'));
final userAlreadExistSnackbar =
SnackBar(content: Text('Este usuário já esta cadastrado'));
final errorOnRetrieveEvaluation =
SnackBar(content: Text('Houve um erro ao recuperar suas informações'));

final String logoPath = 'assets/images/logo_wide.jpg';
final String background = 'assets/images/login_background.jpg';

//final buttonColor = Color(0x99000000);
final buttonColor = Colors.white;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//        appBar: new AppBar(
//          title: Text('RunIn'),
//        ),
        body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage(background),
            fit: BoxFit.cover)
          ),
            child: new LoginPageFrame()));
  }
}

class LoginPageFrame extends StatefulWidget {
  var title = 'RunIn';
  FirebaseApp app;

  @override
  _LoginPageState createState() {
    return new _LoginPageState();
  }

}

class _LoginPageState extends State<LoginPageFrame> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var toRegister = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final loading = false;

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
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 0.0),
          child: new ListView(
//            mainAxisAlignment: MainAxisAlignment.center,
//            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  height: 158.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                      image: new DecorationImage(
                          image: new AssetImage(
                              logoPath),
                          fit: BoxFit.scaleDown)),
                ),
              ),
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
//                      child: BackdropFilter(
//                        filter: new ImageFilter.blur(
//                          sigmaX: 10.0,
//                          sigmaY: 10.0,
//                        ),
                      child: new RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                        ),
                        color: buttonColor,
                        onPressed: () {
                          setState(() {
                            toRegister = true;
                          });
                        },
                        child: Text(
                          'Cadastrar',
                        ),
                      ),
//                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Container(
                      width: 128.0,
                      child: new RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                        ),
                        color: buttonColor,
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
                child: new RaisedButton(
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
                  color: buttonColor,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return new Center(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 64.0, right: 64.0),
          child: new ListView(
//            mainAxisAlignment: MainAxisAlignment.center,
//            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                  child: BackdropFilter(filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                  child: Container(
                    height: 158.0,
                    width: 400.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                        image: new DecorationImage(
                            image: new AssetImage(
                                logoPath),
                            fit: BoxFit.contain)),
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
                      controller: nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Nome',
                        labelStyle: new TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                child: new RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(32.0),
                  ),
                  onPressed: _registerEmail,
                  child: Text('Cadastrar'),
                  color: buttonColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new RaisedButton(
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
                  color: buttonColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: new RaisedButton(
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
                  color: buttonColor,
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
      Navigator.pop(context);
      _navigateNextPage();
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
      Navigator.pop(context);
      _navigateNextPage();
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
      Navigator.pop(context);
      _navigateNextPage();
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
    await FirebaseService.signInWithGoogle();
  }

  Future<String> _signInWithEmail() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    await FirebaseService.signInWithEmail(email, password);

  }

  Future<String> _registerWithEmail() async {
    print('Inicio refgistro');
    print('LOG: ${emailController.text}');
    print('LOG: ${passwordController.text}');

    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();

    await FirebaseService.registerWithEmail(email, password, name);

  }

  void _navigateToMainPage(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
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

  void _navigateNextPage() async {
    if (await FirebaseService.isAuthenticated()) {
      _navigateToMainPage(context);
    }
  }
}
