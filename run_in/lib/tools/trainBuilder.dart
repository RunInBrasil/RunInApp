class TrainBulder {
  int speedTest;
  int daysPerWeek;
  List treino = [];
  const totalNumberOfWeeks = 12;

  Map<String, TrainModel> trainModel;

  List<String> fiveDaysWeek = [
    'moderado',
    'moderado',
    'moderado',
    'intenso1',
    'moderado',

    'moderado',
    'intenso1',
    'moderado',
    'intenso1',
    'moderado',

    'moderado',
    'intenso1',
    'moderado',
    'intenso3',
    'moderado'
  ]

  TrainBulder(int daysPerWeek, int speedTest) {
    this.speedTest = speedTest;
    this.daysPerWeek = daysPerWeek;
  }

  void build() {
    _generateTrainModel();
  }

  void _generateTrainModel() {
    trainModel['moderado'] = TrainModel(0.65, [30 * 60]);
    trainModel['intenso1'] = TrainModel(0.75, [8 * 60, 8 * 60, 8 * 60]);
//    trainModel['intenso2'] = TrainModel(0.80, []);
    trainModel['intenso3'] = TrainModel(0.95, [4 * 60, 4 * 60, 4 * 60, 4 * 60]);
    trainModel['severo1'] =
        TrainModel(1.00, [3 * 5, 3 * 5, 3 * 5, 3 * 5, 3 * 5]);
    trainModel['severo1'] =
        TrainModel(1.10, [6 * 2, 6 * 2, 6 * 2, 6 * 2, 6 * 2, 6 * 2]);
  }

}

class TrainModel {
  List<int> time;
  double effort;

  TrainModel(double effort, List<int> time) {
    this.effort = effort;
    this.time = time;
  }
}