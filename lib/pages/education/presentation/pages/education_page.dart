import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/pages/education/bloc/education_bloc.dart';
import 'package:morzelingo/pages/education/data/repositories/education_repository.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_controller.dart';
import 'package:morzelingo/pages/education/presentation/pages/completed_lessons_page.dart';
import 'package:morzelingo/pages/education/presentation/pages/lesson_page.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/settings_context.dart';
import 'package:morzelingo/storage_context.dart';

import '../../../../ui/app_ui.dart';
import '../../domain/entities/lesson.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final EducationController _model = EducationController(repository: EducationRepository(ApiClient()));

  @override
  void initState() {
    _model.getLessons();
    // _model.getCompletedLessons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, child) {
        return _model.state.isLoading ? LoadingPage() : AppPageScaffold(
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
                      label: 'Награда ${_model.state.lesson?.xp_reward} опыта',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _model.state.lesson?.title ?? "",
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
                      MaterialPageRoute(builder: (context) => LessonPage(lesson: _model.state.lesson!, done: false))
                  );
                },
                child: const Text('Начать урок'),
              ),
              const SizedBox(height: AppSpacing.sm),
              // AppSecondaryButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => CompletedLessonsPage(completed: _model.state?.completedLessons ?? [],))
              //     );
              //   },
              //   child: const Text('К пройденным урокам'),
              // ),
            ],
          ),
        );
      },
    );
  }
}
