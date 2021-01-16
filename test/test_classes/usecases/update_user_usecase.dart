import 'package:base_core/base_core.dart';
import 'package:dartz/dartz.dart';

import '../failures.dart';
import '../user_model.dart';

const FIXED_NAME = 'Anthony';

class UpdateUserUseCase extends DataManagerUseCase<String, User> {
  @override
  Future<Either<Failure, User>> execute(Tuple2<String, User> params) async {
    super.params(params);

    if (param == null) {
      return left(NotFound());
    }

    final res = await Future.delayed(Duration(milliseconds: 500), updateUser);

    return right(res);
  }

  User updateUser() {
    return User.name.set(value, param);
  }
}
