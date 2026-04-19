import 'package:morzelingo/pages/profile/domain/entities/symbol_stats.dart';

class SymbolStatsModel {
  final String symbol;
  final int correct;
  final int wrong;

  const SymbolStatsModel({required this.symbol, required this.correct, required this.wrong});

  factory SymbolStatsModel.fromJson(Map<String, dynamic> json) {
    return SymbolStatsModel(symbol: json["symbol"], correct: json["correct"], wrong: json["wrong"]);
  }
  SymbolStats toEntity() => SymbolStats(symbol: symbol, correct: correct, wrong: wrong);
}