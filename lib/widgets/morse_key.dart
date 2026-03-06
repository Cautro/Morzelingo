import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:morzelingo/app_theme.dart';

import '../settings_context.dart';

typedef MorseCallback = void Function(String decodedText);

class MorseKeyWidget extends StatefulWidget {
  final MorseCallback onTextDecoded;

  const MorseKeyWidget({super.key, required this.onTextDecoded});

  @override
  State<MorseKeyWidget> createState() => _MorseKeyWidgetState();
}

class _MorseKeyWidgetState extends State<MorseKeyWidget> {
  static const Map<String, String> morseToText = {
    '•—': 'A', '—•••': 'B', '—•—•': 'C', '—••': 'D', '•': 'E',
    '••—•': 'F', '——•': 'G', '••••': 'H', '••': 'I', '•———': 'J',
    '—•—': 'K', '•—••': 'L', '——': 'M', '—•': 'N', '———': 'O',
    '•——•': 'P', '——•—': 'Q', '•—•': 'R', '•••': 'S', '—': 'T',
    '••—': 'U', '•••—': 'V', '•——': 'W', '—••—': 'X', '—•——': 'Y',
    '——••': 'Z',
    '—————': '0', '•————': '1', '••———': '2', '•••——': '3',
    '••••—': '4', '•••••': '5', '—••••': '6',
    '——•••': '7', '———••': '8', '————•': '9',
    '/': ' '
  };

  final player = AudioPlayer();
  String currentMorse = "";
  String decodedText = "";
  Timer? pauseTimer;
  bool isPressed = false;
  late MorseTiming timing;

  @override
  void initState() {
    super.initState();
    player.setReleaseMode(ReleaseMode.stop);
    _loadTiming();
  }

  Future<void> _loadTiming() async {
    final wpm = await SettingsService.getWpm();
    setState(() {
      timing = MorseTiming(wpm);
    });
  }

  void _addDot() async {
    await player.play(AssetSource('sounds/dot.wav'));
    _addSymbol('•');
  }

  void _addDash() async {
    await player.play(AssetSource('sounds/dash.wav'));
    _addSymbol('—');
  }

  void _addSymbol(String symbol) {
    setState(() {
      currentMorse += symbol;
    });

    pauseTimer?.cancel();
    pauseTimer = Timer(
      Duration(milliseconds: timing.letterPause * 4),
      _finishLetter,
    );
  }
  
  void _finishLetter() {
    String? letter = morseToText[currentMorse];
    if (letter != null) {
      setState(() {
        decodedText += letter;
      });
      widget.onTextDecoded(decodedText);
    }

    setState(() {
      currentMorse = "";
    });

    pauseTimer = Timer(
      Duration(milliseconds: timing.wordPause + timing.letterPause),
      _addSpace,
    );
  }

  void _addSpace() {
    if (decodedText.isNotEmpty && !decodedText.endsWith(' ')) {
      setState(() {
        decodedText += ' ';
      });
      widget.onTextDecoded(decodedText);
    }
  }

  void _clear() {
    pauseTimer?.cancel();
    setState(() {
      currentMorse = "";
      decodedText = "";
    });
    widget.onTextDecoded("");
  }

  @override
  void dispose() {
    pauseTimer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            /// Расшифрованный текст
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Decoded:",
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
                decodedText.isEmpty ? "..." : decodedText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Текущий сигнал
            Text(
              currentMorse,
              style: TextStyle(
                fontSize: 26,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 24),

            /// Телеграфный ключ
            GestureDetector(
              onTap: _addDot,
              onLongPress: _addDash,
              onTapDown: (_) => setState(() => isPressed = true),
              onTapUp: (_) => setState(() => isPressed = false),
              onTapCancel: () => setState(() => isPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isPressed
                      ? colors.primary.withOpacity(0.7)
                      : colors.primary,
                ),
                child: const Center(
                  child: Text(
                    "Tap = Dot\nHold = Dash",
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

            /// Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textSecondary,
                      foregroundColor: colors.onSurface,
                    ),
                    onPressed: _clear,
                    child: const Text("Очистить",style: TextStyle(color: Colors.white),),
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
                    onPressed: () {
                      setState(() {
                        if (decodedText.isNotEmpty) {
                          decodedText =
                              decodedText.substring(0, decodedText.length - 1);
                        }
                      });
                    },
                    child: const Icon(Icons.backspace),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}