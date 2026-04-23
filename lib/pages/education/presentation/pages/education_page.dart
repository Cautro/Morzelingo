import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/pages/education/domain/repositories/education_repository_interface.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_cubit.dart';
import 'package:morzelingo/pages/education/presentation/controller/education_state.dart';
import 'package:morzelingo/pages/education/presentation/pages/completed_lessons_page.dart';
import 'package:morzelingo/pages/education/presentation/pages/lesson_page.dart';
import 'package:morzelingo/pages/loading_page.dart';
import '../../../../app_theme.dart';
import '../../../../ui/app_ui.dart';

class EducationPage extends StatelessWidget {
  final IEducationRepository repository;
  const EducationPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationCubit(repository: repository)..getData(),
      child: BlocConsumer<EducationCubit, EducationState>(
        listener: (context, state) {
          if (state.success != null) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: state.success == true
                  ? AppTheme.success
                  : AppTheme.error,
              textColor: Colors.white,
            );
          }
        },
        builder: (context, state) {
          return state.isLoading ? const LoadingPage() : AppPageScaffold(
            child: RefreshIndicator(
              onRefresh: () => context.read<EducationCubit>().getData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                            label: 'Награда ${state.lesson?.xp_reward} опыта',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            state.lesson?.title ?? "",
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
                          Text(state.lang == "ru" ? "Русский" : "Английский"),
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
                        final lesson = state.lesson;
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
                        final completed = state.completedLessons;
                        if (completed == null) return;
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CompletedLessonsPage(completed: completed,),
                        ));
                      },
                      child: const Text('К пройденным урокам'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}