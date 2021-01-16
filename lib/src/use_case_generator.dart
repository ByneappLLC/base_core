import 'package:dartz/dartz.dart';

import 'data_manager.dart';
import 'usecase.dart';

abstract class UseCaseGenerator<D> {
  Map<Type, Tuple2<UseCase<dynamic, dynamic>, UseCaseMapFn<D, dynamic>>>
      useCases;

  addUseCase(UseCase<dynamic, dynamic> useCase) {
    final tuple = tuple2(useCase, null);

    if (useCases != null) {
      useCases.putIfAbsent(useCase.runtimeType, () => tuple);
    } else {
      useCases = {useCase.runtimeType: tuple};
    }
  }

  addUseCaseWithMapFn(
    UseCase<dynamic, dynamic> useCase,
    UseCaseMapFn<D, dynamic> mapFn,
  ) {
    final tuple = tuple2(useCase, mapFn);
    if (useCases != null) {
      useCases.putIfAbsent(useCase.runtimeType, () => tuple);
    } else {
      useCases = {useCase.runtimeType: tuple};
    }
  }
}
