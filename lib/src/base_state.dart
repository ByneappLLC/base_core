import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  late Logger logger;
  BaseState() {
    logger = Logger('${runtimeType.toString()}');
    logger.finest('init');
  }

  CompositeSubscription compositeSubscription = CompositeSubscription();

  @override
  void dispose() {
    logger.finest('dispose');
    compositeSubscription.dispose();
    super.dispose();
  }
}
