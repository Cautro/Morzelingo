import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui/app_ui.dart';
import '../bloc/morse_key_bloc.dart';

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
      create: (_) => MorseKeyBloc()..add(const InitMorseKeyEvent()),
      child: _MorseKeyView(onTextDecoded: onTextDecoded),
    );
  }
}

class _MorseKeyView extends StatelessWidget {
  final MorseCallback onTextDecoded;

  const _MorseKeyView({required this.onTextDecoded});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MorseKeyBloc, MorseKeyState>(
      listenWhen: (prev, curr) => prev.decodedText != curr.decodedText,
      listener: (context, state) => onTextDecoded(state.decodedText),
      child: BlocBuilder<MorseKeyBloc, MorseKeyState>(
        builder: (context, state) => _MorseKeyContent(state: state),
      ),
    );
  }
}

class _MorseKeyContent extends StatelessWidget {
  final MorseKeyState state;

  const _MorseKeyContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Ввод азбуки Морзе',
            subtitle: 'Короткое нажатие — точка, длинное удержание — тире.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _DecodedTextDisplay(text: state.decodedText, colors: colors, theme: theme),
          const SizedBox(height: AppSpacing.md),
          _CurrentMorseDisplay(morse: state.currentMorse, theme: theme),
          const SizedBox(height: AppSpacing.lg),
          _MorseKeyButton(isPressed: state.isPressed, colors: colors, theme: theme),
          const SizedBox(height: AppSpacing.md),
          _ActionButtons(),
        ],
      ),
    );
  }
}

class _DecodedTextDisplay extends StatelessWidget {
  final String text;
  final ColorScheme colors;
  final ThemeData theme;

  const _DecodedTextDisplay({
    required this.text,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: AppRadii.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Переведено', style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            text.isEmpty ? '...' : text,
            style: theme.textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class _CurrentMorseDisplay extends StatelessWidget {
  final String morse;
  final ThemeData theme;

  const _CurrentMorseDisplay({required this.morse, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: AppRadii.md,
        border: Border.all(color: theme.dividerColor),
        color: theme.cardColor,
      ),
      child: Text(
        morse.isEmpty ? '• • •' : morse,
        style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 4),
      ),
    );
  }
}

class _MorseKeyButton extends StatelessWidget {
  final bool isPressed;
  final ColorScheme colors;
  final ThemeData theme;

  const _MorseKeyButton({
    required this.isPressed,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<MorseKeyBloc>().add(const AddDotEvent());
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        context.read<MorseKeyBloc>().add(const AddDashEvent());
      },
      onTapDown: (_) => context.read<MorseKeyBloc>().add(const TapDownEvent()),
      onTapUp: (_) => context.read<MorseKeyBloc>().add(const TapUpEvent()),
      onTapCancel: () => context.read<MorseKeyBloc>().add(const TapUpEvent()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        height: 156,
        decoration: BoxDecoration(
          borderRadius: AppRadii.lg,
          color: isPressed
              ? colors.primary.withOpacity(0.82)
              : colors.primary,
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
                'Нажать = Точка\nЗажать = Тире',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppSecondaryButton(
            onPressed: () => context.read<MorseKeyBloc>().add(const AddSpaceEvent()),
            child: const Text('Пробел'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 88,
          child: AppDangerButton(
            expanded: false,
            onPressed: () => context.read<MorseKeyBloc>().add(const BackspaceEvent()),
            child: const Icon(Icons.backspace_outlined),
          ),
        ),
      ],
    );
  }
}