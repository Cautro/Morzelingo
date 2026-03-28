import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';

class DuelsActivePage extends StatefulWidget {
  final String opponent;
  const DuelsActivePage({super.key, required this.opponent});

  @override
  State<DuelsActivePage> createState() => _DuelsActivePageState();
}

class _DuelsActivePageState extends State<DuelsActivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  children: [
                    Text("Ваш противник:", style: Theme.of(context).textTheme.bodyLarge,),
                    Text("${widget.opponent}", style: Theme.of(context).textTheme.titleLarge,),
                    SizedBox(height: 8,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text("К заданиям!"),
                        onPressed: () {
                          context.read<DuelsBloc>().add(GetTasksEvent());
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
