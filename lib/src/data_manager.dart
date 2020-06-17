import 'dart:async';

import 'package:base_core/base_core.dart';
import 'package:rxdart/rxdart.dart';

class DataManager<D, P, U extends UseCase<P, D>> {
  DataManager(this.useCase, {D initData})
      : rx = initData != null
            ? BehaviorSubject<D>.seeded(initData)
            : BehaviorSubject<D>();

  final _onFailure = PublishSubject<Failure>();
  final _getData = PublishSubject<P>();
  final _activityIndicator = ActivityIndicator();

  final BehaviorSubject<D> rx;
  Stream<D> get stream => rx.stream;
  D get value => rx.value;
  final U useCase;

  Stream<bool> get isLoading => _activityIndicator.stream;
  Stream<Failure> get onFailure => _onFailure.stream;

  StreamSubscription get subscriber => _getData
      .whereNotLoading(_activityIndicator)
      .switchMap((params) => useCase(params)
          .trackActivity(_activityIndicator)
          .onFailureForwardTo(_onFailure))
      .listen(rx.add);

  void getData([P params]) {
    _getData.add(params);
  }

  void close() {
    rx.close();
    _onFailure.close();
    _getData.close();
    _activityIndicator.close();
  }
}
