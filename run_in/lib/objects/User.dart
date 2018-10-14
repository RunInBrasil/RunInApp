
class User {
  String name;
  String uid;
  String email;
  String gender;

  final String FEMININE = 'feminino';
  final String MASCULINE = 'masculino';

  User(this.uid, this.name, this.email);

  Map toMap() {
    return {
      'name': name,
      'uid': uid,
      'email': email,
      'gender': gender
    };
  }
}
