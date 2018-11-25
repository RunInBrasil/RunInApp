import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:run_in/utils/constants.dart' as constants;

class myRoundedOutlineButtom extends StatelessWidget {
  final String text;
  final Function onPressed;

  const myRoundedOutlineButtom({
    Key key,
    @required this.text,
    @required this.onPressed,
  })  : assert(text != null),
        assert(onPressed != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
      child: Center(
        child: Container(
          width: 200.0,
          height: 50.0,
          child: BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: new OutlineButton(
                borderSide: BorderSide(color: Colors.white),
                color: Colors.transparent,
                onPressed: onPressed,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(24.0),
                ),
                child: BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                    child: Text(text, style: new TextStyle(color: constants.textColor),))),
          ),
        ),
      ),
    );
  }
}
