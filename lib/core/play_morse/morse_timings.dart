class MorseTiming {
  final int dot;
  final int dash;
  final int symbolPause;
  final int letterPause;
  final int wordPause;

  MorseTiming._({
    required this.dot,
    required this.dash,
    required this.symbolPause,
    required this.letterPause,
    required this.wordPause,
  });

  factory MorseTiming.fromWpm(int wpm) {
    final safeWpm = wpm.clamp(5, 20);
    final dot = (1200 / safeWpm).round();

    return MorseTiming._(
      dot: dot,
      dash: dot * 3,
      symbolPause: dot,
      letterPause: dot * 3,
      wordPause: dot * 7,
    );
  }
}