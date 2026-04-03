import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/education/bloc/education_bloc.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/storage_context.dart';

import '../../../ui/app_ui.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  Map lessons = {};
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationBloc()..add(GetEducationDataEvent()),
      child: BlocListener<EducationBloc, EducationState>(
        listener: (context, state) {
          if (state is GetEducationDataState) {
            setState(() {
              lessons = state.lessons;
              isLoading = false;
            });
          }
        },
        child: BlocBuilder<EducationBloc, EducationState>(
          builder: (context, state) {
            if (isLoading) {
              return const LoadingPage();
            }

            return AppPageScaffold(
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
                          label: 'Награда ${lessons["xp_reward"]} опыта',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          lessons["title"],
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
                  const SizedBox(height: AppSpacing.sm,),
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
                      Navigator.pushNamed(context, '/lesson');
                      StorageService.setItem("lessonid", lessons["id"].toString());
                    },
                    child: const Text('Начать урок'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/completedlessons');
                    },
                    child: const Text('К пройденным урокам'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
