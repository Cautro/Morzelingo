import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/education/context/education_context.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../config.dart';
import '../../../storage_context.dart';

class CompletedLessonsPage extends StatefulWidget {
  const CompletedLessonsPage({super.key});

  @override
  State<CompletedLessonsPage> createState() => _CompletedLessonsPageState();
}

class _CompletedLessonsPageState extends State<CompletedLessonsPage> {
  int? lessondone;
  bool isLoading = true;
  List completed = [];

  @override
  void getData() async {
    var data = await EducationContext().getCompletedLessonsData();
    setState(() {
      completed = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Scaffold(
        body: LoadingPage(),
      );
    }

    return Scaffold(
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
}
