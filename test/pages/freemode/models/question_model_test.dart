import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/pages/freemode/models/question_model.dart';

void main() {
  group('QuestionModel', () {
    test('should parse json and serialize back to json', () {
      final QuestionModel model = QuestionModel.fromJson(<String, dynamic>{
        'question': 'Q',
        'answer': 'A',
      });

      expect(model.question, 'Q');
      expect(model.answer, 'A');
      expect(model.toJson(), <String, dynamic>{
        'question': 'Q',
        'answer': 'A',
      });
    });
  });
}
