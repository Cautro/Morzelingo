import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void initializeTestEnvironment([
  Map<String, Object> values = const <String, Object>{},
]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(values);
}

Future<void> settleAsync([int ticks = 20]) async {
  for (int index = 0; index < ticks; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}
