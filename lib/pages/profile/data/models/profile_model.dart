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
  final List<SymbolStatsModel> symbolStats;
  final int need_xp;

  ProfileModel({
    required this.username,
    required this.email,
    required this.streak,
    required this.coins,
    required this.level,
    required this.xp,
    required this.lesson_done_en,
    required this.lesson_done_ru,
    required this.referral_code,
    required this.referred_by,
    required this.referred_count,
    required this.symbolStats,
    required this.need_xp,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      streak: json["streak"] ?? 0,
      coins: json["coins"] ?? 0,
      level: json["level"] ?? 0,
      xp: json["xp"] ?? 0,
      lesson_done_en: json["lesson_done_en"] ?? 0,
      lesson_done_ru: json["lesson_done_ru"] ?? 0,
      referral_code: json["referral_code"] ?? "",
      referred_by: json["referred_by"] ?? "",
      referred_count: json["referred_count"] ?? 0,
      symbolStats: (json["symbol_stats"] as List<dynamic>? ?? [])
          .map((e) => SymbolStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      need_xp: json["need_xp"] ?? 0,
    );
  }

  Profile toEntity() {
    return Profile(
      username: username,
      email: email,
      streak: streak,
      coins: coins,
      level: level,
      xp: xp,
      lesson_done_en: lesson_done_en,
      lesson_done_ru: lesson_done_ru,
      referral_code: referral_code,
      referred_by: referred_by,
      referred_count: referred_count,
      symbol_stats: symbolStats.map((e) => e.toEntity()).toList(),
      need_xp: need_xp,
    );
  }
}