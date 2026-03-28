import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';

class DuelsMainPage extends StatefulWidget {
  const DuelsMainPage({super.key});

  @override
  State<DuelsMainPage> createState() => _DuelsMainPageState();
}

class _DuelsMainPageState extends State<DuelsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            child: Text("Начать дуэль"),
                          ),
                        ),
                        SizedBox(height: 8,),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ),
        ),
      );
  }
}