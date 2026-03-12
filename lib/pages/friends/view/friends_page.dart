import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:morzelingo/config.dart';
import 'package:morzelingo/pages/friends/bloc/friends_bloc.dart';
import 'package:morzelingo/pages/loading_page.dart';
import 'package:morzelingo/storage_context.dart';
import 'package:morzelingo/theme_controller.dart';

import '../../../app_theme.dart';

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

  Future<void> deleteDialog(FriendsBloc bloc, String username) async {
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
                    bloc.add(DeleteFriendEvent(username: username));
                    Navigator.pop(context);
                  },
                  child: Text("Да, удалить!"),
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FriendsBloc()..add(GetFriendsEvent()),
      child: BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              if (state is FriendsListState) {
                friends = state.friends;
                isLoading = false;
              }
              if (state is AddFriendState) {
                Fluttertoast.showToast(
                  msg: state.message,
                  backgroundColor: state.success ? AppTheme.success : AppTheme.error,
                  textColor: Colors.white,
                );
              }
              if (state is DeleteFriendState) {
                Fluttertoast.showToast(
                  msg: state.message,
                  backgroundColor: state.success ? AppTheme.success : AppTheme.error,
                  textColor: Colors.white,
                );
              }
            },
            child: BlocBuilder<FriendsBloc, FriendsState> (
              builder: (context, state) {
                return isLoading ? Scaffold(
                  appBar: AppBar(
                    title: Text("Друзья"),
                  ),
                  body: LoadingPage(),
                ): Scaffold(
                  appBar: AppBar(
                    title: Text("Друзья"),
                  ),
                  body: SafeArea(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                                              context.read<FriendsBloc>().add(AddFriendEvent(code: code ?? ""));
                                              context.read<FriendsBloc>().add(GetFriendsEvent());
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
                              child: friends.isNotEmpty ? ListView(
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
                                                  deleteDialog(context.read<FriendsBloc>(), item["username"]);
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
              },
            ),
          ),
      );

  }
}
