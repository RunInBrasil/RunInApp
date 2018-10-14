import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/objects/TrainMetadata.dart';
import 'package:run_in/tools/myDivider.dart';
import 'package:run_in/tools/roundedOutlineButtom.dart';
import 'package:run_in/utils/constants.dart' as constants;
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;



class ThirdPage extends StatelessWidget {
  TabController _tabController;

  ThirdPage(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          new Spacer(),
          new Card(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(32.0)
            ),
            color: constants.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mas antes...',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    ),
                  ),
                  myDivider(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nos diga quantas vezes você consegue treinar por semana.',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
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
            ),
          ),
          new Spacer()
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
    TrainMetadata metadata = new TrainMetadata();
    metadata.daysPerWeek = numOfDays;
    FirebaseService.setTrainMetadata(metadata);
  }
}
