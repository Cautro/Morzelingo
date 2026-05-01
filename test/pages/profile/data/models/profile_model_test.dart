import 'package:flutter_test/flutter_test.dart';
import 'package:morzelingo/pages/profile/data/models/profile_model.dart';

void main() {
  group('ProfileModel', () {
    test('should parse json with symbol stats and convert to entity', () {
      final ProfileModel model = ProfileModel.fromJson(<String, dynamic>{
        'username': 'alice',
        'email': 'alice@example.com',
        'streak': 5,
        'coins': 11,
        'level': 3,
        'xp': 120,
        'lesson_done_en': 2,
        'lesson_done_ru': 4,
        'referral_code': 'REF123',
        'referred_by': 'bob',
        'referred_count': 7,
        'need_xp': 30,
        'symbol_stats': <Map<String, dynamic>>[
          <String, dynamic>{'symbol': 'A', 'correct': 4, 'wrong': 1},
        ],
      });

      final entity = model.toEntity();

      expect(model.username, 'alice');
      expect(model.symbolStats, hasLength(1));
      expect(model.symbolStats.first.symbol, 'A');
      expect(entity.username, 'alice');
      expect(entity.symbol_stats, hasLength(1));
      expect(entity.symbol_stats.first.correct, 4);
      expect(entity.need_xp, 30);
    });

    test('should fill default values when optional fields are missing', () {
      final ProfileModel model = ProfileModel.fromJson(<String, dynamic>{});

      expect(model.username, '');
      expect(model.email, '');
      expect(model.streak, 0);
      expect(model.coins, 0);
      expect(model.level, 0);
      expect(model.xp, 0);
      expect(model.lesson_done_en, 0);
      expect(model.lesson_done_ru, 0);
      expect(model.referral_code, '');
      expect(model.referred_by, '');
      expect(model.referred_count, 0);
      expect(model.symbolStats, isEmpty);
      expect(model.need_xp, 0);
    });
  });
}
