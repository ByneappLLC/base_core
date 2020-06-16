import 'dart:async';

import 'package:base_core/src/failure.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseBloc {
  @protected
  Logger logger;

  BaseBloc() {
    logger = Logger(runtimeType.toString());
    logger.finest('init');
  }

  CompositeSubscription compositeSubscription = CompositeSubscription();

  void dispose() {
    logger.finest('dispose');
    if (compositeSubscription != null) {
      compositeSubscription.dispose();
      compositeSubscription = null;
    }
  }
}

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  Logger logger;
  BaseState() {
    logger = Logger('${runtimeType.toString()}');
    logger.finest('init');
  }

  CompositeSubscription compositeSubscription = CompositeSubscription();

  @override
  void dispose() {
    logger.finest('dispose');
    compositeSubscription.dispose();
    compositeSubscription = null;
    super.dispose();
  }
}

class MultiBlocProvider extends StatelessWidget {
  final List<BlocProvider<dynamic>> blocs;
  final Widget child;

  const MultiBlocProvider({Key key, this.blocs, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => blocs.reversed.fold(
      child, (previousValue, element) => element.copyWithChild(previousValue));
}

class BlocProvider<T extends BaseBloc> extends StatefulWidget {
  BlocProvider({
    Key key,
    this.child,
    this.shouldDispose = true,
    @required this.bloc,
  }) : super(key: key);

  final Widget child;
  final T bloc;
  final bool shouldDispose;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BaseBloc>(BuildContext context) {
    _BlocProviderInherited<T> provider = context
        .getElementForInheritedWidgetOfExactType<_BlocProviderInherited<T>>()
        ?.widget;
    return provider?.bloc;
  }

  BlocProvider<T> copyWithChild(Widget child) {
    return BlocProvider<T>(
      bloc: bloc,
      child: child,
      key: key,
    );
  }
}

class _BlocProviderState<T extends BaseBloc> extends State<BlocProvider<T>> {
  @override
  void dispose() {
    if (widget.shouldDispose) {
      widget.bloc?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  _BlocProviderInherited({
    Key key,
    @required Widget child,
    @required this.bloc,
  }) : super(key: key, child: child);

  final T bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
}

extension ForwardFailure<T> on Stream<Either<Failure, T>> {
  Stream<T> onFailureForwardTo(StreamSink<Failure> failureSink) {
    return doOnData((event) {
      event.leftMap(failureSink.add);
    })
        .where((event) => event.isRight())
        .map((event) => event.getOrElse(() => null));
  }
}
