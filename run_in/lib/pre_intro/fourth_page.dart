import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/objects/User.dart';
import 'package:run_in/utils/GlobalState.dart';
import 'package:run_in/services/FirebaseService.dart' as FirebaseService;

final String image = 'assets/images/fourth_page.jpg';
final String title = 'Suas metas importam.';
final String body = 'Cada treino conta, e muito! Mesmo aqueles que você gostaria de não ter feito. Acompanhe suas estatísticas para ver o seu progresso a cada passo dado.';


class FourthPage extends StatelessWidget {
  TabController _tabController;
  GlobalState _store;

  FourthPage(TabController tabController) {
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
}
