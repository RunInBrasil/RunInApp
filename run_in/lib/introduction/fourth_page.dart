import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:run_in/objects/TrainMetadata.dart';
import 'package:run_in/objects/User.dart';
import 'package:run_in/tools/circlePainter.dart';
import 'package:countdown/countdown.dart';
import 'package:run_in/tools/myDivider.dart';
import 'package:run_in/tools/trainBuilder.dart';
import 'package:run_in/utils/GlobalState.dart';
import 'package:run_in/utils/constants.dart' as constants;
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;


final FirebaseAuth _auth = FirebaseAuth.instance;

class FourthPage extends StatelessWidget {
  BuildContext baseContext;

  TabController _tabController;

  FourthPage(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    baseContext = context;
    return new Scaffold(
      backgroundColor: Colors.transparent,
        body: new FourthPageFrame(_tabController));
  }
}

class FourthPageFrame extends StatefulWidget {
  FirebaseApp app;
  FirebaseUser user;
  TabController _tabController;

  FourthPageFrame(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  _FourthPageFrameState createState() {
    return new _FourthPageFrameState();
  }

  Future getUser() async {
    user = await _auth.currentUser();
  }
}

class _FourthPageFrameState extends State<FourthPageFrame>
    with TickerProviderStateMixin {
  var trainArray = [];
  double percentage = 0.0;
  double newPercentage = 0.0;
  AnimationController percentageAnimationController;
  var actualStep = 0;
  var trainStarted = false;
  var timePassed = 0;
  CountDown countDown;
  var sub;
  final formatter = new NumberFormat("##00");
  TrainMetadata metadata;
  User user;
  GlobalState _store;

  @override
  void initState() {
    _store = GlobalState.instance;
    metadata = _store.get(_store.TRAIN_METADATA_KEY);
    user = _store.get(_store.USER_KEY);
    trainArray = _buildPerfomanceTest();
    timePassed = trainArray[actualStep]['time'];
    percentageAnimationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 10000))
      ..addListener(() {
        setState(() {
          percentage = lerpDouble(
              percentage, newPercentage, percentageAnimationController.value);
        });
      });
  }

  @override
  void dispose() {
    percentageAnimationController.dispose();
    super.dispose();
  }

  List _buildPerfomanceTest() {
    var test = new List(18);
    int startPoint;
    if(user.gender == user.FEMININE) {
      startPoint = 4;
    } else {
      startPoint = 5;
    }

    for (int i = startPoint; i < 18; i++) {
      test[i - startPoint] = new Map();
      test[i - startPoint]['speed'] = i;
      test[i - startPoint]['time'] = 60;
    }

    return test;
  }

  @override
  Widget build(BuildContext context) {
    var roundClock = Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Center(
        child: PhysicalModel(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                width: 220.0,
                height: 220.0,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(130.0),
                  color: Colors.transparent,
                ),
                child: new CustomPaint(
                  foregroundPainter: new MyPainter(
                      lineColor: Colors.transparent,
                      completeColor: Colors.white,
                      completePercent: percentage,
                      width: 3.0),
                  child: new Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _getSpeedlabel(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    var timer = new Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: new Text(
          _getRemainTime(),
          style: TextStyle(fontSize: 32.0),
        ),
      ),
    );

    var label = new Center(
        child: new Column(
      children: <Widget>[
        myDivider(),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: _getLabel(),
        ),
        myDivider()
      ],
    ));

    var playButton = new Padding(
      padding: EdgeInsets.all(0.0),
      child: Center(
        heightFactor: 2.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 32.0, left: 32.0),
              child: Container(
                height: 96.0,
                width: 96.0,
                child: BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: new FlatButton(
                    color: Colors.transparent,
                    onPressed: _onPlayButton,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(64.0),
                    ),
                    child: Icon(
                        timePassed == 0 && actualStep == trainArray.length - 1
                            ? Icons.beenhere
                            : trainStarted ? Icons.pause : Icons.directions_run,
                        size: 32.0,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            !trainStarted
                ? Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                    child: Container(
                      height: 96.0,
                      width: 96.0,
                      child: BackdropFilter(
                        filter:
                            new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: new FlatButton(
                          color: Colors.transparent,
                          onPressed: _onStopButton,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(64.0),
                          ),
                          child: Icon(
                              timePassed == 0 &&
                                      actualStep == trainArray.length - 1
                                  ? Icons.beenhere
                                  : trainStarted ? Icons.pause : Icons.stop,
                              size: 32.0,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 0.0,
                  ),
          ],
        ),
      ),
    );
    var screen = new Card(
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(32.0)
      ),
      color: constants.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[new Spacer(),roundClock, timer, label, playButton, new Spacer()],
        ),
      ),
    );
    return screen;
  }

  String _getRemainTime() {
    if (timePassed == 0 && actualStep == trainArray.length - 1) {
      return 'Parabéns!!';
    }
    if (trainArray != null && trainArray.length > 0) {
      var minutes = ((timePassed / 60)).floor();
      var seconds = (timePassed % 60);
      return formatter.format(minutes) + ':' + formatter.format(seconds);
    }
    return '00:00';
  }

  Widget _getLabel() {
    if (trainStarted) {
      if (timePassed <= 15) {
        if (actualStep == trainArray.length - 1) {
          if (timePassed == 0) {
            return new Text(
              'Ótimo treino',
              style: TextStyle(fontSize: 20.0),
            );
          }
          return new Text(
            'Estamos acabando',
            style: TextStyle(fontSize: 20.0),
          );
        }
        return new Text(
          'Preparar para a proxima velocidade...',
          style: TextStyle(fontSize: 20.0),
        );
      }
      return new Text(
        '${actualStep + 1}o Round',
        style: TextStyle(fontSize: 24.0),
      );
    }
    if (!trainStarted &&
        (actualStep != 0 || timePassed != trainArray[actualStep]['time'])) {
      return new Text(
        'Vamos lá, continue...',
        style: TextStyle(fontSize: 24.0),
      );
    }
    return new Text(
      'Vamos comecar da velocidade 4, quando estiver pronto coloque a esteira nessa velocidade e aperte o botão iniciar',
      style: TextStyle(fontSize: 16.0),
    );
  }

  void _onPlayButton() {
    setState(() {
      if (timePassed == 0 && actualStep == trainArray.length - 1) {
        Navigator
            .of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
      if (!trainStarted) {
        if (countDown == null) {
          countDown = new CountDown(new Duration(seconds: timePassed));
          sub = countDown.stream.listen(null);
        } else {
          sub.resume();
        }
        sub.onData((Duration d) {
          if (d.inSeconds != timePassed) {
            setState(() {
              percentage = newPercentage;
              timePassed = d.inSeconds;
              newPercentage = (trainArray[actualStep]['time'] - timePassed) *
                  100 /
                  trainArray[actualStep]['time'];
              percentageAnimationController.forward(from: 0.0);
            });
          }
        });
        sub.onDone(() {
          if (actualStep == trainArray.length - 1) {
//            _trainRef.child('status').set('finished');
          } else {
            actualStep++;
            setState(() {
              timePassed = trainArray[actualStep]['time'];
              registerNewCountdown();
            });
          }
        });
        trainStarted = !trainStarted;
      } else {
        sub.pause();
        trainStarted = !trainStarted;
      }
    });
  }

  List<Widget> _getSpeedlabel() {
    if (timePassed <= 15 && actualStep != trainArray.length - 1) {
      return [
        new Text(
          'Próxima velocidade...',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Text(
          '${trainArray[actualStep + 1]['speed']}',
          style: new TextStyle(fontSize: 96.0),
        ),
        new Text(
          'Km/h',
          style: new TextStyle(fontSize: 16.0),
        )
      ];
    }

    return [
      new Text(
        '${trainArray[actualStep]['speed']}',
        style: new TextStyle(fontSize: 96.0),
      ),
      new Text(
        'Km/h',
        style: new TextStyle(fontSize: 16.0),
      )
    ];
  }

  void registerNewCountdown() {
    countDown = new CountDown(new Duration(seconds: timePassed));
    sub = countDown.stream.listen(null);
    sub.onData((Duration d) {
      if (d.inSeconds != timePassed) {
        setState(() {
          percentage = newPercentage;
          timePassed = d.inSeconds;
          newPercentage = (trainArray[actualStep]['time'] - timePassed) *
              100 /
              trainArray[actualStep]['time'];
          percentageAnimationController.forward(from: 0.0);
        });
      }
    });
    sub.onDone(() {
      if (actualStep == trainArray.length - 1) {
//        _trainRef.child('status').set('finished');
      } else {
        actualStep++;
        setState(() {
          timePassed = trainArray[actualStep]['time'];
          registerNewCountdown();
        });
      }
    });
  }

  void _onStopButton() {
    saveUserEvaluation().then((response) {
      nextPage();
    });
  }

  Future saveUserEvaluation() async {

    metadata.evaluationSpeed = trainArray[actualStep]['speed'];
    metadata.status = 'progress';
    metadata.startDate = new DateTime.now().toIso8601String();

    FirebaseService.setTrainMetadata(metadata);

    TrainBuilder builder = new TrainBuilder(metadata.daysPerWeek, trainArray[actualStep]['speed']);
    builder.build();
    Map trains = builder.getTrain();


    FirebaseService.setTrain(trains);

//    for (var train in  trains) {
//      for (var trainDeep in train) {
//        print(trainDeep.time);
//        print(trainDeep.speed);
//      }
//    }
  }

  nextPage() {
    final int newIndex = widget._tabController.index + 1;
    if (newIndex < 0 || newIndex >= widget._tabController.length) {
      return;
    }
    widget._tabController.animateTo(newIndex);
  }
}
