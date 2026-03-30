import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';
import '../../../app_theme.dart';

class DuelsActivePage extends StatefulWidget {
  final String opponent;
  const DuelsActivePage({super.key, required this.opponent});

  @override
  State<DuelsActivePage> createState() => _DuelsActivePageState();
}

class _DuelsActivePageState extends State<DuelsActivePage> {

  @override
  Future<void> leaveDialog() async {
    final duelsBloc = context.read<DuelsBloc>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Вы уверены что хотите покинуть дуэль?"),
          content: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    duelsBloc.add(LeaveEvent());
                  },
                  child: const Text("Да, покинуть!"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Не покидать"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  children: [
                    Text("Ваш противник:", style: Theme.of(context).textTheme.bodyLarge,),
                    Text(widget.opponent, style: Theme.of(context).textTheme.titleLarge,),
                    const SizedBox(height: 8,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text("К заданиям!"),
                        onPressed: () {
                          context.read<DuelsBloc>().add(GetTasksEvent());
                        },
                      ),
                    ),
                    const SizedBox(height: 16,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                        child: const Text("Покинуть дуэль"),
                        onPressed: () {
                          leaveDialog();
                        },
                      ),
                    ),
                  ],
                ),
              )

            ),
          ),
        ),

      ),
    );
  }
}
