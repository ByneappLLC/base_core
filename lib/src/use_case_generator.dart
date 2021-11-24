import 'package:dartz/dartz.dart';

import 'data_manager.dart';
import 'usecase.dart';

abstract class UseCaseGenerator<D> {
  Map<Type, Tuple2<UseCase<dynamic, dynamic>, UseCaseMapFn<D, dynamic>?>>
      useCases = {};

  addUseCase(UseCase<dynamic, dynamic> useCase) {
    final tuple = tuple2(useCase, null);

    useCases.putIfAbsent(useCase.runtimeType, () => tuple);
  }

  addUseCaseWithMapFn<UP>(
    UseCase<dynamic, dynamic> useCase,
    UseCaseMapFn<D, dynamic> mapFn,
  ) {
    final tuple = tuple2(useCase, mapFn);

    useCases.putIfAbsent(useCase.runtimeType, () => tuple);
  }
}
