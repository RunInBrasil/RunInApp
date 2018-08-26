import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/tools/myDivider.dart';
import 'package:run_in/tools/roundedOutlineButtom.dart';

class ThirdPage extends StatelessWidget {
  TabController _tabController;

  ThirdPage(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Container(
            height: 64.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mas antes...',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          myDivider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Queremos saber um pouco sobre você, os diga mais ou menos seu nível de treino.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          myDivider(),
          myRoundedOutlineButtom(
            text: 'Nunca corro',
              onPressed: _onButtonPressed
          ),
          myRoundedOutlineButtom(
              text: 'Uma vez por semana',
              onPressed: _onButtonPressed
          ),
          myRoundedOutlineButtom(
              text: 'Três vezes por semana',
              onPressed: _onButtonPressed
          ),
          myRoundedOutlineButtom(
              text: 'Todo dia',
              onPressed: _onButtonPressed
          )
        ],
      ),
    );
  }

  void _onButtonPressed() {
    print('OLAAAA');
  }
}
