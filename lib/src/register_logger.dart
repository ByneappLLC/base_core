import 'package:logging/logging.dart';

class BaseCoreLogger {
  static initLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((rec) {
      print(
          '${rec.loggerName} - ${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }
}
