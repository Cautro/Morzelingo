import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/pages/education/data/models/lesson_model.dart';

void main() {
  group('LessonModel', () {
    test('should parse json and convert to entity', () {
      final LessonModel model = LessonModel.fromJson(<String, dynamic>{
        'id': 7,
        'title': 'Lesson 7',
        'theory': 'theory',
        'xp_reward': 15,
      });

      final entity = model.toEntity();

      expect(model.id, 7);
      expect(model.title, 'Lesson 7');
      expect(model.theory, 'theory');
      expect(model.xp_reward, 15);
      expect(entity.id, 7);
      expect(entity.title, 'Lesson 7');
      expect(entity.theory, 'theory');
      expect(entity.xp_reward, 15);
    });
  });
}
