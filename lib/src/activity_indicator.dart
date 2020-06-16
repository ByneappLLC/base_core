import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class ActivityIndicator extends Stream<bool> implements ValueStream<bool> {
  final BehaviorSubject<int> _loadingCounter = BehaviorSubject.seeded(0);

  ActivityIndicator();

  @override
  bool get value => _loadingCounter.value > 0;
  Stream<bool> get stream => _loadingCounter.map((event) => event > 0);

  void _increment() {
    _loadingCounter.value = _loadingCounter.value + 1;
  }

  void _decrement() {
    _loadingCounter.value = _loadingCounter.value - 1;
  }

  void close() {
    _loadingCounter.close();
  }

  @override
  StreamSubscription<bool> listen(void Function(bool event) onData,
          {Function onError, void Function() onDone, bool cancelOnError}) =>
      stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  bool get hasValue => _loadingCounter.hasValue;
}

class _ActivityIndicatorTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  _ActivityIndicatorTransformer(ActivityIndicator indicator)
      : _transformer = StreamTransformer.fromHandlers(handleDone: (sink) {
          indicator._decrement();
          sink.close();
        });

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);
}

extension TrackActivity<T> on Stream<T> {
  Stream<T> trackActivity(ActivityIndicator activityIndicator) {
    activityIndicator._increment();
    return transform(_ActivityIndicatorTransformer<T>(activityIndicator));
  }

  Stream<T> whereNotLoading(ActivityIndicator activityIndicator) {
    return where((event) => activityIndicator.value != true);
  }
}
