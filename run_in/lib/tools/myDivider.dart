import 'package:flutter/material.dart';

class myDivider extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: SizedBox(
        width: 410.0,
        height: 1.0,
        child: DecoratedBox(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                begin: new Alignment(-2.5, 0.0),
                end: new Alignment(2.5, 0.0),
                colors: [Colors.transparent, Colors.white, Colors.transparent],
              )
          ),
        ),
      ),
    );
  }

}