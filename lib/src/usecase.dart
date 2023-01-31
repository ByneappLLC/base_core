import 'dart:async';

import 'package:base_core/src/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class StreamingUseCase<P, R> {
  @protected
  late Logger logger;

  StreamingUseCase() {
    logger = Logger(runtimeType.toString());
  }

  Stream<Either<Failure, R>> onError(Object object, StackTrace stackTrace);

  Stream<Either<Failure, R>> call(P param) => run(param).doOnError(onError);

  Stream<Either<Failure, R>> run(P param);
}

abstract class UseCase<P, R> {
  @protected
  late Logger logger;

  UseCase() {
    logger = Logger(runtimeType.toString());
  }

  Future<Either<Failure, R>> execute(P params);

  Stream<Either<Failure, R>> call(P params) => execute(params).asStream();

  Trampoline<Stream<Either<Failure, R>>> tStream(P params) =>
      treturn(call(params));

  Future<B> result<B>(P params, B Function(Either<Failure, R>) onResult) async {
    final result = await execute(params);
    return onResult(result);
  }
}

// A Usecase to be use inside a data manager
@mustCallSuper
abstract class DataManagerUseCase<P, R> extends UseCase<Tuple2<P, R>, R> {
  late Tuple2<P, R> _params;

  void params(Tuple2<P, R> params) {
    _params = params;
  }

  P get param => _params.value1;
  R get value => _params.value2;
}

@mustCallSuper
abstract class DataManagerStreamingUseCase<P, R>
    extends StreamingUseCase<Tuple2<P, R>, R> {
  late Tuple2<P, R> _params;

  void params(Tuple2<P, R> params) {
    _params = params;
  }

  P get param => _params.value1;
  R get value => _params.value2;
}
