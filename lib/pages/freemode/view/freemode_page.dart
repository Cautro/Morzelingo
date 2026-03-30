import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';

class FreemodePage extends StatelessWidget {
  const FreemodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: EdgeInsetsGeometry.all(24),
              child: Center(
                child: Container(
                    width: double.infinity,
                    child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsetsGeometry.all(16),
                                  child: Text("Свободный режим", style: Theme
                                      .of(context)
                                      .textTheme
                                      .titleLarge,),
                                ),
                                SizedBox(height: 16,),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.read<FreemodeBloc>().add(
                                          GetEvent(mode: FreemodeMode.audio));
                                    },
                                    child: Text(
                                      "Играть в режиме аудио", style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: Colors.white),),
                                  ),
                                ),
                                SizedBox(height: 16,),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.read<FreemodeBloc>().add(
                                          GetEvent(mode: FreemodeMode.text));
                                    },
                                    child: Text(
                                      "Играть в режиме текста", style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: Colors.white),),
                                  ),
                                ),
                              ]
                          ),
                        )
                    )
                ),
              )

          )
      ),
    );
  }
}