import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/pages/loading_page.dart';

import '../config.dart';
import '../settings_context.dart';
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
  bool isLoading = true;

  @override

  void getData() async {
    String? id = await StorageService.getItem("lessonid");
    String? token = await StorageService.getItem("token");
    final lang = await SettingsService.getLang();
    final res = await http.get(Uri.parse("${API}/api/lessons/${id}/?lang=${lang.trim()}"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var data = jsonDecode(res.body);
    setState(() {
      lesson = data;
    });
    print(lesson);

    final res1 = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data1 = await jsonDecode(res1.body);
    print(data);
    setState(() {
      lessondone = data1["lesson_done"].toString();
    });
    print(lessondone);

    id = await StorageService.getItem("lessonid");
    print("id ${id}, done${lessondone}");
    if ((int.parse(lessondone!)) >= (int.parse(id!))) {
      setState(() {
        done = true;
      });
    } else {
      done = false;
    }
    print(done);
    setState(() {
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
