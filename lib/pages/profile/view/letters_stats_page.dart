import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/profile/bloc/profile_bloc.dart';

import '../../../ui/app_ui.dart';

class LettersStatsPage extends StatefulWidget {
  const LettersStatsPage({super.key});

  @override
  State<LettersStatsPage> createState() => _LettersStatsPageState();
}

class _LettersStatsPageState extends State<LettersStatsPage> {
  List<dynamic> stats = [];
  bool isLoading = true;

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
            if (isLoading) {
              return AppPageScaffold(
                appBar: AppBar(title: const Text("Статистика букв")),
                child: const AppLoadingIndicator(),
              );
            }

            return AppPageScaffold(
              appBar: AppBar(title: const Text("Статистика букв")),
              padding: AppSpacing.pageDense,
              child: stats.isNotEmpty
                  ? GridView.builder(
                      itemCount: stats.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        final item = stats[index];
                        return AppSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Буква ${item["symbol"]}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                "Правильно: ${item["correct"]}",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                "Неправильно: ${item["wrong"]}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const AppEmptyState(
                      icon: Icons.query_stats_rounded,
                      title: 'У вас пока нет статистики',
                      subtitle: 'Она появится после первых попыток в упражнениях.',
                    ),
            );
          },
        ),
      ),
    );
  }
}
