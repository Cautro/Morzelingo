import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/morse/morse_alphabet.dart';
import 'package:morzelingo/pages/practice/data/models/question_model.dart';
import 'package:morzelingo/pages/practice/domain/entities/question_types.dart';

import '../../../../helpers/test_bootstrap.dart';

String practiceCodeForLetter(Map<String, String> alphabet, String letter) {
  return alphabet.entries.firstWhere((MapEntry<String, String> entry) {
    return entry.value == letter;
  }).key;
}

void main() {
  group('PracticeQuestionModel', () {
    setUp(() {
      initializeTestEnvironment(<String, Object>{'lang': 'en'});
    });

    test('should parse json with explicit type and convert to entity', () {
      final PracticeQuestionModel model = PracticeQuestionModel.fromJson(
        <String, dynamic>{
          'type': 'audio',
          'question': 'Q',
          'answer': 'A',
        },
      );

      final entity = model.toEntity();

      expect(model.type, PracticeType.audio);
      expect(model.question, 'Q');
      expect(model.answer, 'A');
      expect(entity.type, PracticeType.audio);
      expect(entity.question, 'Q');
      expect(entity.answer, 'A');
    });

    test('should apply default values when json fields are missing', () {
      final PracticeQuestionModel model = PracticeQuestionModel.fromJson(
        <String, dynamic>{},
      );

      expect(model.type, PracticeType.text);
      expect(model.question, '');
      expect(model.answer, '');
    });

    test('should return original text answer for letters text question', () async {
      final PracticeQuestionModel model =
          await PracticeQuestionModel.fromJsonLetters(<String, dynamic>{
            'type': 'text',
            'question': 'HELLO',
          });

      expect(model.type, PracticeType.text);
      expect(model.question, 'HELLO');
      expect(model.answer, 'HELLO');
    });

    test('should decode morse answer for letters audio question', () async {
      final String codeA = practiceCodeForLetter(MorseAlphabet.en, 'A');
      final String codeB = practiceCodeForLetter(MorseAlphabet.en, 'B');

      final PracticeQuestionModel model =
          await PracticeQuestionModel.fromJsonLetters(<String, dynamic>{
            'type': 'audio',
            'question': '$codeA $codeB',
          });

      expect(model.type, PracticeType.audio);
      expect(model.question, '$codeA $codeB');
      expect(model.answer, 'AB');
    });
  });
}
