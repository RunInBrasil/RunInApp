import 'package:flutter/material.dart';
import 'package:run_in/pre_intro/fifth_page.dart';
import 'package:run_in/pre_intro/first_page.dart';
import 'package:run_in/pre_intro/fourth_page.dart';
import 'package:run_in/pre_intro/second_page.dart';
import 'package:run_in/pre_intro/sixth_page.dart';
import 'package:run_in/pre_intro/third_page.dart';
import 'package:run_in/utils/constants.dart' as constants;


final String backgroundImagePath = "assets/images/pre_login_background.png";

class PreIntro extends StatefulWidget {
  @override
  TutorialState createState() => TutorialState();
}

class TutorialState extends State<PreIntro>
    with SingleTickerProviderStateMixin {
  List<Widget> pages = [];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    pages = [
      FirstPage(_tabController),
      SecondPage(_tabController),
      ThirdPage(_tabController),
      FourthPage(_tabController),
      FifthPage(_tabController),
//      SixthPage(_tabController)
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new AssetImage(
                backgroundImagePath),
        fit: BoxFit.cover)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Flexible(
            child: TabBarView(
                controller: _tabController,
                children: pages,
            ),
          ),
          new Container(
            color: constants.primaryColor,
            height: 64.0,
            child: new RaisedButton(onPressed:() => goLoginPage(),
                color: constants.primaryColor,
                child: new Text('Inscreva-se agora', style: new TextStyle(color: Colors.white, fontSize: 16.0),),)
            ),
        ],
      ),
    );
  }

  goLoginPage() {
    Navigator.pushNamed(context, '/login');
  }
}
