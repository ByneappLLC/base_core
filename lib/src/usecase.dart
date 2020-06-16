import 'dart:async';

import 'package:base_core/src/failure.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<P, R> {
  Future<Either<Failure, R>> execute(P params);

  Stream<Either<Failure, R>> call(P params) => execute(params).asStream();

  Future<B> result<B>(P params, B Function(Either<Failure, R>) onResult) async {
    final result = await execute(params);
    return onResult(result);
  }
}
