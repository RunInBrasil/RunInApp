import 'package:flutter/material.dart';

class FirstPage extends StatelessWidget {
  TabController _tabController;

  FirstPage(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    Widget view = new Align(
      alignment: FractionalOffset(0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: new Container(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 16.0),
                child: Container(
                  height: 200.0,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 32.0),
                        child: Text('   O RunIn procura trazer uma experiência 100% personalizada.\n     Para isso tudo que precisaremos é uma esteira.\n    Torquent lobortis euismod sit sodales primis mauris maecenas tortor etiam vel.Vulputate leo curabitur cubilia magna a condimentum at aliquam, integer aenean curabitur litora ac dui mauris lacus, auctor aliquam libero purus et mattis lectus tempus aliquam rutrum class turpis netus potenti, mattis taciti mattis pellentesque senectus, elit habitant curabitur euismod tempus',
                          style: new TextStyle(color: Colors.black,
                          fontSize: 17.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Divider(
              height: 16.0,
              color: Colors.white,
              indent: 16.0,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FlatButton(onPressed: changePage, child: new Text('Continuar >')
                ),
              )
            ],
          ),
        ],
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
}
