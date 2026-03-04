import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'dart:convert';

import 'package:morzelingo/storage_context.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  String? lessondone;
  List lessons = [];

  @override

  void getProfileData() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    setState(() {
      lessondone = data["lesson_done"].toString();
    });
    print(lessondone);
  }

  void getLessons() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/lessons"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    var data = jsonDecode(res.body);
    setState(() {
      lessons = data;
    });
    print(lessons);
  }

  @override
  void initState() {
    super.initState();
    getLessons();
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsetsGeometry.all(24,),
            child: Container(
              width: double.infinity,
              child: Column(
                children: lessons.map((item) {
                  double randomOffset = (Random().nextDouble() - 0.5) * 120;
                  return Transform.translate(
                      offset: Offset(randomOffset, 0),
                      child: _lessonWidget(
                        data: item,
                        buttonHandler: () {
                          print("done");
                        },
                        lessondone: lessondone ?? "",
                      ),
                  );
                }).toList(),
              ),
          ),
          )
      ),
    );
  }
}

class _lessonWidget extends StatefulWidget {
  final Function buttonHandler;
  final Map<String, dynamic> data;
  final String lessondone;
  const _lessonWidget({super.key, required this.data, required this.buttonHandler, required this.lessondone });


  @override
  State<_lessonWidget> createState() => _lessonWidgetState();
}

class _lessonWidgetState extends State<_lessonWidget> {
  bool expanded = false;
  bool locked = false;

  @override

  void _checkLocked () async {
    if ((int.tryParse(widget.lessondone) ?? 0) < (int.tryParse(widget.data["ID"].toString()) ?? 0) - 1) {
      setState(() {
        locked = true;
      });
    } else {
      setState(() {
        locked = false;
      });
    }
    print(locked);
  }

  @override
  void initState() {
    super.initState();
    _checkLocked();
  }


  @override
  void didUpdateWidget(covariant _lessonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lessondone != widget.lessondone) {
      _checkLocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsetsGeometry.all(32),
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.textPrimary.withOpacity(0.4),
                      offset: Offset(4, 4),
                      blurRadius: 5,
                      spreadRadius: 2
                    ),
                    BoxShadow(
                        color: Colors.white,
                        offset: Offset(-5, -5),
                        blurRadius: 5,
                        spreadRadius: 2
                    )
                  ],
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
              child: IconButton(
                onPressed: () {
                  if (!locked) {
                    setState(() {
                      expanded = !expanded;
                      print(widget.data);
                      print("${widget.lessondone} fgf");
                    });
                } else {}
                },
                icon: locked ? Icon(Icons.lock, size: 40,) : Icon(Icons.star_rounded, size: 40,),
                style: IconButton.styleFrom(
                  backgroundColor: locked ? AppTheme.textSecondary : AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  shape: CircleBorder(),
                ),
              ),
            ),
            AnimatedSize(
                duration: Duration(milliseconds: 300),
                  child: expanded ? Container(
                    width: 200,
                    child: Card(
                      child: Padding(
                        child: Column(
                          children: [
                            Text("${widget.data["Title"]}", style: Theme.of(context).textTheme.titleLarge!,),
                            SizedBox(height: 8,),
                            SizedBox(
                              child: ElevatedButton(
                                  onPressed: () {
                                    widget.buttonHandler();
                                    Navigator.pushNamed(context, '/lesson',);
                                    print("${widget.data["ID"]}");
                                    StorageService.setItem("lessonid", widget.data["ID"].toString());
                                  },
                                  child: Text("Начать", style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white
                                  )),
                              ),
                              width: double.infinity,
                            )
                          ],
                        ),
                        padding: EdgeInsetsGeometry.all(8)),

                    )
                  ) : SizedBox(),
            )
          ],
        )
    );
  }
}


