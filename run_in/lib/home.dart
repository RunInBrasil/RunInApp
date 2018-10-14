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
final failedConexionSnackbar = SnackBar(
    content: Text('Erro ao atualizar informações, verifique sua conexão'));

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
          image: new DecorationImage(
              image: new AssetImage(backgroundImagePath), fit: BoxFit.cover)),
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
        ),
      ),
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

class _HomePageFrameState extends State<HomePageFrame>
    with WidgetsBindingObserver {
  var trainArray = [];
  DatabaseReference _trainRef;
  int dayIndex;
  String today;
  List<Train> completedTrains;

  bool loadingInfo = false;
  NumberFormat percentageFormatter = new NumberFormat("#");

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

    completedTrains = new List();

    for (Train train in trainArray) {
      if (train.finished ==
          new DateTime.now().toIso8601String().substring(0, 10)) {
        dayIndex = train.index;
        trainStatus = 'finished';
        break;
      }
      if (train.finished == null) {
        dayIndex = train.index;
        break;
      }
    }

    for (Train train in trainArray) {
      if (train.finished != null) {
        completedTrains.add(train);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    trainArray = _store.get(_store.TRAIN_ARRAY_KEY);
    completedTrains = new List();
    for (Train train in trainArray) {
      if (train.finished != null) {
        completedTrains.add(train);
      }
    }
    Widget todayTrain = Padding(
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
                      leading: const Icon(
                        Icons.directions_run,
                        color: Colors.white,
                      ),
                      title: new Text(
                        getTodayDate(),
                        style: new TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  loadingInfo
                      ? Container(
                          width: 24.0,
                          height: 24.0,
                          child: new CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : Padding(
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
                        child: new Text('Concluído',
                            style: new TextStyle(color: Colors.white)),
                        onPressed: trainStatus == 'finished'
                            ? null
                            : _setTrainFinished,
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                          onPressed: _goTrainPage,
                          child: trainStatus == 'finished'
                              ? new Text('Refazer',
                                  style: new TextStyle(color: Colors.white))
                              : new Text('Iniciar',
                                  style: new TextStyle(color: Colors.white))),
                    )
                  ],
                ),
              ),
            ],
          )),
    );

    Widget progressIndicator = Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Card(
        color: constants.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  'Completou ${getTrainProgress()['finished']} de ${getTrainProgress()['total']} treinos',
                  style: new TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new LinearProgressIndicator(
                  value: getTrainProgress()['ratio'],
                  backgroundColor: Colors.white,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  '${percentageFormatter.format(getTrainProgress()['ratio'] * 100)}%',
                  style: new TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget motivationalText = Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Card(
        color: constants.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Text(
            '“Um campeão tem medo de perder. Todo o resto têm medo de vencer.” – Billie Jean King, tenista',
            style: new TextStyle(color: Colors.white),
          ),
        ),
      ),
    );

    return Column(
      children: <Widget>[todayTrain, progressIndicator, motivationalText],
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Concluir treino?',
                style: new TextStyle(color: constants.primaryColor)),
            content: new Text('Dejesa marcar o treino como concluido?',
                style: new TextStyle(color: constants.primaryColor)),
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
        child: Text('Nenhum treino para hoje',
            style: new TextStyle(color: Colors.white)),
      );
    }

    return Container(
      height: trainArray[dayIndex].steps.length * 20.0,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (trainArray[dayIndex].steps[index].speed == 0) {
            return Text(
                '${trainArray[dayIndex].steps[index].time / 60}  minutos de descanso',
                style: new TextStyle(color: Colors.white));
          }
          return Text(
              '${trainArray[dayIndex].steps[index].time / 60}  minutos na velocidade  ${trainArray[dayIndex].steps[index].speed}',
              style: new TextStyle(color: Colors.white));
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

      Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                new TrainPage(trainArray[dayIndex].steps, dayIndex)),
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

  getTrainProgress() {
    return {
      'total': trainArray.length,
      'finished': completedTrains.length,
      'ratio': completedTrains.length.toDouble() / trainArray.length.toDouble()
    };
  }
}
