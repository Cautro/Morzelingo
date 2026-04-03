import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/duels/bloc/duels_bloc.dart';

import '../../../ui/app_ui.dart';

class DuelsWaitingPage extends StatelessWidget {
  const DuelsWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      bottomBar: AppDangerButton(
        onPressed: () {
          context.read<DuelsBloc>().add(LeaveEvent());
        },
        child: const Text('Отменить'),
      ),
      child: const AppEmptyState(
        icon: Icons.hourglass_top_rounded,
        title: 'Ожидание соперника',
        subtitle: 'Поиск дуэли активен. Как только найдётся противник, матч начнётся автоматически.',
      ),
    );
  }
}