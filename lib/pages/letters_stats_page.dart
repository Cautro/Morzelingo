import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../storage_context.dart';

class LettersStatsPage extends StatefulWidget {
  const LettersStatsPage({super.key});

  @override
  State<LettersStatsPage> createState() => _LettersStatsPageState();
}

class _LettersStatsPageState extends State<LettersStatsPage> {
  List<dynamic> stats = [];

  @override

  void getData() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    print(data);
    setState(() {
      stats = data["symbol_stats"];
    });
    print(stats);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Статистика букв"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: stats.isNotEmpty ? GridView.count(
            childAspectRatio: 1.75,
            crossAxisCount: 2,
            children: stats.map((item) {
              return SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min  ,
                      children: [
                        Row(
                          children: [
                            Text("Буква ${item["symbol"]}", style: Theme.of(context).textTheme.bodyLarge,)
                          ],
                        ),
                        Row(
                          children: [
                            Text("Правильно: ${item["correct"]}")
                          ],
                        ),
                        Row(
                          children: [
                            Text("Неправильно: ${item["wrong"]}")
                          ],
                        )
                      ],
                    )
                  ),
                ),
              );
            }).toList()
          ) : Center(child: Text("У вас пока нет статистики"),)
        ),
      ),
    );
  }
}
