import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/morse/morse_alphabet.dart';

String morseCodeForLetter(Map<String, String> alphabet, String letter) {
  return alphabet.entries.firstWhere((MapEntry<String, String> entry) {
    return entry.value == letter;
  }).key;
}

void main() {
  group('MorseAlphabet', () {
    test('should return russian alphabet only for ru language', () {
      expect(MorseAlphabet.forLang('ru'), same(MorseAlphabet.ru));
      expect(MorseAlphabet.forLang('en'), same(MorseAlphabet.en));
      expect(MorseAlphabet.forLang('de'), same(MorseAlphabet.en));
    });

    test('should decode multiple words for selected language', () {
      final String codeA = morseCodeForLetter(MorseAlphabet.en, 'A');
      final String codeB = morseCodeForLetter(MorseAlphabet.en, 'B');
      final String codeC = morseCodeForLetter(MorseAlphabet.en, 'C');

      final String result = MorseAlphabet.decodeMorse(
        '$codeA $codeB  $codeC',
        'en',
      );

      expect(result, 'AB C');
    });

    test('should ignore unknown symbols while decoding', () {
      final String codeA = morseCodeForLetter(MorseAlphabet.en, 'A');

      final String result = MorseAlphabet.decodeMorse('??? $codeA', 'en');

      expect(result, 'A');
    });
  });
}
