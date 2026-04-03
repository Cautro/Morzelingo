import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';

import '../../../ui/app_ui.dart';

class DuelsActivePage extends StatelessWidget {
  final String opponent;

  const DuelsActivePage({
    super.key,
    required this.opponent,
  });

  Future<void> _leaveDialog(BuildContext context) async {
    final duelsBloc = context.read<DuelsBloc>();

    return showDialog(
      context: context,
      builder: (dialogContext) => AppConfirmationDialog(
        title: 'Покинуть дуэль?',
        message: 'Если выйти сейчас, текущая дуэль будет отменена.',
        confirmLabel: 'Да, покинуть',
        cancelLabel: 'Остаться',
        destructive: true,
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          duelsBloc.add(LeaveEvent());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Дуэль готова',
            subtitle: 'Противник найден. Можно переходить к заданиям.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ваш противник', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(opponent, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: () {
                    context.read<DuelsBloc>().add(GetTasksEvent());
                  },
                  child: const Text('К заданиям'),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDangerButton(
                  onPressed: () async {
                    await _leaveDialog(context);
                  },
                  child: const Text('Покинуть дуэль'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
