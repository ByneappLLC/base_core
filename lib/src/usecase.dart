import 'dart:async';

import 'package:base_core/src/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

abstract class UseCase<P, R> {
  @protected
  Logger logger;

  UseCase() {
    logger = Logger(runtimeType.toString());
  }

  Future<Either<Failure, R>> execute(P params);

  Stream<Either<Failure, R>> call(P params) => execute(params).asStream();

  Future<B> result<B>(P params, B Function(Either<Failure, R>) onResult) async {
    final result = await execute(params);
    return onResult(result);
  }
}

// A Usecase to be use inside a data manager
abstract class DataManagerUseCase<P, R> extends UseCase<Tuple2<P, R>, R> {}
