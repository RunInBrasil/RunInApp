import 'package:flutter/material.dart';
import 'package:run_in/introduction/fifth_page.dart';
import 'package:run_in/introduction/first_page.dart';
import 'package:run_in/introduction/fourth_page.dart';
import 'package:run_in/introduction/second_page.dart';
import 'package:run_in/introduction/sixth_page.dart';
import 'package:run_in/introduction/third_page.dart';

final String backgroundImagePath = "assets/images/tutorial_cover.jpg";

class Tutorial extends StatefulWidget {
  @override
  TutorialState createState() => TutorialState();
}

class TutorialState extends State<Tutorial>
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
      child: TabBarView(
          controller: _tabController,
          children: pages,
      ),
    );
  }
}
