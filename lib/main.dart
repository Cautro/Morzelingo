import 'package:flutter/material.dart';
import 'package:morzelingo/pages/authorization/view/login_page.dart';
import 'package:morzelingo/pages/authorization/view/register_page.dart';
import 'package:morzelingo/pages/duels/view/duels_main_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_page.dart';
import 'package:morzelingo/pages/friends/view/friends_page.dart';
import 'package:morzelingo/pages/profile/view/letters_stats_page.dart';
import 'package:morzelingo/pages/profile/view/profile_page.dart';
import 'package:morzelingo/theme_controller.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'app_theme.dart';
import 'pages/home_page.dart';
import 'package:morzelingo/pages/education/view/completed_lessons_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_audio_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_text_page.dart';
import 'package:morzelingo/pages/education/view/lesson_page.dart';
import 'package:morzelingo/pages/practice/view/practice_letters_page.dart';
import 'package:morzelingo/pages/practice/view/practice_page.dart';
import 'package:morzelingo/pages/profile/view/settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MobileAds.setUserConsent(true);
    MobileAds.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  BannerAdSize _getAdSize() {
    final screenwidth = MediaQuery.of(context).size.width.round();
    return BannerAdSize.inline(width: screenwidth, maxHeight: 60);
    }

  late BannerAd banner;
  var isBannerAlreadyCreated = false;

  _loadAd() {
    banner = _createBanner();
    banner.loadAd(adRequest: AdRequest());
    setState(() {
      isBannerAlreadyCreated = true;
    });
  }

  _createBanner() {
    return BannerAd(
        adUnitId: 'R-M-18875854-1', // or 'demo-banner-yandex'
        adSize: _getAdSize(),
        adRequest: const AdRequest(),
    );
  }

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
            "/friends": (context) => FriendsPage(),
            "/duels": (context) => DuelsMainPage(),
          },
          builder: (context, child) {
            return Column(
              children: [

                Expanded(
                  child: child!,
                ),

                if (isBannerAlreadyCreated)
                  SizedBox(
                    height: 60,
                    child: AdWidget(bannerAd: banner),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}