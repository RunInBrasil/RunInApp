import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/tools/circlePainter.dart';
import 'package:run_in/tools/myDivider.dart';
import 'package:run_in/utils/constants.dart' as constants;


class SecondPage extends StatelessWidget {
  TabController _tabController;

  SecondPage(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    Widget roundClock = Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Center(
        child: PhysicalModel(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                width: 250.0,
                height: 250.0,
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(150.0),
                  color: Colors.transparent,
                ),
                child: new CustomPaint(
                  foregroundPainter: new MyPainter(
                      lineColor: Colors.transparent,
                      completeColor: Colors.white,
                      completePercent: 75.0,
                      width: 3.0),
                  child: new Center(
                    child: new Text(
                      '6',
                      style: new TextStyle(fontSize: 128.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Widget timer = new Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: new Text(
          '00:37',
          style: TextStyle(fontSize: 32.0, color: Colors.white),
        ),
      ),
    );

    Widget text = new Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        children: <Widget>[
          myDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: Text(
              'Vamos lá, as regras são simples: \n\n    - A velocidade que a esteira deve ficar esta indicada no número maior acima, no caso o número 6.\n    - A cada minuto a velocidade será aumentada em 1. \n    - Quando não aguentar mais correr, pare o treino e nos vamos desenvolver um plano de treinos especialmente para você.',
              style: new TextStyle(color: Colors.white, fontSize: 17.0),
            ),
          ),
          myDivider()
        ],
      ),
    );

    Widget proceedButton = FlatButton(onPressed: nextPage, child: Text('Vamos lá', style: new TextStyle(color: constants.textColor),));

    return new Scaffold(
      backgroundColor: Colors.transparent,
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[roundClock, timer, text, proceedButton],
    ));
  }

  nextPage() {
    final int newIndex = _tabController.index + 1;
    if (newIndex < 0 || newIndex >= _tabController.length) {
      return;
    }
    _tabController.animateTo(newIndex);
  }
}
