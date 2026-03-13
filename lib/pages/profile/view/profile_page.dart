import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:http/http.dart' as http;
import "package:morzelingo/app_theme.dart";
import "package:morzelingo/pages/loading_page.dart";
import "package:morzelingo/pages/profile/bloc/profile_bloc.dart";
import "package:morzelingo/settings_context.dart";
import "package:morzelingo/storage_context.dart";
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "package:morzelingo/config.dart";

import "../../../theme_controller.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? xp;
  String? lessondone_en;
  String? lessondone_ru;
  String? token;
  String? level;
  String? coins;
  String? streak;
  String? needxp;
  String? referral;
  bool isLoading = true;

  @override


  void Logout(ProfileBloc bloc,) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Вы уверены что хотите выйти?"),
            content: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                    onPressed: () async {
                      bloc.add(LogoutEvent());
                    },
                    child: Text("Выйти!",),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Остаться"),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => ProfileBloc()..add(GetProfileDataEvent()),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileDataState) {
            setState(() {
              xp = state.xp;
              referral = state.referral;
              level = state.level;
              lessondone_en = state.lessondone_en;
              lessondone_ru = state.lessondone_ru;
              coins = state.coins;
              streak = state.streak;
              needxp = state.needxp;
              referral = state.referral;
              email = state.email;
              username = state.username;
              isLoading = false;
            });
          }
          if (state is LogoutState) {
            Navigator.pushReplacementNamed(context, "/login");
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return isLoading ? Scaffold(body: LoadingPage(),) : Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, "/settings");
                                  },
                                  icon: Icon(Icons.settings),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person, size: 50, color: themeController.themeMode == ThemeMode.dark ? AppTheme.DarktextPrimary : AppTheme.textPrimary,),
                              ],
                            ),
                            SizedBox(height: 8,),
                            Text(username!, style: Theme.of(context).textTheme.titleLarge,),
                            _ProfileCard(
                              username: "${username}" ?? "",
                              email: "${email}" ?? "",
                              xp: "${xp}" ?? "",
                              lessondone: "${SettingsService.getLang() == "en" ? lessondone_en : lessondone_ru}" ?? "",
                              coins: "${coins}" ?? "",
                              level: "${level}" ?? "",
                              streak: "${streak}" ?? "",
                              needxp: "${needxp}" ?? "",
                              refferal: "${referral}" ?? "",
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Logout(context.read<ProfileBloc>());
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.error),
                                  child: Text("Выйти из аккаунта", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),),
                                )
                            )

                          ],
                        )

                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

  }
}

class _ProfileCard extends StatelessWidget {
  final String username;
  final String email;
  final String xp;
  final String lessondone;
  final String coins;
  final String level;
  final String streak;
  final String needxp;
  final String refferal;

  const _ProfileCard({
    super.key,
    required this.username,
    required this.email,
    required this.xp,
    required this.lessondone,
    required this.coins,
    required this.level,
    required this.streak,
    required this.needxp,
    required this.refferal,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsetsGeometry.all(8)),
          Row(
            children: [
              _ProfileItem(text: level, icon: Icon(Icons.leaderboard, color: Colors.blue  ,)),
              _ProfileItem(text: xp, icon: Icon(Icons.star_rounded, color: Colors.amber,)),
            ]
          ),
          Row(
              children: [
                _ProfileItem(text: streak, icon: Icon(Icons.local_fire_department, color: Colors.orange,)),
                _ProfileItem(text: lessondone, icon: Icon(Icons.done_outline, color: AppTheme.success,)),
              ]
          ),
          Row(
            children: [
              _ProfileItem(text: "Опыта до повышения: ${needxp}", icon: Icon(Icons.upgrade, color: Colors.amber ,)),
            ],
          ),
          Row(
            children: [
              _ProfileItem(text: "Реферальный код: ${refferal}", icon: Icon(Icons.link, color: Colors.blue,))
            ],
          ),
          SizedBox(height: 8,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/friends");
                  },
                  child: Text("Друзья"),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/lettersstats");
                  },
                  child: Text("Статистика букв"),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String text;
  final Icon icon;
  const _ProfileItem({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Row(
              children: [
                icon,
                Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 8)),
                Text(text, style: Theme.of(context).textTheme.bodyLarge),
              ],
            )
        ),
      ),
    );
  }
}




