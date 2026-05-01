import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/core/morse/morse_timings.dart';

void main() {
  group('MorseTiming', () {
    test('should calculate timing values from valid wpm', () {
      final MorseTiming timing = MorseTiming.fromWpm(10);

      expect(timing.dot, 120);
      expect(timing.dash, 360);
      expect(timing.symbolPause, 120);
      expect(timing.letterPause, 360);
      expect(timing.wordPause, 840);
    });

    test('should clamp wpm to lower boundary', () {
      final MorseTiming timing = MorseTiming.fromWpm(1);

      expect(timing.dot, 240);
      expect(timing.wordPause, 1680);
    });

    test('should clamp wpm to upper boundary', () {
      final MorseTiming timing = MorseTiming.fromWpm(50);

      expect(timing.dot, 60);
      expect(timing.wordPause, 420);
    });
  });
}
