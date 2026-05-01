import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/pages/duels/models/duel_question_model.dart';

void main() {
  group('DuelQuestionModel', () {
    test('should parse json and serialize back to json', () {
      final DuelQuestionModel model = DuelQuestionModel.fromJson(
        <String, dynamic>{
          'question': 'Q',
          'type': 'text',
        },
      );

      expect(model.question, 'Q');
      expect(model.type, 'text');
      expect(model.toJson(), <String, dynamic>{
        'question': 'Q',
        'type': 'text',
      });
    });
  });
}
