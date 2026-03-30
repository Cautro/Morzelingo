
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/profile/bloc/profile_bloc.dart';


class LettersStatsPage extends StatefulWidget {
  const LettersStatsPage({super.key});

  @override
  State<LettersStatsPage> createState() => _LettersStatsPageState();
}

class _LettersStatsPageState extends State<LettersStatsPage> {
  List<dynamic> stats = [];
  bool isLoading = true;

  @override



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(GetStatsEvent()),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is StatsState) {
            setState(() {
              stats = state.stats;
              isLoading = false;
            });
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
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
          },
        ),
      ),
    );

  }
}
