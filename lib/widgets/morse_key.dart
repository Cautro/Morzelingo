import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

typedef MorseCallback = void Function(String decodedText);

class MorseKeyWidget extends StatefulWidget {
  final MorseCallback onTextDecoded;

  const MorseKeyWidget({super.key, required this.onTextDecoded});

  @override
  State<MorseKeyWidget> createState() => _MorseKeyWidgetState();
}

class _MorseKeyWidgetState extends State<MorseKeyWidget> {
  static const Map<String, String> morseToText = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z',
    '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6',
    '--...': '7', '---..': '8', '----.': '9',
    '/': ' '
  };

  final player = AudioPlayer();
  String currentMorse = "";
  String decodedText = "";
  Timer? pauseTimer;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    player.setReleaseMode(ReleaseMode.stop);
  }

  void _addDot() async {
    await player.play(AssetSource('sounds/dot.wav'));
    _addSymbol('.');
  }

  void _addDash() async {
    await player.play(AssetSource('sounds/dash.wav'));
    _addSymbol('-');
  }

  void _addSymbol(String symbol) {
    setState(() {
      currentMorse += symbol;
    });

    pauseTimer?.cancel();
    pauseTimer = Timer(const Duration(milliseconds: 900), _finishLetter);
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

    pauseTimer = Timer(const Duration(milliseconds: 1800), _addSpace);
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                decodedText.isEmpty ? "..." : decodedText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 24),

            /// Текущий сигнал
            Text(
              currentMorse,
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 24),

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
                      ? Theme.of(context).primaryColor.withOpacity(0.7)
                      : Theme.of(context).primaryColor,
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

            SizedBox(height: 16),

            /// Очистка
            TextButton(
              onPressed: _clear,
              child: const Text("Очистить"),
            ),
          ],
        ),
      ),
    );
  }
}