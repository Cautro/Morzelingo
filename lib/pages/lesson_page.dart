import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../storage_context.dart';

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

  @override

  void getLesson() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/lessons/${id}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var data = jsonDecode(res.body);
    setState(() {
      lesson = data;
    });
    print(lesson);
  }

  Future<void> getProfileData() async {
    String? token = await StorageService.getItem("token");

    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    print(data);
    setState(() {
      lessondone = data["lesson_done"].toString();
    });
    print(lessondone);

    id = await StorageService.getItem("lessonid");
    print("id ${id}, done${lessondone}");
    if ((int.parse(lessondone!)) >= (int.parse(id))) {
      setState(() {
        done = true;
      });
    } else {
      done = false;
    }
    print(done);
  }


  @override
  void initState() {
    super.initState();
    getLesson();
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Теория")),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
