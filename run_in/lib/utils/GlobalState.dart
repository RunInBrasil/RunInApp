class GlobalState {

  final String USER_KEY = 'User';
  final String TRAIN_METADATA_KEY = 'train_key';
  final String TRAIN_ARRAY_KEY = 'train_array_key';
  final String DayIndexKey = 'dayIndex';
  final String TRAIN_LOADED_KEY = 'train_loaded';

  final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
  static GlobalState instance = new GlobalState._();
  GlobalState._();

  set(dynamic key, dynamic value) => _data[key] = value;
  get(dynamic key) => _data[key];
}