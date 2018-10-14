class TrainMetadata {
  int daysPerWeek;
  int evaluationSpeed;
  String status;
  String startDate;

  Map toMap() {
    return {
      'days_per_week': daysPerWeek,
      'evaluation_speed': evaluationSpeed,
      'status': status,
      'start_date': startDate
    };
  }
}