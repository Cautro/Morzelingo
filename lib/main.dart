import 'package:flutter/material.dart';
import 'package:morzelingo/pages/letters_stats_page.dart';
import 'package:morzelingo/theme_controller.dart';
import 'app_theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'package:morzelingo/pages/completed_lessons_page.dart';
import 'package:morzelingo/pages/freemode_audio_page.dart';
import 'package:morzelingo/pages/freemode_page.dart';
import 'package:morzelingo/pages/freemode_text_page.dart';
import 'package:morzelingo/pages/lesson_page.dart';
import 'package:morzelingo/pages/practice_letters_page.dart';
import 'package:morzelingo/pages/practice_page.dart';
import 'package:morzelingo/pages/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,

          initialRoute: "/login",

          routes: {
            "/home": (context) => HomeTabsPage(),
            "/register": (context) => RegisterPage(),
            "/login": (context) => LoginPage(),
            "/freemode": (context) => FreemodePage(),
            "/freemodetext": (context) => FreemodeTextPage(),
            "/freemodeaudio": (context) => FreemodeAudioPage(),
            "/profile": (context) => ProfilePage(),
            "/lesson": (context) => LessonPage(),
            "/completedlessons": (context) => CompletedLessonsPage(),
            "/practice": (context) => PracticePage(),
            "/practiceletter": (context) => PracticeLettersPage(),
            "/settings": (context) => SettingsPage(),
            "/lettersstats": (context) => LettersStatsPage(),
          },
        );
      },
    );
  }
}