import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/objects/User.dart';
import 'package:run_in/utils/constants.dart' as constants;
import 'package:run_in/utils/GlobalState.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;



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
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: new Card(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(32.0)
                ),
                color: constants.primaryColor,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: new Text('Conte-nos sobre você',
                          style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new OutlineButton(onPressed:() => setGender('masculino'),
                            child: new Text('Masculino',
                            style: new TextStyle(color: Colors.white),),),
                            new OutlineButton(onPressed:() => setGender('feminino'),
                            child: new Text('Feminino',
                              style: new TextStyle(color: Colors.white),),),
                          ],
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Divider(
                height: 16.0,
                color: Colors.white,
                indent: 16.0,
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
