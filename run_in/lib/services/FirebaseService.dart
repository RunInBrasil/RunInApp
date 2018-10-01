import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:run_in/utils/GlobalState.dart';

const String FirebaseAppKey = 'FirebaseApp';
const String UserUidKey = 'UserUid';
const String TrainStatusKey = 'trainStatus';
const String TrainArrayKey = 'trainArray';

final FirebaseAuth _auth = FirebaseAuth.instance;
GlobalState _store = GlobalState.instance;
FirebaseDatabase database;

Future configureFirebaseApp() async {
  FirebaseApp app = await FirebaseApp.configure(
    name: 'run-in',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:808188414561:ios:a1f5c1e0a4427dd3',
      gcmSenderID: '808188414561',
      apiKey: 'AIzaSyCPVxFP42DTFixgO9mTDoTep_OW-LTIA18',
      projectID: 'runin-d30a7',
      databaseURL: 'https://runin-d30a7.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:808188414561:android:0354ca0c79b55f65',
      apiKey: 'AIzaSyAAWl2MXOnpAUca6lly3wEru1ZoyCu3yFw',
      databaseURL: 'https://runin-d30a7.firebaseio.com',
    ),
  );
  database = new FirebaseDatabase(app: _store.get(FirebaseAppKey));
  _store.set(FirebaseAppKey, app);
}

void fetchInfoFromFirebase() async {
  FirebaseDatabase(app: _store.get(FirebaseAppKey));
  FirebaseUser user = await _auth.currentUser();
  if (user != null) {
    _store.set(UserUidKey, user.uid);
    await configureFirebaseApp();
    DatabaseReference _evaluationRef = FirebaseDatabase.instance
        .reference()
        .child('trains')
        .child(user.uid)
        .child('status');


    DataSnapshot snapshot = await _evaluationRef.once().timeout(
        Duration(seconds: 20));

    String evaluationStatus = snapshot.value;
    _store.set(TrainStatusKey, evaluationStatus);
    if (evaluationStatus != 'progress') {
      return;
//      return evaluationStatus;
    }

    _evaluationRef.keepSynced(true);

    final f = new DateFormat('yyyy-MM-dd');
    String today = f.format(new DateTime.now());

    DatabaseReference _trainRef = database
        .reference()
        .child('trains')
        .child(user.uid)
        .child('treinos');

    DataSnapshot trainSnapshot = await _trainRef
        .orderByChild('finished')
        .equalTo(f.format(new DateTime.now()))
        .once();

    if (trainSnapshot.value != null) {
      _store.set(TrainStatusKey, 'finished');
      List trainArray = new List();
      for (var key in snapshot.value.keys) {
        String dayIndex = key;
        for (int i = 0; i < snapshot.value[key].length - 1; i++) {
          trainArray.add(snapshot.value[key][i.toString()]);
        }
      }
      _store.set(TrainArrayKey, trainArray);
    } else {
      DataSnapshot trainSnapshot = await _trainRef
          .orderByChild('finished')
          .equalTo(null)
          .limitToFirst(1)
          .once();

      List trainArray = new List();
      if (trainSnapshot.value.keys != null) {
        for (var key in trainSnapshot.value.keys) {
          String dayIndex = key;
          for (var train in trainSnapshot.value[key]) {
            trainArray.add(train);
          }
        }
      } else {
        print(trainSnapshot.key);
        for (var key in trainSnapshot.value) {
          String dayIndex = '0';
          for (var train in key) {
            trainArray.add(train);
          }
        }
      }
      _store.set(TrainArrayKey, trainArray);
    }
    _trainRef.keepSynced(true);
  }
}
