import 'package:dartz/dartz.dart';

import 'data_manager.dart';
import 'usecase.dart';

abstract class UseCaseGenerator<D> {
  Map<Type, Tuple2<UseCase<dynamic, dynamic>, UseCaseMapFn<D, dynamic>?>>
      useCases = {};

  Map<Type,
          Tuple2<StreamingUseCase<dynamic, dynamic>, UseCaseMapFn<D, dynamic>?>>
      streamingUseCases = {};

  void addUseCase(UseCase<dynamic, dynamic> useCase) {
    final tuple = tuple2(useCase, null);

    useCases.putIfAbsent(useCase.runtimeType, () => tuple);
  }

  void addStreamingUseCase(StreamingUseCase<dynamic, dynamic> useCase) {
    final tuple = tuple2(useCase, null);

    streamingUseCases.putIfAbsent(useCase.runtimeType, () => tuple);
  }

  void addUseCaseWithMapFn<UP>(
    UseCase<dynamic, dynamic> useCase,
    UseCaseMapFn<D, dynamic> mapFn,
  ) {
    final tuple = tuple2(useCase, mapFn);

    useCases.putIfAbsent(useCase.runtimeType, () => tuple);
  }
}
