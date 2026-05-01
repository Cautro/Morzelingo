import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/exceptions/exceptions.dart';
import 'package:morzelingo/pages/practice/domain/entities/question_types.dart';
import 'package:morzelingo/pages/practice/domain/services/practice_service.dart';

Map<String, SymbolUpdate> bySymbol(List<SymbolUpdate> updates) {
  return <String, SymbolUpdate>{
    for (final SymbolUpdate update in updates) update.symbol: update,
  };
}

void main() {
  group('PracticeService', () {
    late PracticeService service;

    setUp(() {
      service = PracticeService();
    });

    test('should map string values to practice types', () {
      expect(service.stringToType('text'), PracticeType.text);
      expect(service.stringToType('audio'), PracticeType.audio);
      expect(service.stringToType('morse'), PracticeType.morse);
      expect(service.stringToType('unknown'), PracticeType.text);
    });

    test('should map practice types to string values', () {
      expect(service.typeToString(PracticeType.text), 'text');
      expect(service.typeToString(PracticeType.audio), 'audio');
      expect(service.typeToString(PracticeType.morse), 'morse');
    });

    test('should return true when answer matches ignoring case and spaces', () {
      final bool result = service.checkAnswer('  sos ', 'SoS');

      expect(result, isTrue);
    });

    test('should throw ValidationException when text or answer is empty', () async {
      expect(
        () => service.checkAnswer('', 'ABC'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => service.checkAnswer('ABC', ''),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should calculate full match stats for each symbol', () {
      final Map<String, SymbolUpdate> stats = bySymbol(
        service.calculateStats('AB', 'AB'),
      );

      expect(stats['A']?.correct, 1);
      expect(stats['A']?.wrong, 0);
      expect(stats['B']?.correct, 1);
      expect(stats['B']?.wrong, 0);
    });

    test('should accumulate correct and wrong counts for repeated symbols', () {
      final Map<String, SymbolUpdate> stats = bySymbol(
        service.calculateStats('ABA', 'ACA'),
      );

      expect(stats['A']?.correct, 2);
      expect(stats['A']?.wrong, 0);
      expect(stats['B']?.correct, 0);
      expect(stats['B']?.wrong, 1);
    });

    test('should ignore extra user symbols that are not in correct answer', () {
      final Map<String, SymbolUpdate> stats = bySymbol(
        service.calculateStats('AB', 'ABC'),
      );

      expect(stats.keys, isNot(contains('C')));
      expect(stats['A']?.correct, 1);
      expect(stats['B']?.correct, 1);
    });

    test('should count missing user symbols as wrong answers', () {
      final Map<String, SymbolUpdate> stats = bySymbol(
        service.calculateStats('ABC', 'A'),
      );

      expect(stats['A']?.correct, 1);
      expect(stats['B']?.wrong, 1);
      expect(stats['C']?.wrong, 1);
    });
  });
}
