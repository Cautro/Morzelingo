import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../ui/app_ui.dart';
import '../bloc/education_bloc.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  var lesson;
  bool done = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EducationBloc()..add(GetLessonDataEvent()),
      child: BlocListener<EducationBloc, EducationState>(
        listener: (context, state) {
          if (state is GetLessonDataState) {
            setState(() {
              lesson = state.lesson;
              done = state.done;
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
              appBar: AppBar(title: const Text("Теория")),
              scrollable: true,
              bottomBar: done
                  ? null
                  : AppPrimaryButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/practice');
                      },
                      child: const Text('Закрепить знания'),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: lesson["title"],
                    subtitle: !done ? 'Изучите теорию морзе, а после - закрепите свои знания практикой.' : 'Повторите теорию уже пройденного вами урока',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppSurfaceCard(
                    child: Text(
                      lesson["theory"],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
