import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';

class Profile {
  final String username;
  final String email;
  final int xp;
  final int lesson_done_ru;
  final int lesson_done_en;
  final int level;
  final int coins;
  final int streak;
  final String referral_code;
  final String referred_by;
  final int referred_count;
  final List<SymbolStats> symbol_stats;
  final int need_xp;


  const Profile({required this.username, required this.email, required this.streak, required this.coins, required this.level, required this.xp, required this.lesson_done_en, required this.lesson_done_ru, required this.referral_code, required this.referred_by, required this.referred_count, required this.symbol_stats, required this.need_xp});
}