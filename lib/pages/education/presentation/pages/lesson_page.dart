import 'package:flutter/material.dart';
import 'package:morzelingo/pages/practice/view/practice_page.dart';
import '../../../../ui/app_ui.dart';
import '../../domain/entities/lesson.dart';

class LessonPage extends StatelessWidget {
  final bool done;
  final Lesson lesson;

  const LessonPage({required this.lesson, required this.done});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      appBar: AppBar(title: const Text("Теория")),
      scrollable: true,
      bottomBar: done
          ? null
          : AppPrimaryButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PracticeFlowPage(id: lesson.id.toString()))
          );
        },
        child: const Text('Закрепить знания'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: lesson.title,
            subtitle: !done ? 'Изучите теорию морзе, а после - закрепите свои знания практикой.' : 'Повторите теорию уже пройденного вами урока',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Text(
              lesson.theory,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

}

