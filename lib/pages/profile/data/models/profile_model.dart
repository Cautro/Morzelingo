import 'package:morzelingo/pages/profile/data/models/symbol_stats_model.dart';
import 'package:morzelingo/pages/profile/domain/entities/profile.dart';
import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';

class ProfileModel {
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
  final List symbol_stats;
  final int need_xp;

  ProfileModel({required this.username, required this.email, required this.streak, required this.coins, required this.level, required this.xp, required this.lesson_done_en, required this.lesson_done_ru, required this.referral_code, required this.referred_by, required this.referred_count, required this.symbol_stats, required this.need_xp});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(username: json["username"], email: json["email"], streak: json["streak"], coins: json["coins"], level: json["level"], xp: json["xp"], lesson_done_en: json["lesson_done_en"], lesson_done_ru: json["lesson_done_ru"], referral_code: json["referral_code"], referred_by: json["referred_by"], referred_count: json["referred_count"], symbol_stats: json["symbol_stats"], need_xp: json["need_xp"],);
  }

  Profile toEntity() {
    List<SymbolStats> stats = symbol_stats.map((e) => SymbolStatsModel.fromJson(e).toEntity()).toList();
    return Profile(username: username, email: email, streak: streak, coins: coins, level: level, xp: xp, lesson_done_en: lesson_done_en, lesson_done_ru: lesson_done_ru, referral_code: referral_code, referred_by: referred_by, referred_count: referred_count, symbol_stats: stats, need_xp: need_xp);
  }

}