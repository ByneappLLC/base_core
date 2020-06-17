import 'dart:async';

import 'package:base_core/base_core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// [D] data being managed
/// [U] usecases to load or manipulate data from db or api
abstract class DataManager<D, U extends UseCase<dynamic, D>> {
  DataManager(this.useCases, {D initData})
      : rx = initData != null
            ? BehaviorSubject<D>.seeded(initData)
            : BehaviorSubject<D>();

  final _onFailure = PublishSubject<Failure>();
  final _runUseCase = PublishSubject<Tuple2<Type, dynamic>>();
  final _activityIndicator = ActivityIndicator();
  final onDone = PublishSubject();

  Future<void> waitDone() => onDone.first;

  final BehaviorSubject<D> rx;
  Stream<D> get stream => rx.stream;
  D get value => rx.value;
  //final U useCase;

  final Iterable<U> useCases;

  Stream<bool> get isLoading => _activityIndicator.stream;
  Stream<Failure> get onFailure => _onFailure.stream;

  StreamSubscription get subscriber => _runUseCase
      .whereNotLoading(_activityIndicator)
      .switchMap((p) => useCases
          .where((u) => u.runtimeType == p.value1)
          .first(p.value2)
          .trackActivity(_activityIndicator)
          .onFailureForwardTo(_onFailure)
          .doOnDone(() => onDone.add(null)))
      .listen(rx.add);

  void runUseCase<U, P>([P params]) {
    _runUseCase.add(tuple2(U, params));
  }

  void update(D data) {
    rx.add(data);
  }

  @protected
  void close() {
    rx.close();
    _onFailure.close();
    _runUseCase.close();
    _activityIndicator.close();
  }
}
