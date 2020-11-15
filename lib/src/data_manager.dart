import 'dart:async';

import 'package:base_core/base_core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

typedef DataListener<T> = void Function(T);
typedef AsyncMapFn<T> = FutureOr<T> Function(T);
typedef MapStreamFn<T> = Stream<T> Function(T);

extension<T> on Stream<T> {
  Stream<T> optionalAsyncMap(AsyncMapFn<T> fn) {
    if (fn != null) {
      return this.asyncMap(fn);
    } else {
      return this;
    }
  }

  Stream<T> optionalMap(MapStreamFn<T> fn) {
    if (fn != null) {
      return this.switchMap(fn);
    } else {
      return this;
    }
  }

  Stream<T> optionallyNotifyListeners(ObserverList<DataListener<T>> listeners) {
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
  Logger logger;

  DataManager(this.useCases, {D initData, this.autoClearFns = true})
      : rx = initData != null
            ? BehaviorSubject<D>.seeded(initData)
            : BehaviorSubject<D>() {
    logger = Logger(runtimeType.toString());
  }

  final bool autoClearFns;
  final _onFailure = PublishSubject<Failure>();
  final _runUseCase = PublishSubject<Tuple2<Type, dynamic>>();
  final activityIndicator = ActivityIndicator();
  final onDone = PublishSubject();

  Future<void> get waitDone => onDone.first;
  ObserverList<DataListener<D>> _listeners = ObserverList<DataListener<D>>();

  AsyncMapFn<D> asyncMapFn;
  MapStreamFn<D> mapStreamFn;

  final BehaviorSubject<D> rx;
  Stream<D> get stream => rx.stream;
  D get value => rx.value;

  final Iterable<UseCase<dynamic, D>> useCases;

  Stream<bool> get isLoading => activityIndicator.stream;
  Stream<Failure> get onFailure => _onFailure.stream;

  StreamSubscription get subscriber => _runUseCase
      .whereNotLoading(activityIndicator)
      .switchMap((p) => useCases
              .where((u) => u.runtimeType == p.value1)
              .first(p.value2)
              .trackActivity(activityIndicator)
              .onFailureForwardTo(_onFailure)
              .optionalAsyncMap(asyncMapFn)
              .optionalMap(mapStreamFn)
              .optionallyNotifyListeners(_listeners)
              .doOnDone(() {
            if (autoClearFns) {
              asyncMapFn = null;
              mapStreamFn = null;
            }
            onDone.add(null);
          }))
      .listen(rx.add);

  void runUseCase<U, P>([P params]) {
    _runUseCase.add(tuple2(U, params));
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
    _listeners = null;
  }
}
