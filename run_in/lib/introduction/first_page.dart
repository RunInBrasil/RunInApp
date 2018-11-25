import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:run_in/objects/User.dart';
import 'package:run_in/utils/GlobalState.dart';
import 'package:run_in/utils/constants.dart' as constants;



class FirstPage extends StatelessWidget {
  TabController _tabController;
  BuildContext context;
  GlobalState _store;

  FirstPage(TabController tabController) {
    this._tabController = tabController;
    _store = GlobalState.instance;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
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
                    new Container(
                      height: 128.0,
                      width: 128.0,
                      child: new Icon(Icons.account_circle,
                      size: 128.0,
                      color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: new Text(getTitle(),
                          style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: new Container(
                        child: new Text(constants.firstPageText,
                          style: new TextStyle(fontSize: 16.0, color: Colors.white),),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: FlatButton(onPressed: _logOut, child: new Text('Sair', style: new TextStyle(color: Colors.white),)
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: FlatButton(onPressed: changePage, child: new Text('Continuar', style: new TextStyle(color: Colors.white))
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    return view;
  }

  changePage() {
    final int newIndex = _tabController.index + 1;
    if (newIndex < 0 || newIndex >= _tabController.length) {
      return;
    }
    _tabController.animateTo(newIndex);
  }

  void _logOut() async {
    await FirebaseAuth.instance.signOut().then((onValue) async {
      Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    });
  }

  String getTitle() {
    User user = _store.get(_store.USER_KEY);
    return 'Bem-vindo, ${user.name}. Você está dentro.';
  }
}
