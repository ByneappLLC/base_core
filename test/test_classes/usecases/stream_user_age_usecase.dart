import 'package:base_core/src/failure.dart';
import 'package:base_core/src/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../failures.dart';
import '../user_model.dart';

class StreamUserAgeUseCase extends DataManagerStreamingUseCase<int?, User> {
  @override
  Either<Failure, User> onError(Object object, StackTrace stackTrace) {
    return left(NotFound());
  }

  @override
  Stream<Either<Failure, User>> run(Tuple2<int?, BehaviorSubject<User>> param) {
    super.params(param);

    return Stream.periodic(Duration(milliseconds: 700), (_) {
      final current = value.value;

      final updatedAge = User.age.get(current) + 1;

      return right(User.age.set(current, updatedAge));
    });
  }
}
