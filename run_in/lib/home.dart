import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:run_in/login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:run_in/tools/trainBuilder.dart';
import 'package:run_in/train.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final failedConexionSnackbar = SnackBar(content: Text('Erro ao atualizar informações, verifique sua conexão'));


const List<Text> menuItems = <Text>[
  const Text("Sair"),
];

class HomePage extends StatelessWidget {
  BuildContext baseContext;

  @override
  Widget build(BuildContext context) {
    baseContext = context;
    _checkIfLogged(context);
    return new Scaffold(
        appBar: new AppBar(
          title: Text('RunIn'),
          actions: <Widget>[
            new PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return menuItems.map((Text item) {
                  return new PopupMenuItem(
                    value: item.data,
                    child: item,
                  );
                }).toList();
              },
              onSelected: _handleMenuAction,
            )
          ],
        ),
        body: Container(
            constraints: new BoxConstraints.expand(),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage("assets/images/prepare-to-run.jpg"),
                    fit: BoxFit.cover)),
            child: Column(
              children: <Widget>[
                new HomePageFrame(),
                Spacer(),
              ],
            )));
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case "Sair":
        _logOut();
        break;
    }
  }

  void _logOut() async {
    await _auth.signOut().then((onValue) async {
      Navigator.of(baseContext)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  void _checkIfLogged(BuildContext context) async {
    if (await _auth.currentUser() != null) {
      return;
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }
}

class HomePageFrame extends StatefulWidget {
  FirebaseApp app;
  FirebaseUser user;

  @override
  _HomePageFrameState createState() {
    return new _HomePageFrameState();
  }

  Future configureFirebaseApp() async {
    app = await FirebaseApp.configure(
      name: 'run-in',
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

  Future getUser() async {
    user = await _auth.currentUser();
  }
}

class _HomePageFrameState extends State<HomePageFrame> with WidgetsBindingObserver {
  var trainArray = [];
  DatabaseReference _trainRef;
  String evaluationStatus;
  String dayIndex;
  String today;

  bool loadingInfo = false;

  var trainStatus = '';

  @override
  Widget build(BuildContext context) {
    var todayTrain = Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        color: Color(0xAA000000),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                child: ListTile(
                  leading: const Icon(Icons.directions_run),
                  title: new Text(getTodayDate()),
                ),
              ),
              loadingInfo ? Container(
                width: 24.0,
                height: 24.0,
                child: new CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              ) : 
              Padding(
                padding: EdgeInsets.all(0.0),
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: trainStatus == 'finished'
                      ? new Icon(Icons.beenhere)
                      : null)
            ],
          ),
          Padding(
              padding: EdgeInsets.only(
                  left: 64.0, top: 8.0, right: 0.0, bottom: 8.0),
              child: _buildTrainListView()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: const Text('Concluído'),
                    onPressed:
                        trainStatus == 'finished' ? null : _setTrainFinished,
                  ),
                ),
                Expanded(
                  child: FlatButton(
                      onPressed: _goTrainPage,
                      child: trainStatus == 'finished'
                          ? const Text('Refazer')
                          : const Text('Iniciar')),
                )
              ],
            ),
          ),
        ],
      )),
    );
    return todayTrain;
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Concluir treino?'),
            content: new Text('Dejesa marcar o treino como concluido?'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancelar')),
              new FlatButton(
                  onPressed: () {
                    _trainRef.child(dayIndex).child('finished').set(today);
                    setState(() {
                      trainStatus = 'finished';
                    });
                    Navigator.of(context).pop();
                  },
                  child: new Text('Concluir'))
            ],
          );
        });
  }

  String getTodayDate() {
    final f = new DateFormat('dd/MM/yyyy');
    return f.format(new DateTime.now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchInfoFromFirebase();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchInfoFromFirebase();
  }


  Widget _buildTrainListView() {
    if (trainArray.length == 0) {
      return Container(
        height: 40.0,
        child: Text('Nenhum treino para hoje'),
      );
    }

    return Container(
      height: trainArray.length * 20.0,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (trainArray[index]['speed'] == 0) {
            return Text(
                '${trainArray[index]['time'] / 60}  minutos de descanso');
          }
          return Text(
              '${trainArray[index]['time'] / 60}  minutos na velocidade  ${trainArray[index]['speed']}');
        },
        itemCount: trainArray.length,
      ),
    );
  }

  void _setTrainFinished() {
    _showDialog();
  }

  void _goTrainPage() {
    if (trainArray.length != 0) {
//      Navigator.of(context).push(new PageRouteBuilder(
//        pageBuilder: (_, __, ___) =>
//            new TrainPage({'trains': trainArray, 'day': dayIndex}),
//      ));
      Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => new TrainPage({'trains': trainArray, 'day': dayIndex})),
      );
    }
    return null;
  }

  void _goTutorialPage() {
    Navigator.of(context).pushNamed('/tutorial');
    return null;
  }

  void fetchInfoFromFirebase() {
    setState(() {
      loadingInfo = true;
    });
    widget.getUser().then((response) {
      widget.configureFirebaseApp().then((response) {
        DatabaseReference _evaluationRef = FirebaseDatabase.instance
            .reference()
            .child('trains')
            .child(widget.user.uid)
            .child('status');

        _evaluationRef.once().then((DataSnapshot snapshot) {
          evaluationStatus = snapshot.value;
          if (evaluationStatus != 'progress') {
            _goTutorialPage();
          }
        })
        .timeout(Duration(seconds: 20))
        .catchError((error) {
          Scaffold.of(context).showSnackBar(failedConexionSnackbar);
          setState(() {
            loadingInfo = false;
          });
        });
        _evaluationRef.keepSynced(true);

        final FirebaseDatabase database = new FirebaseDatabase(app: widget.app);

        final f = new DateFormat('yyyy-MM-dd');
        today = f.format(new DateTime.now());

        _trainRef = database
            .reference()
            .child('trains')
            .child(widget.user.uid)
            .child('treinos');

        _trainRef
            .orderByChild('finished')
            .equalTo(f.format(new DateTime.now()))
//            .onValue
//            .listen((Event event) {
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            setState(() {
              loadingInfo = false;
              trainStatus = 'finished';
              trainArray = new List();
              for (var key in snapshot.value.keys) {
                dayIndex = key;
                for (int i = 0; i < snapshot.value[key].length - 1; i++) {
                  trainArray.add(snapshot.value[key][i.toString()]);
                }
              }
            });
          } else {
            _trainRef
                .orderByChild('finished')
                .equalTo(null)
                .limitToFirst(1)
//                .onValue
//                .listen((Event event) {
//              setState(() {
//                trainArray = new List();
//                if (event.snapshot.value.keys != null) {
//                  for (var key in event.snapshot.value.keys) {
//                    dayIndex = key;
//                    for (var train in event.snapshot.value[key]) {
//                      trainArray.add(train);
//                    }
//                  }
//                } else {
//                  print(event.snapshot.key);
//                  for (var key in event.snapshot.value) {
//                    dayIndex = '0';
//                    for (var train in key) {
//                      trainArray.add(train);
//                    }
//                  }
//                }
//              });
//            });
                .once()
                .then((DataSnapshot snapshot) {
              setState(() {
                loadingInfo = false;
                trainArray = new List();
                if (snapshot.value.keys != null) {
                  for (var key in snapshot.value.keys) {
                    dayIndex = key;
                    for (var train in snapshot.value[key]) {
                      trainArray.add(train);
                    }
                  }
                } else {
                  print(snapshot.key);
                  for (var key in snapshot.value) {
                    dayIndex = '0';
                    for (var train in key) {
                      trainArray.add(train);
                    }
                  }
                }
              });
            })
            .catchError((error) {
              Scaffold.of(context).showSnackBar(failedConexionSnackbar);
            });
          }
          _trainRef.keepSynced(true);
        })
        .catchError((error) {
          Scaffold.of(context).showSnackBar(failedConexionSnackbar);
        });

//        _trainRef.once().then((DataSnapshot snapshot) {
//          print('LOGANDO: Connected to second database and read ${snapshot
//              .value}');
//        _trainRef.onValue.listen((Event event) {
//          setState(() {
//            trainArray = [];
//            trainStatus = event.snapshot.value['status'];
//            for (int i = 0; i < (event.snapshot.value['treino']).length; i++) {
//              if (event.snapshot.value['treino'][i] != null) {
//                print(trainArray.length);
//                trainArray.add(event.snapshot.value['treino'][i]);
//              }
//            }
//          });
//        });
      }).catchError((error)  {
        Scaffold.of(context).showSnackBar(failedConexionSnackbar);
      });
    }).catchError((error) {
      Scaffold.of(context).showSnackBar(failedConexionSnackbar);
    });
  }
}
