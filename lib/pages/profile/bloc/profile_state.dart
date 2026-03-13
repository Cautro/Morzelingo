part of 'profile_bloc.dart';

class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileDataState extends ProfileState {
  ProfileDataState({required this.username, required this.email, required this.needxp, required this.streak, required this.coins, required this.lessondone_ru, required this.lessondone_en, required this.level, required this.referral, required this.xp});
  final username;
  final email;
  final xp;
  final lessondone_ru;
  final lessondone_en;
  final level;
  final coins;
  final streak;
  final needxp;
  final referral;
}

class LogoutState extends ProfileState {}

class StatsState extends ProfileState {
  StatsState({required this.stats});
  final stats;
}