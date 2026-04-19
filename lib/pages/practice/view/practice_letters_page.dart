import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/pages/practice/bloc/practice_bloc.dart';
import 'package:morzelingo/pages/practice/repository/practice_repository.dart';
import 'package:morzelingo/pages/practice/service/practice_service.dart';
import 'package:morzelingo/pages/practice/view/practice_audio_page.dart';
import 'package:morzelingo/pages/practice/view/practice_morse_page.dart';
import 'package:morzelingo/pages/practice/view/practice_text_page.dart';

import '../../../app_theme.dart';
import '../../../ui/app_ui.dart';

class LettersFlowPage extends StatelessWidget {
  const LettersFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PracticeBloc(repository: PracticeRepository(ApiClient()), service: PracticeService())..add(GetLettersEvent()),
      child: BlocConsumer<PracticeBloc, PracticeState>(
        listener: (context, state) {
          if (state.success != null) {
            Fluttertoast.showToast(
                msg: state.message ?? "",
                backgroundColor: state.success! ? AppTheme.success : AppTheme.error,
                textColor: Colors.white
            );
          }
          if (state.status == PracticeStatus.completed) {
            Fluttertoast.showToast(
                msg: "Урок завершён",
                backgroundColor: AppTheme.success,
                textColor: Colors.white
            );
            Navigator.pushReplacementNamed(context, "/home");
          }
          if (state.status == PracticeStatus.leave) {
            Fluttertoast.showToast(
                msg: "Урок покинут",
                backgroundColor: AppTheme.error,
                textColor: Colors.white
            );
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        builder: (context, state) {

          switch (state.status) {
            case PracticeStatus.idle || PracticeStatus.leave || PracticeStatus.completed:
              return const LoadingPage();
            case PracticeStatus.error:
              return const AppPageScaffold(
                child: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Ошибка',
                ),
              );
            case PracticeStatus.active:
              Widget content() { switch (state.type) {
                case PracticeType.text:
                  return PracticeTextPage(question: state.question, isLast: state.isLast, answer: state.answer, currentquestion: state.index / state.tasks!.length, isLetter: state.isLetter,);
                case PracticeType.audio:
                  return PracticeAudioPage(question: state.question, isLast: state.isLast, answer: state.answer, currentquestion: state.index / state.tasks!.length, isLetter: state.isLetter,);
                case PracticeType.morse:
                  return PracticeMorsePage(question: state.question, isLast: state.isLast, answer: state.answer, currentquestion: state.index / state.tasks!.length, isLetter: state.isLetter,);
                default:
                  return ErrorWidget("Ошибка");
              }
              }

              return AppPageScaffold(
                appBar: AppBar(
                  title: const Text("Практика букв"),
                  automaticallyImplyLeading: false,
                ),
                bottomBar: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppDangerButton(
                        child: const Text("Выйти"),
                        onPressed: () {
                          context.read<PracticeBloc>().add(LeaveEvent());
                        },
                      ),
                    )
                  ],
                ),
                child: content(),
              );
          }

        },
      ),
    );
  }
}