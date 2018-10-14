import 'package:run_in/objects/TrainStep.dart';

class Train {
  List<TrainStep> steps = new List();
  String finished;

  Map toMap() {
    return {
      'train': steps,
      'finished': finished
    };
  }
}
