import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:run_in/tools/circlePainter.dart';
import 'package:countdown/countdown.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class TrainPage extends StatelessWidget {
  BuildContext baseContext;
  var trainArray = [];

  TrainPage(List trainArray) {
    this.trainArray = trainArray;
  }

  @override
  Widget build(BuildContext context) {
    if (trainArray == null || trainArray.length == 0) {
      Navigator.of(baseContext).pushNamed('/home');
    }
    baseContext = context;
    return new Scaffold(body: new TrainPageFrame(trainArray));
  }
}

class TrainPageFrame extends StatefulWidget {
  FirebaseApp app;
  FirebaseUser user;
  var trainArray = [];

  TrainPageFrame(List trainArray) {
    this.trainArray = trainArray;
  }

  @override
  _TrainPageFrameState createState() {
    return new _TrainPageFrameState();
  }

//  Future configureFirebaseApp() async {
//    app = await FirebaseApp.configure(
//      name: 'db2',
//      options: Platform.isIOS
//          ? const FirebaseOptions(
//        googleAppID: '1:808188414561:ios:7e6d93c2f42792e9',
//        gcmSenderID: '808188414561',
//        databaseURL: 'https://runin-d30a7.firebaseio.com',
//      )
//          : const FirebaseOptions(
//        googleAppID: '1:808188414561:android:0354ca0c79b55f65',
//        apiKey: 'AIzaSyAAWl2MXOnpAUca6lly3wEru1ZoyCu3yFw',
//        databaseURL: 'https://runin-d30a7.firebaseio.com',
//      ),
//    );
//  }

  Future getUser() async {
    user = await _auth.currentUser();
  }
}

class _TrainPageFrameState extends State<TrainPageFrame>
    with TickerProviderStateMixin {
  DatabaseReference _trainRef;
  var percentage = 0.0;
  double newPercentage = 0.0;
  AnimationController percentageAnimationController;
  var actualStep = 0;
  var trainStarted = false;
  var timePassed = 0;
  CountDown countDown;
  var sub;
  final formatter = new NumberFormat("##00");

  @override
  void initState() {
    widget.getUser().then((response) async {
//      final f = new DateFormat('yyyy-MM-dd');

//      _trainRef = FirebaseDatabase.instance
//          .reference()
//          .child('trains')
//          .child(widget.user.uid)
//          .child(f.format(new DateTime.now()));
//
//      await _trainRef.once().then((DataSnapshot snapshot) {
//        print('LOGANDO: Connected to second database and read ${snapshot
//            .value}');
//        setState(() {
//          trainArray = snapshot.value['treino'];
//          trainArray = [];
//          for (int i = 0; i < (snapshot.value['treino']).length; i++) {
//            if (snapshot.value['treino'][i] != null) {
//              print(trainArray.length);
//              trainArray.add(snapshot.value['treino'][i]);
//            }
//          }
//        });
//      });

    });

    setState(() {
      timePassed = widget.trainArray[actualStep]['time'];
      percentage = 0.0;
    });

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
  Widget build(BuildContext context) {
    var roundClock = Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 0.0),
      child: Center(
        child: PhysicalModel(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                width: 300.0,
                height: 300.0,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(150.0),
                  color: Colors.transparent,
                ),
                child: new CustomPaint(
                  foregroundPainter: new MyPainter(
                      lineColor: Colors.transparent,
                      completeColor: Colors.white,
                      completePercent: percentage,
                      width: 3.0),
                  child: new Center(
//                    child: RaisedButton(
//                        color: Colors.transparent,
//                        onPressed: () {
//                          setState(() {
//                            percentage = newPercentage;
//                            newPercentage += 10;
//                            if (newPercentage > 100.0) {
//                              newPercentage = 0.0;
//                            }
//                            percentageAnimationController.forward(from: 0.0);
//                          });
//                        }),
                    child: new Column(
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

    var label = new Padding(
      padding: EdgeInsets.all(16.0),
      child: new Center(child: _getLabel()),
    );

    var playButton = new Padding(
      padding: EdgeInsets.all(0.0),
      child: Center(
        heightFactor: 1.5,
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
                  timePassed == 0 && actualStep == widget.trainArray.length - 1
                      ? Icons.beenhere
                      : trainStarted ? Icons.pause : Icons.directions_run,
                  size: 32.0,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
    var screen = new Column(
      children: <Widget>[roundClock, timer, label, playButton],
    );
    return screen;
  }

  String _getRemainTime() {
    if (timePassed == 0 && actualStep == widget.trainArray.length - 1) {
      return 'Parabéns!!';
    }
    if (widget.trainArray != null && widget.trainArray.length > 0) {
      var minutes = ((timePassed / 60)).floor();
      var seconds = (timePassed % 60);
      return formatter.format(minutes) + ':' + formatter.format(seconds);
    }
    return '00:00';
  }

  Widget _getLabel() {
    if (trainStarted) {
      if (timePassed <= 15) {
        if (actualStep == widget.trainArray.length - 1) {
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

    if (!trainStarted) {
      if (actualStep == 0 && widget.trainArray[actualStep]['time'] == timePassed) {
        return new Text(
          'Vamos começar...',
          style: TextStyle(fontSize: 24.0),
        );
      }
    }
    return new Text(
      'Vamos lá, continue...',
      style: TextStyle(fontSize: 24.0),
    );
  }

  void _onPlayButton() {
    setState(() {
      if (timePassed == 0 && actualStep == widget.trainArray.length - 1) {
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
              newPercentage = (widget.trainArray[actualStep]['time'] - timePassed) *
                  100 /
                  widget.trainArray[actualStep]['time'];
              percentageAnimationController.forward(from: 0.0);
            });
          }
        });
        sub.onDone(() {
          if (actualStep == widget.trainArray.length - 1) {
            _trainRef.child('status').set('finished');
          } else {
            actualStep++;
            setState(() {
              timePassed = widget.trainArray[actualStep]['time'];
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
    if (timePassed <= 15 && actualStep != widget.trainArray.length - 1 && trainStarted) {
      return [
        new Text(
          'Próxima velocidade...',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Text(
          '${widget.trainArray[actualStep + 1]['speed']}',
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
        '${widget.trainArray[actualStep]['speed']}',
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
          newPercentage = (widget.trainArray[actualStep]['time'] - timePassed) *
              100 /
              widget.trainArray[actualStep]['time'];
          percentageAnimationController.forward(from: 0.0);
        });
      }
    });
    sub.onDone(() {
      if (actualStep == widget.trainArray.length - 1) {
        _trainRef.child('status').set('finished');
      } else {
        actualStep++;
        setState(() {
          timePassed = widget.trainArray[actualStep]['time'];
          registerNewCountdown();
        });
      }
    });
  }
}
