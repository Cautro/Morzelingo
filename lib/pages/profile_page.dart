import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import "package:morzelingo/storage_context.dart";
import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";
import "package:morzelingo/config.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? xp;
  String? lessondone;
  String? token;
  String? level;
  String? coins;

  @override

  Future<void> getProfileData() async {
    String? token = await StorageService.getItem("token");
    final res = await http.get(Uri.parse("${API}/api/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    final data = await jsonDecode(res.body);
    print(data);
    setState(() {
      username = data["username"].toString();
      email = data["email"].toString();
      xp = data["xp"].toString();
      lessondone = data["lesson_done"].toString();
      level = data["level"].toString();
      coins = data["coins"].toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _ProfileCard(
                  username: "${username}" ?? "",
                  email: "${email}" ?? "",
                  xp: "${xp}" ?? "",
                  lessondone: "${lessondone}" ?? "",
                  coins: "${coins}" ?? "",
                  level: "${level}" ?? "",
                ),
              ),
            ),
          ),
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

  const _ProfileCard({
    super.key,
    required this.username,
    required this.email,
    required this.xp,
    required this.lessondone,
    required this.coins,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsetsGeometry.all(8)),
        _ProfileItem(text: username, icon: Icon(Icons.person),),
        _ProfileItem(text: email, icon: Icon(Icons.email)),
        _ProfileItem(text: level, icon: Icon(Icons.leaderboard),),
        _ProfileItem(text: xp, icon: Icon(Icons.star_rounded)),
        _ProfileItem(text: coins, icon: Icon(Icons.monetization_on_rounded)),
        _ProfileItem(text: lessondone, icon: Icon(Icons.download_done_rounded))
      ],
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Row(
              children: [
                icon,
                Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 8)),
                Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight(550)),),
              ],
            )
        ),
      ),
    );
  }
}




