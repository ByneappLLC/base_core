import 'package:base_core/base_core.dart';
import 'package:dartz/dartz.dart';

import '../user_model.dart';

const WRONG_NAME = 'Anothony';

class GetUserUseCase extends UseCase<int, User> {
  @override
  Future<Either<Failure, User>> execute(int params) async {
    final res = await Future.delayed(
      Duration(milliseconds: 500),
      () => User(1, WRONG_NAME, 'Tony', 'Hello all, my name is Tony', 20),
    );

    return right(res);
  }
}
