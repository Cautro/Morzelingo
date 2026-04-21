import 'package:flutter/material.dart';
import 'package:morzelingo/core/api/api_client.dart';
import 'package:morzelingo/pages/authorization/view/authorization_flow_page.dart';
import 'package:morzelingo/pages/duels/view/duels_main_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_flow_page.dart';
import 'package:morzelingo/pages/friends/view/friends_page.dart';
import 'package:morzelingo/pages/hints/view/hints_page.dart';
import 'package:morzelingo/pages/practice/presentation/view/practice_letters_page.dart';
import 'package:morzelingo/pages/profile/data/repositories/profile_repository.dart';
import 'package:morzelingo/pages/profile/presentation/view/profile_page.dart';
import 'package:morzelingo/pages/profile/presentation/view/settings_page.dart';
import 'package:morzelingo/theme_controller.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'app_theme.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


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

  void _loadAd() {
    banner = _createBanner();
    banner.loadAd(adRequest: const AdRequest());
    setState(() {
      isBannerAlreadyCreated = true;
    });
  }

  BannerAd _createBanner() {
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
            "/home": (context) => const HomeTabsPage(),
            "/login": (context) => const AuthorizationFlowPage(),
            "/freemode": (context) => const FreemodeFlowPage(),
            "/profile": (context) => ProfilePage(repository: ProfileRepository(ApiClient()),),
            "/practiceletter": (context) => const LettersFlowPage(),
            "/settings": (context) => const SettingsPage(),
            "/friends": (context) => const FriendsPage(),
            "/duels": (context) => const DuelsMainPage(),
            "/hints": (context) => const HintsPage(),
          },
          // builder: (context, child) {
          //   return Column(
          //     children: [
          //
          //       Expanded(
          //         child: child!,
          //       ),
          //
          //       if (isBannerAlreadyCreated)
          //         SizedBox(
          //           height: 60,
          //           child: AdWidget(bannerAd: banner),
          //         ),
          //     ],
          //   );
          // },
        );
      },
    );
  }
}