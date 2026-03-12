

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../../storage_context.dart';

class ProfileContext {

  Future<Map> getProfileData() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    print(data);
    var username = data["username"].toString();
    var email = data["email"].toString();
    var xp = data["xp"].toString();
    var lessondone_en = data["lesson_done_en"].toString();
    var lessondone_ru = data["lesson_done_ru"].toString();
    var level = data["level"].toString();
    var coins = data["coins"].toString();
    var streak = data["streak"].toString();
    var needxp = data["need_xp"].toString();
    var referral = data["referral_code"].toString();

    return {"username": username, "email": email, "xp": xp, "lessondone_en": lessondone_en, "lessondone_ru": lessondone_ru,
    "level": level, "coins": coins, "streak": streak, "needxp": needxp, "referral": referral, };
  }

  Future<List> getStats() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    print(data);
    List stats = data["symbol_stats"];
    print(stats);
    return stats;
  }
}