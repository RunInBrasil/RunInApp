import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:run_in/objects/Train.dart';
import 'package:run_in/train.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;
import 'package:run_in/utils/GlobalState.dart';
import 'package:run_in/utils/constants.dart' as constants;


final FirebaseAuth _auth = FirebaseAuth.instance;
final failedConexionSnackbar = SnackBar(content: Text('Erro ao atualizar informações, verifique sua conexão'));

final String backgroundImagePath = "assets/images/prepare_to_run.png";

const List<Text> menuItems = <Text>[
  const Text("Sair"),
];

class HomePage extends StatelessWidget {
  BuildContext baseContext;

  @override
  Widget build(BuildContext context) {
    baseContext = context;
    return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(image: new AssetImage(
              backgroundImagePath),
              fit: BoxFit.cover)
      ),
      child: new Scaffold(
        backgroundColor: Colors.transparent,
          appBar: new AppBar(
            title: Text('RunIn'),
            backgroundColor: Colors.transparent,
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
          body: Column(
                  children: <Widget>[
                    new HomePageFrame(),
                    Spacer(),
                  ],
                ),),
    );
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
}

class HomePageFrame extends StatefulWidget {
  FirebaseApp app;
  FirebaseUser user;

  @override
  _HomePageFrameState createState() {
    return new _HomePageFrameState();
  }
}

class _HomePageFrameState extends State<HomePageFrame> with WidgetsBindingObserver {
  var trainArray = [];
  DatabaseReference _trainRef;
  int dayIndex;
  String today;

  bool loadingInfo = false;

  var trainStatus = '';

  GlobalState _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _store = GlobalState.instance;
    final f = new DateFormat('yyyy-MM-dd');
    today = f.format(new DateTime.now());
    trainArray = _store.get(_store.TRAIN_ARRAY_KEY);

