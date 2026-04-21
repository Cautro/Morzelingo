import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_controller.dart';
import 'package:morzelingo/pages/education/presentation/pages/completed_lessons_page.dart';
import 'package:morzelingo/pages/education/presentation/pages/lesson_page.dart';
import 'package:morzelingo/pages/loading_page.dart';
import '../../../../app_theme.dart';
import '../../../../ui/app_ui.dart';

class EducationPage extends StatefulWidget {
  final IEducationRepository repository;
  const EducationPage({super.key, required this.repository});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late final EducationController _controller = EducationController(repository: widget.repository);

  @override
  void initState() {
    _controller.addListener(_onStateChanged);
    _controller.getData();
    super.initState();
  }

  void _onStateChanged() {
    if (_controller.state.success != null) {
      Fluttertoast.showToast(
        msg: _controller.state.message,
        backgroundColor: _controller.state.success == true
            ? AppTheme.success
            : AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return _controller.state.isLoading ? const LoadingPage() : AppPageScaffold(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Текущий урок',
                subtitle: 'Изучайте теорию и сразу переходите к закреплению материала в практических заданиях.',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppInfoPill(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Награда ${_controller.state.lesson?.xp_reward} опыта',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _controller.state.lesson?.title ?? "",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Последовательное изучение морзе в 2х этапах: теория и практика.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs,),
              AppSurfaceCard(
                child: Row(
                  children: [
                    const AppInfoPill(
                      icon: Icons.language_outlined,
                      label: "Язык",
                    ),
                    const SizedBox(width: AppSpacing.md,),
                    Text(_controller.state.lang == "ru" ? "Русский" : "Английский"),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs,),
              const Row(
                children: [
                  Expanded(
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppInfoPill(icon: Icons.menu_book_rounded, label: "Теория",),
                          SizedBox(height: AppSpacing.lg),
                          Text("Краткое объяснение теории азбуки морзе",),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppInfoPill(icon: Icons.electric_bolt, label: "Практика",),
                          SizedBox(height: AppSpacing.lg),
                          Text("Закрепление материала через задания",),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                onPressed: () {
                  final lesson = _controller.state.lesson;
                  if (lesson == null) return;
                  Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => LessonPage(lesson: lesson, done: false))
                  );
                },
                child: const Text('Начать урок'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                onPressed: () {
                  final completed = _controller.state.completedLessons;
                  if (completed == null) return;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CompletedLessonsPage(completed: completed,),
                  ));
                },
                child: const Text('К пройденным урокам'),
              ),
            ],
          ),
        );
      },
    );
  }
}
