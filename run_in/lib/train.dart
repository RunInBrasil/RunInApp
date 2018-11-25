import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:run_in/objects/TrainStep.dart';
import 'package:run_in/tools/circlePainter.dart';
import 'package:countdown/countdown.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;


final FirebaseAuth _auth = FirebaseAuth.instance;
final backgroundColor = Color(0xCC000000);
final String backgroundImagePath = "assets/images/prepare_to_run.jpg";


class TrainPage extends StatelessWidget {
  BuildContext baseContext;
  List<TrainStep> trainArray;
  int dayIndex;

  TrainPage(List<TrainStep> trainInfo, int day) {
    this.trainArray = trainInfo;
    this.dayIndex = day;
  }

  @override
  Widget build(BuildContext context) {
    if (trainArray == null || trainArray.length == 0) {
      Navigator.of(baseContext).pushNamed('/home');
    }
    baseContext = context;
    return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(image: new AssetImage(backgroundImagePath),
            fit: BoxFit.cover
          )
      ),
      child: new Scaffold(
        backgroundColor: Colors.transparent,
          body: new TrainPageFrame(trainArray, dayIndex)
          ),
    );
  }
}

class TrainPageFrame extends StatefulWidget {
  FirebaseApp app;
  FirebaseUser user;
  List<TrainStep> trainArray;
  int dayIndex;

  TrainPageFrame(List<TrainStep> trainArray, int day) {
    this.trainArray = trainArray;
    this.dayIndex = day;
  }

  @override
  _TrainPageFrameState createState() {
    return new _TrainPageFrameState();
  }

  Future getUser() async {
    user = await _auth.currentUser();
  }
}

class _TrainPageFrameState extends State<TrainPageFrame>
    with TickerProviderStateMixin {
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

    setState(() {
      timePassed = widget.trainArray[actualStep].time;
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
  void dispose() {
    percentageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var roundClock = Padding(
      padding: EdgeInsets.fromLTRB(0.0, Platform.isIOS ? 0.0 : 32.0, 0.0, 0.0),
      child: Center(
        child: PhysicalModel(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
              child: new Container(
                width: 300.0,
                height: 300.0,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(150.0),
                  color: backgroundColor,
                ),
                child: new CustomPaint(
                  foregroundPainter: new MyPainter(
                      lineColor: Colors.transparent,
                      completeColor: Colors.white,
                      completePercent: percentage,
                      width: 4.0),
                  child: new Center(
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
          style: TextStyle(fontSize: 32.0, color: Colors.white),
        ),
      ),
    );

    var label = new Padding(
      padding: EdgeInsets.only(top: 16.0),
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
            filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: new FlatButton(
              color: backgroundColor,
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

    var backButton = new Padding(padding: EdgeInsets.only(top: 42.0),
      child: Container(
        alignment: Alignment(-1.0, 3.0),
        child: FlatButton(onPressed: () { Navigator.pop(context);}, child: Icon(
            Icons.arrow_back_ios,
            size: 32.0,
            color: Colors.white)
        ),
      ),
    );

    var childs = [roundClock, timer, label, playButton];
    if (Platform.isIOS) {
      childs.insert(0, backButton);
    }
    var screen = new Column(
      children: childs,
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
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            );
          }
          return new Text(
            'Estamos acabando',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          );
        }
        return new Text(
          'Preparar para a próxima velocidade...',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        );
      }
      return new Text(
        '${actualStep + 1}o Round',
        style: TextStyle(fontSize: 24.0, color: Colors.white),
      );
    }

    if (!trainStarted) {
      if (actualStep == 0 &&
          widget.trainArray[actualStep].time == timePassed) {
        return new Text(
          'Vamos começar...',
          style: TextStyle(fontSize: 24.0, color: Colors.white),
        );
      }
    }
    return new Text(
      'Vamos lá, continue...',
      style: TextStyle(fontSize: 24.0, color: Colors.white),
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
              newPercentage =
                  (widget.trainArray[actualStep].time - timePassed) *
                      100 /
                      widget.trainArray[actualStep].time;
              percentageAnimationController.forward(from: 0.0);
            });
          }
        });
        sub.onDone(() {
          if (actualStep == widget.trainArray.length - 1) {
            _registerTrainFinished();
          } else {
            actualStep++;
            setState(() {
              timePassed = widget.trainArray[actualStep].time;
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
    if (timePassed <= 15 &&
        actualStep != widget.trainArray.length - 1 &&
        trainStarted) {
      if (widget.trainArray[actualStep + 1].speed == 0) {
        return [
          Spacer(),
          new Text(
            'Próxima passo...',
            style: new TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          new Text(
            'Descanso',
            style: new TextStyle(fontSize: 48.0, color: Colors.white),
          ),
          Spacer()
        ];
      }
      return [
        Spacer(),
        new Text(
          'Próxima velocidade...',
          style: new TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        new Text(
          '${widget.trainArray[actualStep + 1].speed}',
          style: new TextStyle(fontSize: 96.0, color: Colors.white),
        ),
        new Text(
          'Km/h',
          style: new TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        Spacer()
      ];
    }

    return [
      Spacer(),
      new Text(
        '${widget.trainArray[actualStep].speed}',
        style: new TextStyle(fontSize: 96.0, color: Colors.white),
      ),
      new Text(
        'Km/h',
        style: new TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      Spacer(),
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
          newPercentage = (widget.trainArray[actualStep].time - timePassed) *
              100 /
              widget.trainArray[actualStep].time;
          percentageAnimationController.forward(from: 0.0);
        });
      }
    });
    sub.onDone(() {
      if (actualStep == widget.trainArray.length - 1) {
        _registerTrainFinished();
      } else {
        actualStep++;
        setState(() {
          timePassed = widget.trainArray[actualStep].time;
          registerNewCountdown();
        });
      }
    });
  }

  void _registerTrainFinished() {
    FirebaseService.concludeATrain(widget.dayIndex);
  }
}