    for(Train train in trainArray) {
      if (train.finished == new DateTime.now().toIso8601String().substring(0, 10)) {
        dayIndex = train.index;
        trainStatus = 'finished';
        break;
      }
      if (train.finished == null) {
        dayIndex = train.index;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var todayTrain = Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        color: constants.primaryColor,
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Expanded(
                child: ListTile(
                  leading: const Icon(Icons.directions_run, color: Colors.white,),
                  title: new Text(getTodayDate(), style: new TextStyle(color: Colors.white),),
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
                    child: new Text('Concluído', style: new TextStyle(color: Colors.white)),
                    onPressed:
                        trainStatus == 'finished' ? null : _setTrainFinished,
                  ),
                ),
                Expanded(
                  child: FlatButton(
                      onPressed: _goTrainPage,
                      child: trainStatus == 'finished'
                          ? new Text('Refazer', style: new TextStyle(color: Colors.white))
                          : new Text('Iniciar', style: new TextStyle(color: Colors.white))),
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
            title: new Text('Concluir treino?', style: new TextStyle(color: constants.primaryColor)),
            content: new Text('Dejesa marcar o treino como concluido?', style: new TextStyle(color: constants.primaryColor)),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancelar')),
              new FlatButton(
                  onPressed: () {
                    concludeTrain();
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
      FirebaseService.getInitialInfo();
    }
  }


  Widget _buildTrainListView() {
    if (trainArray.length == 0) {
      return Container(
        height: 40.0,
        child: Text('Nenhum treino para hoje', style: new TextStyle(color: Colors.white)),
      );
    }

    return Container(
      height: trainArray[dayIndex].steps.length * 20.0,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (trainArray[dayIndex].steps[index].speed == 0) {
            return Text(
                '${trainArray[dayIndex].steps[index].time / 60}  minutos de descanso', style: new TextStyle(color: Colors.white));
          }
          return Text(
              '${trainArray[dayIndex].steps[index].time / 60}  minutos na velocidade  ${trainArray[dayIndex].steps[index].speed}', style: new TextStyle(color: Colors.white));
        },
        itemCount: trainArray[dayIndex].steps.length,
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

  void concludeTrain() {
    FirebaseService.concludeATrain(dayIndex);
  }

//  void fetchInfoFromFirebase() {
//    setState(() {
//      loadingInfo = true;
//    });
//    widget.getUser().then((response) {
//      widget.configureFirebaseApp().then((response) {
//        DatabaseReference _evaluationRef = FirebaseDatabase.instance
//            .reference()
//            .child('trains')
//            .child(widget.user.uid)
//            .child('status');
//
//        _evaluationRef.once().then((DataSnapshot snapshot) {
//          evaluationStatus = snapshot.value;
//          if (evaluationStatus != 'progress') {
//            _goTutorialPage();
//          }
//        })
//            .timeout(Duration(seconds: 20))
//            .catchError((error) {
//          Scaffold.of(context).showSnackBar(failedConexionSnackbar);
//          setState(() {
//            loadingInfo = false;
//          });
//        });
//        _evaluationRef.keepSynced(true);
//
//        final FirebaseDatabase database = new FirebaseDatabase(app: widget.app);
//
//        _trainRef = database
//            .reference()
//            .child('trains')
//            .child(widget.user.uid)
//            .child('treinos');
//
//        _trainRef
//            .orderByChild('finished')
//            .equalTo(f.format(new DateTime.now()))
////            .onValue
////            .listen((Event event) {
//            .once()
//            .then((DataSnapshot snapshot) {
//          if (snapshot.value != null) {
//            setState(() {
//              loadingInfo = false;
//              trainStatus = 'finished';
//              trainArray = new List();
//              for (var key in snapshot.value.keys) {
//                dayIndex = key;
//                for (int i = 0; i < snapshot.value[key].length - 1; i++) {
//                  trainArray.add(snapshot.value[key][i.toString()]);
//                }
//              }
//            });
//          } else {
//            _trainRef
//                .orderByChild('finished')
//                .equalTo(null)
//                .limitToFirst(1)
////                .onValue
////                .listen((Event event) {
////              setState(() {
////                trainArray = new List();
////                if (event.snapshot.value.keys != null) {
////                  for (var key in event.snapshot.value.keys) {
////                    dayIndex = key;
////                    for (var train in event.snapshot.value[key]) {
////                      trainArray.add(train);
////                    }
////                  }
////                } else {
////                  print(event.snapshot.key);
////                  for (var key in event.snapshot.value) {
////                    dayIndex = '0';
////                    for (var train in key) {
////                      trainArray.add(train);
////                    }
////                  }
////                }
////              });
////            });
//                .once()
//                .then((DataSnapshot snapshot) {
//              setState(() {
//                loadingInfo = false;
//                trainArray = new List();
//                if (snapshot.value.keys != null) {
//                  for (var key in snapshot.value.keys) {
//                    dayIndex = key;
//                    for (var train in snapshot.value[key]) {
//                      trainArray.add(train);
//                    }
//                  }
//                } else {
//                  print(snapshot.key);
//                  for (var key in snapshot.value) {
//                    dayIndex = '0';
//                    for (var train in key) {
//                      trainArray.add(train);
//                    }
//                  }
//                }
//              });
//            })
//                .catchError((error) {
//              Scaffold.of(context).showSnackBar(failedConexionSnackbar);
//            });
//          }
//          _trainRef.keepSynced(true);
//        })
//            .catchError((error) {
//          Scaffold.of(context).showSnackBar(failedConexionSnackbar);
//        });
//
////        _trainRef.once().then((DataSnapshot snapshot) {
////          print('LOGANDO: Connected to second database and read ${snapshot
////              .value}');
////        _trainRef.onValue.listen((Event event) {
////          setState(() {
////            trainArray = [];
////            trainStatus = event.snapshot.value['status'];
////            for (int i = 0; i < (event.snapshot.value['treino']).length; i++) {
////              if (event.snapshot.value['treino'][i] != null) {
////                print(trainArray.length);
////                trainArray.add(event.snapshot.value['treino'][i]);
////              }
////            }
////          });
////        });
//      }).catchError((error)  {
//        Scaffold.of(context).showSnackBar(failedConexionSnackbar);
//      });
//    }).catchError((error) {
//      Scaffold.of(context).showSnackBar(failedConexionSnackbar);
//    });
//  }
}
