import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/settings_context.dart';

import '../../ui/app_ui.dart';
import '../bloc/morse_key_bloc.dart';
import '../bloc/morse_key_event.dart';
import '../bloc/morse_key_state.dart';

typedef MorseCallback = void Function(String decodedText);

class MorseKeyWidget extends StatelessWidget {
  final MorseCallback onTextDecoded;

  const MorseKeyWidget({
    super.key,
    required this.onTextDecoded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MorseKeyBloc(
        settingsService: SettingsService(),
      )..add(InitMorseKey()),
      child: _MorseKeyView(onTextDecoded: onTextDecoded),
    );
  }
}

class _MorseKeyView extends StatelessWidget {
  final MorseCallback onTextDecoded;

  const _MorseKeyView({
    required this.onTextDecoded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<MorseKeyBloc, MorseKeyState>(
      listenWhen: (prev, curr) => prev.decodedText != curr.decodedText,
      listener: (context, state) {
        onTextDecoded(state.decodedText);
      },
      child: BlocBuilder<MorseKeyBloc, MorseKeyState>(
        builder: (context, state) {
          return AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionHeader(
                  title: 'Ввод азбуки Морзе',
                  subtitle: 'Короткое нажатие добавляет точку, длинное удержание — тире.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.08),
                    borderRadius: AppRadii.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Переведено',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        state.decodedText.isEmpty ? "..." : state.decodedText,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.md,
                    border: Border.all(color: theme.dividerColor),
                    color: theme.cardColor,
                  ),
                  child: Text(
                    state.currentMorse.isEmpty ? '• • •' : state.currentMorse,
                    style: theme.textTheme.titleLarge?.copyWith(
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: () => context.read<MorseKeyBloc>().add(AddDot()),
                  onLongPress: () => context.read<MorseKeyBloc>().add(AddDash()),
                  onTapDown: (_) => context.read<MorseKeyBloc>().add(TapDownEvent()),
                  onTapUp: (_) => context.read<MorseKeyBloc>().add(TapUpEvent()),
                  onTapCancel: () => context.read<MorseKeyBloc>().add(TapUpEvent()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: double.infinity,
                    height: 156,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.lg,
                      color: state.isPressed ? colors.primary.withOpacity(0.82) : colors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded, color: colors.onPrimary, size: 30),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            "Нажать = Точка\nЗажать = Тире",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppSecondaryButton(
                        onPressed: () => context.read<MorseKeyBloc>().add(ClearMorse()),
                        child: const Text('Очистить'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 88,
                      child: AppDangerButton(
                        expanded: false,
                        onPressed: () => context.read<MorseKeyBloc>().add(BackspacePressed()),
                        child: const Icon(Icons.backspace_outlined),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
