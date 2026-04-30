import 'package:flutter/foundation.dart';

abstract final class AdConfig {
  static const String _prodInterstitialAdUnitId = String.fromEnvironment(
    'YANDEX_INTERSTITIAL_AD_UNIT_ID',
  );

  static const String _demoInterstitialAdUnitId = 'demo-interstitial-yandex';

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get canShowInterstitial {
    if (!isSupportedPlatform) return false;

    if (kDebugMode || kProfileMode) return true;

    return _prodInterstitialAdUnitId.isNotEmpty;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode || kProfileMode) {
      return _demoInterstitialAdUnitId;
    }

    return _prodInterstitialAdUnitId;
  }

  static const Duration minInterstitialInterval = Duration(minutes: 5);
  static const Duration maxInterstitialInterval = Duration(minutes: 10);
}