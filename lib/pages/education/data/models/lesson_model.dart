import '../../domain/entities/lesson.dart';

class LessonModel {
  final int id;
  final String title;
  final String theory;
  final int xp_reward;

  LessonModel({
    required this.xp_reward,
    required this.id,
    required this.title,
    required this.theory
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(id: json['id'], theory: json['theory'], title: json['title'], xp_reward: json['xp_reward']);
  }

  Lesson toEntity() => Lesson(id: id, theory: theory, title: title, xp_reward: xp_reward);
}