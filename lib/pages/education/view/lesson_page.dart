import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/education/context/education_context.dart';
import 'package:morzelingo/pages/loading_page.dart';

import '../../../config.dart';
import '../../../settings_context.dart';
import '../../../storage_context.dart';

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

  void getData() async {
    var data = await EducationContext().getLessonData();
    setState(() {
      lesson = data["lesson"];
      done = data["done"];
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
                                  lesson["Title"],
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  lesson["Theory"],
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
}
