import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/app_theme.dart';
import '../../theme_controller.dart';
import '../../settings_context.dart';
import '../bloc/morse_key_bloc.dart';
import '../bloc/morse_key_event.dart';
import '../bloc/morse_key_state.dart';

typedef MorseCallback = void Function(String decodedText);

class MorseKeyWidget extends StatelessWidget {
  final MorseCallback onTextDecoded;

  const MorseKeyWidget({super.key, required this.onTextDecoded});

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
  const _MorseKeyView({required this.onTextDecoded});

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
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Переведено:",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outline.withOpacity(0.4),
                      ),
                      color: colors.surface,
                    ),
                    child: Text(
                      state.decodedText.isEmpty ? "..." : state.decodedText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    state.currentMorse,
                    style: TextStyle(
                      fontSize: 26,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () => context.read<MorseKeyBloc>().add(AddDot()),
                    onLongPress: () => context.read<MorseKeyBloc>().add(AddDash()),
                    onTapDown: (_) => context.read<MorseKeyBloc>().add(TapDownEvent()),
                    onTapUp: (_) => context.read<MorseKeyBloc>().add(TapUpEvent()),
                    onTapCancel: () => context.read<MorseKeyBloc>().add(TapUpEvent()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: state.isPressed
                            ? (themeController.themeMode == ThemeMode.dark
                            ? AppTheme.Darkprimary.withOpacity(0.7)
                            : AppTheme.primary.withOpacity(0.7))
                            : (themeController.themeMode == ThemeMode.dark
                            ? AppTheme.Darkprimary
                            : AppTheme.primary),
                      ),
                      child: const Center(
                        child: Text(
                          "Нажать = Точка\nЗажать = Тире",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.textSecondary,
                            foregroundColor: colors.onSurface,
                          ),
                          onPressed: () => context.read<MorseKeyBloc>().add(ClearMorse()),
                          child: const Text("Очистить", style: TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(width: 8),

                      SizedBox(
                        width: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => context.read<MorseKeyBloc>().add(BackspacePressed()),
                          child: const Icon(Icons.backspace),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}