import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:run_in/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

const List<Text> menuItems = <Text>[
  const Text("Sair"),
];

class HomePage extends StatelessWidget {
  
  BuildContext baseContext;
  
  @override
  Widget build(BuildContext context) {
    baseContext = context;
    _checkIfLogged(context);
    return new Scaffold(
        appBar: new AppBar(
          title: Text('RunIn'),
          actions: <Widget>[
            new PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return menuItems.map((Text item) {
                  return new PopupMenuItem(
                    value: item.data,
                    child: item,
                  );
                }).toList();
              },
              onSelected: _handleMenuAction,
            )
          ],
        ),
        body: new HomePageFrame()
    );
  }


  void _handleMenuAction(String value) {
    switch (value) {
      case "Sair":
        _logOut();
        break;
    }
  }

  void _logOut() async {
    await _auth
        .signOut()
        .then((onValue) async {
      Navigator.of(baseContext).pushNamedAndRemoveUntil(
        '/login', (Route<dynamic> route) => false
      );
    });
  }

  void _checkIfLogged(BuildContext context) async {
    if (await _auth.currentUser() != null) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', (Route<dynamic> route) => false
    );
  }
}

class HomePageFrame extends StatefulWidget {

  @override
  _HomePageFrameState createState() => new _HomePageFrameState();
}

class _HomePageFrameState extends State<HomePageFrame> {
  @override
  Widget build(BuildContext context) {
    var todayTrain = new Card(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const ListTile(
            leading: const Icon(Icons.album),
            title: const Text('The Enchanted Nightingale'),
            subtitle: const Text(
                'Music by Julie Gable. Lyrics by Sidney Stein.'),
          ),
          new ButtonTheme
              .bar( // make buttons use the appropriate styles for cards
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {
                    /* ... */
                  },
                ),
                new FlatButton(
                  child: const Text('LISTEN'),
                  onPressed: () {
                    /* ... */
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return todayTrain;
  }

}