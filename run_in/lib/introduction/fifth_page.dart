import 'package:flutter/material.dart';
import 'package:run_in/tools/myDivider.dart';
import 'package:run_in/tools/roundedOutlineButtom.dart';
import 'package:run_in/utils/constants.dart' as constants;


class FifthPage extends StatelessWidget{

  BuildContext context;
  TabController _tabController;

  FifthPage(TabController tabController) {
    this._tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Material(
      color: constants.primaryColor,
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
                'Parabéns!!!',
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
                'Você mandou muiito bem!!! Agora nos temos as informações que precisavamos, agora vamos criar um treino especial para você, se quiser, já pode iniciar hoje.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          myDivider(),
          myRoundedOutlineButtom(
              text: 'Continuar',
              onPressed: _navigateToMainPage
          ),
        ],
      ),
    );
  }

  void _navigateToMainPage() {
    Navigator
        .of(context)
        .pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
  }
}