import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
                'Nos diga quantas vezes você pretende treinar por semana.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          myDivider(),
          myRoundedOutlineButtom(
            text: 'Duas vezes',
              onPressed: () => _onButtonPressed(2)
          ),
          myRoundedOutlineButtom(
              text: 'Três vezes',
              onPressed: () => _onButtonPressed(3)
          ),
          myRoundedOutlineButtom(
              text: 'Quatro vezes',
              onPressed: () => _onButtonPressed(4)
          ),
          myRoundedOutlineButtom(
              text: 'Cinco vezes',
              onPressed: () => _onButtonPressed(5)
          )
        ],
      ),
    );
  }

  void _onButtonPressed(int numOfDays) {
    _saveDaysPerWeek(numOfDays);
    nextPage();
  }

  nextPage() {
    final int newIndex = _tabController.index + 1;
    if (newIndex < 0 || newIndex >= _tabController.length) {
      return;
    }
    _tabController.animateTo(newIndex);
  }

  void _saveDaysPerWeek(int numOfDays) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    FirebaseDatabase.instance.reference().child('train')
    .child(user.uid)
    .child('days_per_week')
    .set(numOfDays);
  }
}
