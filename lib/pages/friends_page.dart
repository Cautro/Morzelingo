import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/storage_context.dart';
import 'package:morzelingo/theme_controller.dart';

import '../app_theme.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with TickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> friends = [];
  bool isAdd = false;
  String? code;

  @override
  Future<void> getData() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/friends"),
    headers: {
      "Authorization": "Bearer $token"
    });
    final data = await jsonDecode(res.body);
    setState(() {
      friends = data["friends"];
    });
    print(friends);
    isLoading = false;
  }

  Future<void> addHandler() async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/add-to-friend"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"referral_code": code}),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Друг добавлен",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
    } else {
      Fluttertoast.showToast(
          msg: "${data["message"]}",
          backgroundColor: AppTheme.error,
          textColor: Colors.white
      );
    }
    getData();
  }

  Future<void> deleteHandler(username) async {
    String? token = await StorageService.getItem("token");
    final res = await http.post(Uri.parse("${API}/api/delete-friend"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"username": username}),
    );
    final data = jsonDecode(res.body);
    print(data);
    if (res.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Друг удалён",
          backgroundColor: AppTheme.success,
          textColor: Colors.white
      );
    } else {
      Fluttertoast.showToast(
          msg: "${data["message"]}",
          backgroundColor: AppTheme.error,
          textColor: Colors.white
      );
    }
    Duration(milliseconds: 1000);
    print("get");
    getData();
  }
  Future<void> deleteDialog(username) async {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text("Вы уверены что хотите удалить друга?"),
            content: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                    onPressed: () async {
                      deleteHandler(username);
                      Navigator.pop(context);
                    },
                    child: Text("Да, удалить!",),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Не удалять"),
                  ),
                ),
              ],
            ),
          );
        }
    );
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
        appBar: AppBar(
          title: Text("Друзья"),
        ),
        body: LoadingPage(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Друзья"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAdd = isAdd ? false : true;
                    });
                  },
                  child: Text(!isAdd ? "Добавить друга" : "Скрыть"),
                ),
              ),
              SizedBox(height: 8,),
              AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: isAdd ? Card(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              code = value.toUpperCase();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Код друга",
                          ),
                        ),
                        SizedBox(height: 8,),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              addHandler();
                            },
                            child: Text("Добавить в друзья"),
                          ),
                        )
                      ],
                    ),
                  ),
                ) : SizedBox()
              ),
              SizedBox(height: 8,),
              Expanded(
                child: friends.isNotEmpty ? Column(
                    children: friends.map((item) {
                      return Card(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("${item["username"]}", style: Theme.of(context).textTheme.titleLarge,),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.people),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                                  Text("Общая серия - ${item["streak"]}", style: Theme.of(context).textTheme.bodyLarge,),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.local_fire_department, color: Colors.orange,),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                                  Text("Серия друга - ${item["individual_streak"]}", style: Theme.of(context).textTheme.bodyLarge,),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.date_range, color: themeController.themeMode == ThemeMode.dark ? AppTheme.Darkprimary : AppTheme.primary,),
                                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                                  Text("Последняя активность - ${item["last_active"]}", style: Theme.of(context).textTheme.bodyLarge,),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    deleteDialog(item["username"]);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(8),
                                    backgroundColor: AppTheme.error
                                  ),
                                  child: Text("Удалить друга"),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList()
                ) : Center(child: Text("У вас нет друзей"),),
              )

            ],
          )
        ),
      ),
    );
  }
}
