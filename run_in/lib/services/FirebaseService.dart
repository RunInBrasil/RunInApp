import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:run_in/objects/Train.dart';
import 'package:run_in/objects/TrainMetadata.dart';
import 'package:run_in/objects/TrainStep.dart';
import 'package:run_in/objects/User.dart';
import 'package:run_in/utils/GlobalState.dart';

const String UserKey = 'User';
const String TrainStatusKey = 'trainStatus';
const String EvaluationStatusKey = 'evaluationStatus';
const String TrainArrayKey = 'trainArray';
const String TrainRefKey = 'trainRef';
const String DayIndexKey = 'dayIndex';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;
GlobalState _store = GlobalState.instance;
FirebaseDatabase database;

DatabaseReference _userInfoRef;
DatabaseReference _trainMetadataRef;
DatabaseReference _trainRef;

Future configureFirebaseApp() async {
  await FirebaseApp.configure(
    name: 'RunIn',
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
}


void getInitialInfo() async {
//  _auth.signOut();
//  print('comecando');
//  print(await _auth.currentUser());
//  configureFirebaseApp();
  if (await isAuthenticated() == false) {
    return;
  }
  _store.set(_store.TRAIN_LOADED_KEY, false);
  configureReferences();
  await getUserInfo();
  getTrainMetadataInfo();
  await getTrainInfo();
}


void configureReferences() async {
  assert(_auth.currentUser() != null);
  _store = GlobalState.instance;
  FirebaseUser user = await _auth.currentUser();
  _userInfoRef =
      FirebaseDatabase.instance.reference().child('users').child(user.uid).child('user_info');
  _trainMetadataRef = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(user.uid)
      .child('train_metadata');
  _trainRef = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(user.uid)
      .child('train');

//  _store.set(_store.GENERAL_DOCTOR_REF_KEY, _generalDoctorsRef);
//  _store.set(_store.DOCTOR_REF_KEY, _doctorRef);
//  _store.set(_store.DUTY_REF_KEY, _dutiesRef);
//  _store.set(_store.SECTOR_REF_KEY, _sectorsRef);
}

Future<FirebaseUser> signInWithGoogle() async {
  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  assert(user.email != null);
  assert(user.displayName != null);
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);
  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  await getUserInfo();

  print("signed in " + user.displayName);
  return user;
}

Future<FirebaseUser> signInWithEmail(String email, String password) async {
  email = email.trim();
  password = password.trim();
  final firebaseUser = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);

  final FirebaseUser currentUser = await _auth.currentUser();

  assert(firebaseUser.uid == currentUser.uid);

  await getUserInfo();
  return firebaseUser;
}

Future<FirebaseUser> registerWithEmail(
    String email, String password, String name) async {
  email = email.trim();
  password = password.trim();
  final firebaseUser = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);

  final FirebaseUser currentUser = await _auth.currentUser();

  assert(firebaseUser.uid == currentUser.uid);

  User user = new User(firebaseUser.uid, name, email);

  await setUserInfo(user);
  return firebaseUser;
}

void getUserInfo() async {
  await configureReferences();

  DataSnapshot snapshot = await _userInfoRef.once();
  User user =
  new User(snapshot.value['uid'], snapshot.value['name'], snapshot.value['email']);
  if(snapshot.value['gender'] != null) {
    user.gender = snapshot.value['gender'];
  }
  _store.set(_store.USER_KEY, user);

  _userInfoRef.onValue.listen((event) {
    User user =
    new User(event.snapshot.value['uid'], event.snapshot.value['name'], event.snapshot.value['email']);
    if(event.snapshot.value['gender'] != null) {
      user.gender = event.snapshot.value['gender'];
    }
    _store.set(_store.USER_KEY, user);
  });

}

void setUserInfo(User user) async {
  await configureReferences();
  _userInfoRef.set(user.toMap());
//  FirebaseUser user = await _auth.currentUser();
//  _userInfoRef.child('uid').set(user.uid);
//  _userInfoRef.child('name').set(name);
//  _userInfoRef.child('email').set(email);
}

void setTrainMetadata (TrainMetadata metadata) async {
  await configureReferences();
  _trainMetadataRef.set(metadata.toMap());
}

void getTrainMetadataInfo() async {
  await configureReferences();
  _trainMetadataRef.onValue.listen((event) {
      TrainMetadata metadata = new TrainMetadata();
      metadata.status = event.snapshot.value['status'];
      metadata.daysPerWeek = event.snapshot.value['days_per_week'];
      metadata.evaluationSpeed = event.snapshot.value['evaluation_speed'];
      _store.set(_store.TRAIN_METADATA_KEY, metadata);
  });
}

void setTrain(Map train) async {
  await configureReferences();
  _trainRef.set(train);
}

void getTrainInfo() async {
  assert(await isAuthenticated());
  await configureReferences();
  User user = _store.get(_store.USER_KEY);

  final f = new DateFormat('yyyy-MM-dd');
  String today = f.format(new DateTime.now());

  DataSnapshot snapshot = await _trainRef.once();
  if (snapshot.value == null) {
    return;
  }
  List<Train> trains = new List();
  for (var trainKey in snapshot.value) {
    if (trainKey != null) {
      Train train = new Train();
      if (trainKey['finished'] != null) {
        train.finished = trainKey['finished'];
      }
      train.index = snapshot.value.indexOf(trainKey);
      for (var step in trainKey['train']) {
        TrainStep trainStep = new TrainStep(trainKey['train'].indexOf(step),
            step['speed'].toDouble(),
            step['time']);
        train.steps.add(trainStep);
      }
      trains.add(train);
    }
  }
  _store.set(_store.TRAIN_ARRAY_KEY, trains);




  _trainRef
//      .orderByChild('finished')
//      .equalTo(today)
      .onValue
      .listen((event) {
    if (event.snapshot.value == null) {
      return;
    }
    List<Train> trains = new List();
    for (var trainKey in event.snapshot.value) {
      if (trainKey != null) {
        Train train = new Train();
        if (trainKey['finished'] != null) {
          train.finished = trainKey['finished'];
        }
        train.index = event.snapshot.value.indexOf(trainKey);
        for (var step in trainKey['train']) {
          TrainStep trainStep = new TrainStep(trainKey['train'].indexOf(step),
              step['speed'].toDouble(),
              step['time']);
          train.steps.add(trainStep);
        }
        trains.add(train);
      }
    }
    _store.set(_store.TRAIN_ARRAY_KEY, trains);
  });
}

void concludeATrain(int index) {
  _trainRef.child('${index}').child('finished').set(new DateTime.now().toIso8601String().substring(0, 10));
}

Future<bool> isAuthenticated() async {
  return await _auth.currentUser() != null;
}
