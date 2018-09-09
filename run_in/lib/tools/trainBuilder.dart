class TrainBuilder {
  int speedTest;
  int daysPerWeek;
  Map<String, Map<String, Map>> train;
  static const totalNumberOfWeeks = 12;

  Map<String, TrainModel> trainModel;

  static List<String> dificultyLevels = ['moderado', 'intenso1', 'intenso2', 'intenso3', 'severo1', 'severo2'];


  List<String> fiveDaysWeek = [
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[3],
    dificultyLevels[0],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[3],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[0],
    dificultyLevels[4],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[0],
    dificultyLevels[4],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[5],

    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[0],
    dificultyLevels[5],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[3],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[5],
  ];

  List<String> fourDaysWeek = [
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[3],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[3],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[4],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[5],

    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[5],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[5],
  ];

  List<String> threeDaysWeek = [
    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[0],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[3],

    dificultyLevels[0],
    dificultyLevels[1],
    dificultyLevels[0],

    dificultyLevels[3],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[4],
    dificultyLevels[0],
    dificultyLevels[5],

    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[5],
    dificultyLevels[0],
    dificultyLevels[3],

    dificultyLevels[1],
    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[0],
    dificultyLevels[0],
    dificultyLevels[5],
  ];

  List<String> twoDaysWeek = [
    dificultyLevels[0],
    dificultyLevels[0],

    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[0],
    dificultyLevels[3],

    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[3],
    dificultyLevels[0],

    dificultyLevels[1],
    dificultyLevels[4],

    dificultyLevels[1],
    dificultyLevels[5],

    dificultyLevels[1],
    dificultyLevels[4],

    dificultyLevels[0],
    dificultyLevels[1],

    dificultyLevels[0],
    dificultyLevels[5],

    dificultyLevels[0],
    dificultyLevels[4],

    dificultyLevels[1],
    dificultyLevels[5],
  ];

  TrainBuilder(int daysPerWeek, int speedTest) {
    this.speedTest = speedTest;
    this.daysPerWeek = daysPerWeek;
  }

  void build() {
    _generateTrainModel();
    _generateTrain();
  }

  void _generateTrainModel() {
    trainModel = new Map();
    trainModel['moderado'] = TrainModel([0.65], [30 * 60]);
    trainModel['intenso1'] = TrainModel([0.75, 0.0, 0.75, 0.0, 0.75], [8 * 60, 60, 8 * 60, 60, 8 * 60]);
//    trainModel['intenso2'] = TrainModel(0.80, []);
    trainModel['intenso3'] = TrainModel([0.95, 0.0, 0.95, 0.0, 0.95, 0.0, 0.95], [4 * 60, 90, 4 * 60, 90, 4 * 60, 90, 4 * 60]);
    trainModel['severo1'] =
        TrainModel([1.00, 0.0, 1.00, 0.0, 1.00, 0.0, 1.00, 0.0, 1.00, 0.0], [3 * 5 * 60, 120, 3 * 5 * 60, 120, 3 * 5 * 60, 120, 3 * 5 * 60, 120, 3 * 5 * 60]);
    trainModel['severo2'] =
        TrainModel([1.10, 0.0, 1.10, 0.0, 1.10, 0.0, 1.10, 0.0, 1.10, 0.0, 1.10], [60 * 2, 120, 60 * 2, 120, 60 * 2, 120, 60 * 2, 120, 60 * 2, 120, 60 * 2]);
  }

  void _generateTrain() {
    List plan = daysPerWeek == 2 ? fiveDaysWeek :
        daysPerWeek == 3 ? threeDaysWeek :
        daysPerWeek == 4 ? fourDaysWeek :
        fiveDaysWeek;

//    train = new List(plan.length);
    train = Map();
    int dayCounter = 0;
    int timeCounter;
    for (var day in plan) {
      timeCounter = 0;
      train[dayCounter.toString()] = new Map();
      for (var time in  trainModel[day].time) {
        train[dayCounter.toString()][timeCounter.toString()] = (new Train(trainModel[day].effort[timeCounter] * speedTest, time)).toJson();
        timeCounter++;
      }
      dayCounter++;
    }
  }

  Map<String, Map<String, Map>> getTrain() {
    return train;
  }

}

class Train {
  double speed;
  int time;

  Train(double speed, int time) {
    this.speed = speed;
    this.time = time;
  }

  Map<String, dynamic> toJson() =>
      {
        'speed': speed,
        'time': time,
      };
}

class TrainModel {
  List<int> time;
  List<double> effort;

  TrainModel(List<double> effort, List<int> time) {
    this.effort = effort;
    this.time = time;
  }
}