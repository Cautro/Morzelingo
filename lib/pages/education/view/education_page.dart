
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/education/bloc/education_bloc.dart';
import 'package:morzelingo/pages/loading_page.dart';

import 'package:morzelingo/storage_context.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  int? lessondone;
  Map lessons = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

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
            return isLoading ? LoadingPage() : Scaffold(
                body: SafeArea(
                    child: Center(
                        child: SingleChildScrollView(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Card(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                                                child: Column(
                                                  children: [
                                                    Text(lessons["title"], style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
                                                    SizedBox(height: 16,),
                                                    Text("Награда ${lessons["xp_reward"].toString()} опыта", style: Theme.of(context).textTheme.titleMedium,),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                      SizedBox(height: 16,),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/lesson',);
                                            StorageService.setItem("lessonid", lessons["id"].toString());
                                          },
                                          child: Text("Начать урок", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),),
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/completedlessons',);
                                        },
                                        child: Text("К пройденным урокам"),
                                      )
                                    ],
                                  )
                              ),
                            )
                        )
                    )
                )
            );
          },
        ),
      ),
    );

  }
}