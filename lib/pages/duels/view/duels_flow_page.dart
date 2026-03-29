import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';
import 'package:morzelingo/pages/duels/repository/duels_repository.dart';
import 'package:morzelingo/pages/duels/service/duels_service.dart';
import 'package:morzelingo/pages/duels/view/duels_active_page.dart';
import 'package:morzelingo/pages/duels/view/duels_main_page.dart';
import 'package:morzelingo/pages/duels/view/duels_playing_page.dart';
import 'package:morzelingo/pages/duels/view/duels_waiting_page.dart';

import '../../../app_theme.dart';

class DuelsFlowPage extends StatefulWidget {
  const DuelsFlowPage({super.key});

  @override
  State<DuelsFlowPage> createState() => _DuelsFlowPageState();
}

class _DuelsFlowPageState extends State<DuelsFlowPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DuelsBloc(repository: DuelsRepository(), service: DuelsService()),
      child: BlocConsumer<DuelsBloc, DuelsState>(
        listener: (context, state) {

          if (state.status == DuelsStatus.cancelled) {
            Fluttertoast.showToast(
              msg: "Дуэль отменена",
              backgroundColor: AppTheme.error,
              textColor: Colors.white,
            );
            Navigator.pushReplacementNamed(context, "/home");
          }
          if (state.status == DuelsStatus.playing) {
            if (state.currentQuestion >= state.tasks.length) {
              context.read<DuelsBloc>().add(CompleteEvent());
            }
          }
          if (state.success != null) {
            print('${state.success}');
            Fluttertoast.showToast(
              msg: state.message.toString(),
              backgroundColor: state.success  == true ? AppTheme.success : AppTheme.error,
              textColor: Colors.white,
            );
          }
          if (state.status == DuelsStatus.finished) {
            Fluttertoast.showToast(
              msg: "Дуэль завершена",
              backgroundColor: AppTheme.success,
              textColor: Colors.white,
            );
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case DuelsStatus.idle:
              return const DuelsMainPage();
            case DuelsStatus.active:
              return DuelsActivePage(opponent: state.opponent ?? "?",);
            case DuelsStatus.playing:
              return DuelsPlayingPage(tasks: state.tasks, currentQuestion: state.currentQuestion, answer: state.answer,);
            case DuelsStatus.waiting:
              return const DuelsWaitingPage();
            default:
              return const Center(child: Text("Ошибка"),);
          }
        },
      ),
    );
  }
}
