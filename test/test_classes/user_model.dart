import 'package:dartz/dartz.dart';

class User {
  final String _name, _nickname, _intro;
  final int _id, _age;

  User(this._id, this._name, this._nickname, this._intro, this._age);

  User _copy({
    int? id,
    String? name,
    String? nickname,
    String? intro,
    int? age,
  }) =>
      User(
        id ?? this._id,
        name ?? this._name,
        nickname ?? this._nickname,
        intro ?? this._intro,
        age ?? this._age,
      );

  static final id = lensS<User, int>(
    (u) => u._id,
    (u, i) => u._copy(id: i),
  );

  static final name = lensS<User, String>(
    (u) => u._name,
    (u, n) => u._copy(name: n),
  );

  static final nickName = lensS<User, String>(
    (u) => u._nickname,
    (u, n) => u._copy(nickname: n),
  );

  static final intro = lensS<User, String>(
    (u) => u._intro,
    (u, i) => u._copy(intro: i),
  );

  static final age = lensS<User, int>(
    (u) => u._age,
    (u, a) => u._copy(age: a),
  );
}
