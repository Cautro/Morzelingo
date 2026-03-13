import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/education/context/education_context.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';
import '../bloc/education_bloc.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key,});

  @override
  State<LessonPage> createState() => _LessonPageState();

}
class _LessonPageState extends State<LessonPage> {
  var lesson;
  String? lessondone;
  var done = false;
  var id;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

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
                  return isLoading ? LoadingPage() : Scaffold(
                    appBar: AppBar(title: const Text("Теория")),
                    body: SafeArea(
                      child: Padding(
                        padding:  EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Card(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Text(
                                                  lesson["title"],
                                                  style: Theme.of(context).textTheme.titleLarge,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Text(
                                                  lesson["theory"],
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                              ),
                            ),

                            !done ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/practice',);
                                },
                                child: Text(
                                  "Закрепить знания",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ) : Container()
                          ],
                        ),
                      ),
                    ),
                  );
                }
            )
        )
    );
  }
}
