import 'package:run_in/objects/TrainStep.dart';

class Train {
  List<TrainStep> steps = new List();
  String finished;
  int index;

  Map toMap() {
    return {
      'train': steps,
      'finished': finished
    };
  }

  @override
  String toString() {
    return {
      'train': steps,
      'finished': finished,
      'index': index
    }.toString();
  }


}
