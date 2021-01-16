import 'package:base_core/base_core.dart';
import 'package:dartz/dartz.dart';

import '../user_model.dart';

class UserAge {
  final int id, age;

  UserAge(this.id, this.age);
}

class GetUserAges extends UseCase<String, List<UserAge>> {
  static User mapToUser(User user, dynamic users) {
    final currentUser = User.id.get(user);
    return User.age.set(user,
        (users as List<UserAge>).firstWhere((u) => u.id == currentUser).age);
  }

  @override
  Future<Either<Failure, List<UserAge>>> execute(String params) async {
    return right([
      UserAge(1, 21),
      UserAge(2, 25),
      UserAge(3, 27),
      UserAge(4, 56),
      UserAge(5, 72),
      UserAge(6, 29),
      UserAge(7, 22),
      UserAge(8, 19),
    ]);
  }
}
