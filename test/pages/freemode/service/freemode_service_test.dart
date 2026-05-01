import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/pages/freemode/service/freemode_service.dart';

void main() {
  group('FreemodeService', () {
    late FreemodeService service;

    setUp(() {
      service = FreemodeService();
    });

    test('should return true when answers match ignoring case and spaces', () {
      final bool result = service.answerHandler('  hello ', 'HeLLo');

      expect(result, isTrue);
    });

    test('should return false when answers are different', () {
      final bool result = service.answerHandler('hello', 'world');

      expect(result, isFalse);
    });
  });
}
