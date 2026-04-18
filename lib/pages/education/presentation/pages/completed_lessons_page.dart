import 'package:flutter/material.dart';
import 'package:morzelingo/pages/education/data/models/lesson_model.dart';
import 'package:morzelingo/pages/education/domain/entities/lesson.dart';
import '../../../../ui/app_ui.dart';
import 'lesson_page.dart';


class CompletedLessonsPage extends StatelessWidget {
  final List<Lesson> completed;
  const CompletedLessonsPage({super.key, required this.completed});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      appBar: AppBar(title: const Text('Пройденные уроки')),
      padding: AppSpacing.pageDense,
      child: completed.isNotEmpty
          ? ListView.separated(
        itemCount: completed.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = completed[index];
          return AppListCard(
            title: item.title,
            subtitle: 'Повторите теорию уже пройденного урока.',
            leading: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: AppRadii.md,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonPage(lesson: item, done: true)),

              );
            },
          );
        },
      )
          : const AppEmptyState(
        icon: Icons.school_outlined,
        title: 'У вас пока нет пройденных уроков',
        subtitle: 'Когда завершите первый урок, он появится здесь.',
      ),
    );
  }
}

