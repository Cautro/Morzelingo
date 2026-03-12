import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/app_theme.dart';
import 'package:morzelingo/config.dart';
import 'package:morzelingo/pages/education/context/education_context.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/settings_context.dart';
import 'dart:convert';

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

  void getData() async {
      var les = await EducationContext().getEducationData();
      setState(() {
        lessons = les;
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
        body: LoadingPage()
      );
    }

    return Scaffold(
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Container(
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
  }
}
