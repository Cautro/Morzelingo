import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/morse/morse_alphabet.dart';
import 'package:morzelingo/pages/duels/service/duels_service.dart';

import '../../../helpers/test_bootstrap.dart';

String duelsCodeForLetter(Map<String, String> alphabet, String letter) {
  return alphabet.entries.firstWhere((MapEntry<String, String> entry) {
    return entry.value == letter;
  }).key;
}

void main() {
  group('DuelsService', () {
    late DuelsService service;

    setUp(() {
      initializeTestEnvironment(<String, Object>{'lang': 'en'});
      service = DuelsService();
    });

    test('should return question text as answer for text type', () async {
      final String answer = await service.getAnswer('HELLO', 'text');

      expect(answer, 'HELLO');
    });

    test('should decode audio question using selected language', () async {
      final String codeA = duelsCodeForLetter(MorseAlphabet.en, 'A');
      final String codeB = duelsCodeForLetter(MorseAlphabet.en, 'B');

      final String answer = await service.getAnswer('$codeA $codeB', 'audio');

      expect(answer, 'AB');
    });

    test('should decode morse question using selected language', () async {
      final String codeS = duelsCodeForLetter(MorseAlphabet.en, 'S');
      final String codeO = duelsCodeForLetter(MorseAlphabet.en, 'O');

      final String answer = await service.getAnswer(
        '$codeS $codeO $codeS',
        'morse',
      );

      expect(answer, 'SOS');
    });

    test('should validate answers ignoring case and spaces', () async {
      final bool result = await service.answerHandler('  sos ', 'SoS');

      expect(result, isTrue);
    });

    test('should count matching symbols when scoring answers', () async {
      final int score = await service.scoreHandler('AXC', 'ABC');

      expect(score, 2);
    });

    test('should return zero score for empty user answer', () async {
      final int score = await service.scoreHandler('', 'ABC');

      expect(score, 0);
    });
  });
}
