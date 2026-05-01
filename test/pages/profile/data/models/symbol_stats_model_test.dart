import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/pages/profile/data/models/symbol_stats_model.dart';

void main() {
  group('SymbolStatsModel', () {
    test('should parse json and convert to entity', () {
      final SymbolStatsModel model = SymbolStatsModel.fromJson(
        <String, dynamic>{
          'symbol': 'A',
          'correct': 4,
          'wrong': 2,
        },
      );

      final entity = model.toEntity();

      expect(model.symbol, 'A');
      expect(model.correct, 4);
      expect(model.wrong, 2);
      expect(entity.symbol, 'A');
      expect(entity.correct, 4);
      expect(entity.wrong, 2);
    });
  });
}
