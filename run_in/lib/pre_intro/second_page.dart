import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/objects/User.dart';
import 'package:run_in/utils/constants.dart' as constants;
import 'package:run_in/utils/GlobalState.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;

final String image = 'assets/images/first_page.png';
final String title = 'Correr na esteira pode ser DIVERTIDO.';
final String body = 'A esteira do seu condomínio, hotel ou academia pode ser sua grande aliada em busca da sua alta performance. Com treinos divertidos e desafiadores você alcançará outro nível de condicionamento.';


class SecondPage extends StatelessWidget {
  TabController _tabController;
  GlobalState _store;

  SecondPage(TabController tabController) {
    this._tabController = tabController;
    _store = GlobalState.instance;
  }

  @override
  Widget build(BuildContext context) {
    Widget view = Material(
      color: Colors.transparent,
      child: new Align(
        alignment: FractionalOffset(0.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Spacer(),
            new Container(
              height: 164.0,
              decoration: new BoxDecoration(
                image: new DecorationImage(image: new AssetImage(image))
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: new Container(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: new Text(title,
                          textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.white, fontSize: 24.0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                      child: new Text(body,
                        textAlign: TextAlign.center,
                        style: new TextStyle(color: Colors.white, fontSize: 18.0),)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return view;

  }

  nextPage() {
    final int newIndex = _tabController.index + 1;
    if (newIndex < 0 || newIndex >= _tabController.length) {
      return;
    }
    _tabController.animateTo(newIndex);
  }

  setGender(String s) {
    User user = _store.get(_store.USER_KEY);
    user.gender = s;
    FirebaseService.setUserInfo(user);
    nextPage();
  }
}
