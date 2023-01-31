import 'package:base_core/src/failure.dart';
import 'package:base_core/src/usecase.dart';
import 'package:dartz/dartz.dart';

import '../user_model.dart';

class StreamUserAgeUseCase extends DataManagerStreamingUseCase<int, User> {
  @override
  Either<Failure, User> onError(Object object, StackTrace stackTrace) {
    // TODO: implement onError
    throw UnimplementedError();
  }

  @override
  Stream<Either<Failure, User>> run(Tuple2<int, User> param) {
    super.params(param);

    final updateAge = User.age.get(value) + 1;

    return Stream.periodic(Duration(seconds: 1), (i) {
      return right(User.age.set(value, updateAge));
    });
  }
}
