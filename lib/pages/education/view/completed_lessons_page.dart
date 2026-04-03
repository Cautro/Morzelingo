import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../storage_context.dart';
import '../../../ui/app_ui.dart';
import '../bloc/education_bloc.dart';

class CompletedLessonsPage extends StatefulWidget {
  const CompletedLessonsPage({super.key});

  @override
  State<CompletedLessonsPage> createState() => _CompletedLessonsPageState();
}

class _CompletedLessonsPageState extends State<CompletedLessonsPage> {
  bool isLoading = true;
  List completed = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationBloc()..add(GetCompletedDataEvent()),
      child: BlocListener<EducationBloc, EducationState>(
        listener: (context, state) {
          if (state is GetCompletedDataState) {
            setState(() {
              completed = state.completed;
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
              appBar: AppBar(title: const Text('Пройденные уроки')),
              padding: AppSpacing.pageDense,
              child: completed.isNotEmpty
                  ? ListView.separated(
                      itemCount: completed.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final item = completed[index];
                        return AppListCard(
                          title: item["title"],
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
                            StorageService.setItem("lessonid", item["id"].toString());
                            Navigator.pushNamed(context, "/lesson");
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
          },
        ),
      ),
    );
  }
}
