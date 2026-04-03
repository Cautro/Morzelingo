import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';

import '../../../ui/app_ui.dart';

class DuelsMainPage extends StatelessWidget {
  const DuelsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Дуэли',
            subtitle: 'Соревнуйтесь в скорости и точности с другими игроками.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInfoPill(
                  icon: Icons.flash_on_rounded,
                  label: 'Режим соревнования',
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Найдите соперника и начните серию заданий на знание морзе.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: () {
                    context.read<DuelsBloc>().add(CreateDuelEvent());
                  },
                  child: const Text('Начать дуэль'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
