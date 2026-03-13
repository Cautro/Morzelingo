import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/education/context/education_context.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../config.dart';
import '../../../storage_context.dart';
import '../bloc/education_bloc.dart';

class CompletedLessonsPage extends StatefulWidget {
  const CompletedLessonsPage({super.key});

  @override
  State<CompletedLessonsPage> createState() => _CompletedLessonsPageState();
}

class _CompletedLessonsPageState extends State<CompletedLessonsPage> {
  bool isLoading = true;
  List completed = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => EducationBloc()..add(GetCompletedDataEvent()),
        child: BlocListener<EducationBloc, EducationState>(
            listener: (context, state) {
              if (state is GetCompletedDataState) {
                setState(() {
                  completed = state.completed;
                  isLoading = false;
                });
              }
            },
            child: BlocBuilder<EducationBloc, EducationState>(
                builder: (context, state) {
                  return isLoading ? LoadingPage() : Scaffold(
                    appBar: AppBar(
                      title: Text("Пройденные уроки"),
                    ),
                    body: SafeArea(
                        child: Container(
                            padding: EdgeInsets.all(24),
                            width: double.infinity,
                            child: completed.isNotEmpty ? Column(
                              children: completed.map((item) {
                                return Container(
                                    width: double.infinity,
                                    child: GestureDetector(
                                      onTap: () {
                                        StorageService.setItem("lessonid", item["id"].toString());
                                        Navigator.pushNamed(context, "/lesson");
                                      },
                                      child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(item["title"]),
                                          )
                                      ),
                                    )
                                );
                              }).toList(),
                            ) : Center(child: Text("Вы пока не прошли ни одного урока"),)
                        )
                    ),
                  );
                }
            )
        )
    );

  }
}
