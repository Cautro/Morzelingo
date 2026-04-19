import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final AppLogger = Logger(
  printer: PrettyPrinter(methodCount: 0),
  level: kDebugMode ? Level.debug : Level.warning,
);