import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';
import 'package:morzelingo/pages/duels/view/duels_playing_page.dart';
import 'package:morzelingo/pages/duels/view/duels_waiting_page.dart';

import '../../../app_theme.dart';

class DuelsMainPage extends StatefulWidget {
  const DuelsMainPage({super.key});

  @override
  State<DuelsMainPage> createState() => _DuelsMainPageState();
}

class _DuelsMainPageState extends State<DuelsMainPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DuelsBloc(),
      child: BlocConsumer<DuelsBloc, DuelsState>(
        listener: (context, state) {
          if (state.status == "waiting") {
            context.read<DuelsBloc>().add(GetStatusEvent());
          }
          if (state.status == "active") {
            context.read<DuelsBloc>().add(GetTasksEvent());
          }
          if (state.success != null) {
            print('${state.success}');
            Fluttertoast.showToast(
              msg: state.message.toString(),
              backgroundColor: state.success  == true ? AppTheme.success : AppTheme.error,
              textColor: Colors.white,
            );
          }
          if (state.status == 'cancelled') {
            Navigator.pushReplacementNamed(context, "/home");
          }
          if (state.status == "playing") {
            if (state.currentQuestion >= state.tasks.length) {
              context.read<DuelsBloc>().add(CompleteEvent());
            }
          }
          if (state.status == "finished") {
            Fluttertoast.showToast(
              msg: "Дуэль завершена",
              backgroundColor: AppTheme.success,
              textColor: Colors.white,
            );
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
        builder: (context, state) {
          return
            state.status == "idle" ? Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text("Дуэли", style: Theme.of(context).textTheme.titleLarge,),
                            SizedBox(height: 16,),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<DuelsBloc>().add(CreateDuelEvent());
                                },
                                child: Text("Создать дуэль"),
                              ),
                            ),
                            SizedBox(height: 8,),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text("Присоединиться к дуэли"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ),
            ),
          ) :
            state.status == "waiting" ? DuelsWaitingPage() :
            state.status == "active" ? Placeholder() :
            state.status == "playing" ? DuelsPlayingPage(tasks: state.tasks, currentQuestion: state.currentQuestion, answer: state.answer,) :
            Center(child: Text("Ожидание"),);
        },
      ),
    );
  }
}
