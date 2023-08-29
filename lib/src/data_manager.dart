import 'dart:async';

import 'package:base_core/base_core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

typedef DataListener<T> = void Function(T);
typedef AsyncMapFn<T> = FutureOr<T> Function(T);
typedef MapStreamFn<T> = Stream<T> Function(T);

typedef UseCaseMapFn<D, P> = D Function(D, P);
typedef StreamingUseCaseMapFn<D, P> = D Function(D, P);

extension<T> on Stream<T> {
  Stream<T> optionalAsyncMap(AsyncMapFn<T>? fn) {
    if (fn != null) {
      return this.asyncMap(fn);
    } else {
      return this;
    }
  }

  Stream<T> optionalMap(MapStreamFn<T>? fn) {
    if (fn != null) {
      return this.switchMap(fn);
    } else {
      return this;
    }
  }

  Stream<T> optionallyNotifyListeners(
    ObserverList<DataListener<T>>? listeners,
  ) {
    if (listeners != null && listeners.isNotEmpty) {
      return this.doOnData((event) {
        listeners.forEach((fn) => fn(event));
      });
    } else {
      return this;
    }
  }
}

/// [D] data being managed
abstract class DataManager<D> {
  @protected
  late Logger logger;

  DataManager(
    UseCaseGenerator<D> useCaseGen, {
    D? initData,
    this.autoClearFns = true,
  })  : rx = initData != null
            ? BehaviorSubject<D>.seeded(initData)
            : BehaviorSubject<D>(),
        useCases = useCaseGen.useCases,
        streamingUseCases = useCaseGen.streamingUseCases {
    logger = Logger(runtimeType.toString());
  }

  final bool autoClearFns;
  final _onFailure = PublishSubject<Failure>();
  final _runUseCase = PublishSubject<
      Tuple2<Trampoline<Stream<Either<Failure, dynamic>>>,
          UseCaseMapFn<D, dynamic>?>>();
  final activityIndicator = ActivityIndicator();
  final onDone = PublishSubject();
  late CompositeSubscription compositeSubscription;

  Future<void> get waitDone => onDone.first;
  ObserverList<DataListener<D>> _listeners = ObserverList<DataListener<D>>();

  AsyncMapFn<D>? asyncMapFn;
  MapStreamFn<D>? mapStreamFn;

  void registerSubscription(CompositeSubscription subscription) {
    compositeSubscription = subscription;
    subscriber.addTo(compositeSubscription);
  }

  final BehaviorSubject<D> rx;
  Stream<D> get stream => rx.stream;
  D get value => rx.value;
  D? get valueOrNull => rx.valueOrNull;

  final Map<Type, Tuple2<UseCase<dynamic, dynamic>, UseCaseMapFn<D, dynamic>?>>
      useCases;

  final Map<Type,
          Tuple2<StreamingUseCase<dynamic, dynamic>, UseCaseMapFn<D, dynamic>?>>
      streamingUseCases;

  Stream<bool> get isLoading => activityIndicator.stream;
  Stream<Failure> get onFailure => _onFailure.stream;

  StreamSubscription get subscriber => _runUseCase
      .whereNotLoading(activityIndicator)
      .switchMap((t) => t.value1
          .run()
          .map((e) => e.map((d) => d is D ? d : t.value2!.call(value!, d)))
          .trackActivity(activityIndicator)
          .onFailureForwardTo(_onFailure)
          .optionalAsyncMap(asyncMapFn)
          .optionalMap(mapStreamFn)
          .optionallyNotifyListeners(_listeners)
          .doOnDone(_handleOnDone))
      .listen(rx.add);

  void _handleOnDone() {
    if (autoClearFns) {
      asyncMapFn = null;
      mapStreamFn = null;
    }
    onDone.add(null);
  }

  void runUseCase<U, P>(P params) {
    final tuple = useCases[U];
    final useCase = tuple!.value1;
    final mapFn = tuple.value2;

    Trampoline<Stream<Either<Failure, dynamic>>> runningUseCase;

    if (useCase is DataManagerUseCase) {
      runningUseCase = useCase.tStream(tuple2<P, D>(params, value));
    } else {
      runningUseCase = useCase.tStream(params);
    }
    _runUseCase.add(tuple2(runningUseCase, mapFn));
  }

  final Map<StreamingUseCase, StreamSubscription<D>> runningUseCaseStreams = {};

  void registerStreamingUseCase<U, P>(P params) {
    final tuple = streamingUseCases[U];

    final useCase = tuple!.value1;
    final mapFn = tuple.value2;

    if (runningUseCaseStreams.containsKey(useCase)) {
      logger.fine('Cannot register same stream twice');
      return;
    }

    final ss = useCase(useCase is DataManagerStreamingUseCase
            ? tuple2<P, BehaviorSubject<D>>(params, rx)
            : params)
        .onFailureForwardTo(_onFailure)
        .map((d) => d is D ? d : mapFn!.call(value, d))
        .listen(update);

    compositeSubscription.add(ss);
    runningUseCaseStreams.putIfAbsent(useCase, () => ss);
  }

  void deRegisterUseCase<U>() {
    final tuple = streamingUseCases[U];
    final useCase = tuple!.value1;

    final ss = runningUseCaseStreams[useCase];

    if (ss != null) {
      compositeSubscription.remove(ss);
      runningUseCaseStreams.remove(useCase);
    }
  }

  void update(D data) {
    rx.add(data);
  }

  void addListener(DataListener<D> listener) {
    _listeners.add(listener);
  }

  void removeListener(DataListener<D> listener) {
    _listeners.remove(listener);
  }

  @protected
  void close() {
    rx.close();
    _onFailure.close();
    _runUseCase.close();
    activityIndicator.close();
  }
}
