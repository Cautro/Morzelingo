import 'package:flutter/material.dart';
import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';
import '../../../../ui/app_ui.dart';

class LettersStatsPage extends StatelessWidget {
  final List<SymbolStats> stats;

  const LettersStatsPage({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
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
                  "Буква ${item.symbol}",
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium,
                ),
                const Spacer(),
                Text(
                  "Правильно: ${item.correct}",
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Неправильно: ${item.wrong}",
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          );
        },
      ) : const AppEmptyState(
        icon: Icons.query_stats_rounded,
        title: 'У вас пока нет статистики',
        subtitle: 'Она появится после первых попыток в упражнениях.',
      ),
    );
  }

}