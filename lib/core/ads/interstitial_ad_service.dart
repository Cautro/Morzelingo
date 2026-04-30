import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

import 'ad_config.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static final InterstitialAdService instance = InterstitialAdService._();

  final InterstitialAdLoader _loader = InterstitialAdLoader();
  final Random _random = Random();

  InterstitialAd? _ad;

  bool _isLoading = false;
  bool _isShowing = false;

  DateTime? _nextAllowedAt;

  int _failedLoadAttempts = 0;
  Timer? _retryTimer;

  void start() {
    _nextAllowedAt = DateTime.now().add(_randomInterval());
    unawaited(preload());
  }

  Future<void> preload() async {
    if (!AdConfig.canShowInterstitial) return;
    if (_isLoading) return;
    if (_ad != null) return;

    _isLoading = true;

    try {
      final InterstitialAd ad = await _loader.loadAd(
        adRequest: AdRequest(
          adUnitId: AdConfig.interstitialAdUnitId,
        ),
      );

      _ad = ad;
      _failedLoadAttempts = 0;

      if (kDebugMode) {
        debugPrint('Interstitial loaded');
      }
    } on AdRequestError catch (error) {
      _ad = null;
      _failedLoadAttempts++;

      if (kDebugMode) {
        debugPrint(
          'Interstitial failed to load: '
              '${error.code}, ${error.description}',
        );
      }

      _scheduleRetry();
    } catch (error, stack) {
      _ad = null;
      _failedLoadAttempts++;

      if (kDebugMode) {
        debugPrint('Unexpected interstitial load error: $error');
        debugPrintStack(stackTrace: stack);
      }

      _scheduleRetry();
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> tryShow({
    required String placement,
    bool force = false,
  }) async {
    if (!AdConfig.canShowInterstitial) return false;
    if (_isShowing) return false;

    if (!force && !_isTimeAllowed()) {
      unawaited(preload());
      return false;
    }

    final InterstitialAd? ad = _ad;

    if (ad == null) {
      unawaited(preload());
      return false;
    }

    _ad = null;
    _isShowing = true;

    ad.setAdEventListener(
      eventListener: InterstitialAdEventListener(
        onAdShown: () {
          if (kDebugMode) {
            debugPrint('Interstitial shown. placement=$placement');
          }
        },
        onAdFailedToShow: (error) {
          if (kDebugMode) {
            debugPrint(
              'Interstitial failed to show: '
                  '${error}, ${error.description}',
            );
          }
        },
        onAdClicked: () {
          if (kDebugMode) {
            debugPrint('Interstitial clicked');
          }
        },
        onAdDismissed: () {
          if (kDebugMode) {
            debugPrint('Interstitial dismissed');
          }
        },
        onAdImpression: (impressionData) {
          if (kDebugMode) {
            debugPrint(
              'Interstitial impression: ${impressionData.getRawData()}',
            );
          }
        },
      ),
    );

    try {
      await ad.show();
      await ad.waitForDismiss();

      return true;
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('Interstitial show error: $error');
        debugPrintStack(stackTrace: stack);
      }

      return false;
    } finally {
      ad.destroy();

      _isShowing = false;
      _nextAllowedAt = DateTime.now().add(_randomInterval());

      unawaited(preload());
    }
  }

  void dispose() {
    _retryTimer?.cancel();
    _ad?.destroy();
    _ad = null;
  }

  bool _isTimeAllowed() {
    final DateTime? nextAllowedAt = _nextAllowedAt;

    if (nextAllowedAt == null) return true;

    return DateTime.now().isAfter(nextAllowedAt);
  }

  Duration _randomInterval() {
    final int min = AdConfig.minInterstitialInterval.inSeconds;
    final int max = AdConfig.maxInterstitialInterval.inSeconds;

    final int seconds = min + _random.nextInt(max - min + 1);

    return Duration(seconds: seconds);
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive ?? false) return;

    if (_failedLoadAttempts > 3) {
      return;
    }

    final Duration delay = Duration(
      seconds: 20 * _failedLoadAttempts,
    );

    _retryTimer = Timer(delay, () {
      unawaited(preload());
    });
  }
}