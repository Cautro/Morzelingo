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
  // Словарь Морзе
  static const Map<String, String> morseToText = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z',
    '-----': '0', '.----': '1', '..---': '2', '...--': '3', '....-': '4',
    '.....': '5', '-....': '6', '--...': '7', '---..': '8', '----.': '9',
    '.-.-.-': '.', '--..--': ',', '..--..': '?', '.----.': '\'',
    '-.-.--': '!', '-..-.': '/', '-.--.': '(', '-.--.-': ')',
    '.-...': '&', '---...': ':', '-.-.-.': ';', '-...-': '=',
    '.-.-.': '+', '-....-': '-', '..--.-': '_', '.-..-.': '"',
    '...-..-': r'$', '.--.-.': '@', '/': ' '
  };

  final player = AudioPlayer();
  String currentMorse = "";
  String decodedText = "";

  Timer? pauseTimer;

  @override
  void initState() {
    super.initState();
    player.setReleaseMode(ReleaseMode.stop);
  }

  void _addDot() async {
    await player.play(AssetSource('sounds/morse-dot.wav'));
    _addSymbol('.');
  }

  void _addDash() async {
    await player.play(AssetSource('sounds/morse-dash.wav'));
    _addSymbol('-');
  }

  void _addSymbol(String symbol) {
    currentMorse += symbol;

    // Таймер паузы между буквами
    pauseTimer?.cancel();
    pauseTimer = Timer(Duration(milliseconds: 1000), _finishLetter);
  }

  void _finishLetter() {
    String? letter = morseToText[currentMorse];
    if (letter != null) {
      decodedText += letter;
      widget.onTextDecoded(decodedText); // передаем наружу
    }
    currentMorse = "";

    // Таймер для пробела между словами
    pauseTimer = Timer(Duration(milliseconds: 2000), _addSpace);
  }

  void _addSpace() {
    if (decodedText.isNotEmpty && !decodedText.endsWith(' ')) {
      decodedText += ' ';
      widget.onTextDecoded(decodedText); // обновляем наружный виджет
    }
  }

  @override
  void dispose() {
    pauseTimer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 200),
      ),
      onPressed: _addDot,
      onLongPress: _addDash,
      child: Text(currentMorse.isEmpty ? "Press / Long Press" : currentMorse),
    );
  }
}