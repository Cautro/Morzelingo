import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/pages/education/data/repositories/education_repository.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_controller.dart';
import 'package:morzelingo/pages/education/presentation/pages/lesson_page.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/settings_context.dart';
import '../../../../app_theme.dart';
import '../../../../ui/app_ui.dart';
import 'completed_lessons_page.dart';

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
    _controller.getData();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.state.success != null) {
          Fluttertoast.showToast(
            msg: _controller.state.message,
            backgroundColor: _controller.state.success == true ? AppTheme.success : AppTheme.error,
            textColor: Colors.white
          );
        }

        return _controller.state.isLoading ? LoadingPage() : AppPageScaffold(
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
                    AppInfoPill(
                      icon: Icons.language_outlined,
                      label: "Язык",
                    ),
                    const SizedBox(width: AppSpacing.md,),
                    Text(SettingsService.getLang() == "ru" ? "Русский" : "Английский"),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs,),
              Row(
                children: [
                  Expanded(
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppInfoPill(icon: Icons.menu_book_rounded, label: "Теория",),
                          const SizedBox(height: AppSpacing.lg),
                          Text("Краткое объяснение теории азбуки морзе",),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppInfoPill(icon: Icons.electric_bolt, label: "Практика",),
                          const SizedBox(height: AppSpacing.lg),
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
                  Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => LessonPage(lesson: _controller.state.lesson!, done: false))
                  );
                },
                child: const Text('Начать урок'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompletedLessonsPage(completed: _controller.state?.completedLessons ?? [],))
                  );
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
