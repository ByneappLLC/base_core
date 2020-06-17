import 'dart:async';

import 'package:base_core/base_core.dart';
import 'package:rxdart/rxdart.dart';

class DataManager<T, P> {
  DataManager(this.useCase, {T initData})
      : rx = BehaviorSubject<T>.seeded(initData);

  final _onFailure = PublishSubject<Failure>();
  final _getData = PublishSubject<P>();
  final _activityIndicator = ActivityIndicator();

  final BehaviorSubject<T> rx;
  final UseCase<P, T> useCase;

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
