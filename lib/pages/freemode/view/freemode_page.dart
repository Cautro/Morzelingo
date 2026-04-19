import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';

import '../../../ui/app_ui.dart';

class FreemodePage extends StatelessWidget {
  const FreemodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Свободный режим',
            subtitle: 'Практикуйтесь в удобном формате с бесконечным количеством заданий.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите формат практики',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Режим аудио воспроизводит азбуку Морзе, а текстовый режим оставляет ввод через морзянку.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: () {
                    context.read<FreemodeBloc>().add(
                          const GetEvent(mode: FreemodeMode.audio),
                        );
                  },
                  child: const Text('Играть в режиме аудио'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  onPressed: () {
                    context.read<FreemodeBloc>().add(
                          const GetEvent(mode: FreemodeMode.text),
                        );
                  },
                  child: const Text('Играть в режиме текста'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
