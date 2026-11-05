import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service responsible for initializing Google Mobile Ads and handling
/// Banner & Interstitial (Full Screen) ads for Android and iOS.
class AdService {
  AdService({MobileAds? mobileAds}) : _mobileAds = mobileAds ?? MobileAds.instance;

  final MobileAds _mobileAds;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;

  /// Primary Android Interstitial Ad Unit ID
  static const String _androidPrimaryInterstitialId = 'ca-app-pub-4265159290601827/6415017189';
  /// Google Official Android Test Interstitial Ad Unit ID
  static const String _androidTestInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  /// Primary Android Banner Ad Unit ID
  static const String _androidPrimaryBannerId = 'ca-app-pub-4265159290601827/1193871288';
  /// Google Official Android Test Banner Ad Unit ID
  static const String _androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return _androidPrimaryBannerId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return _androidPrimaryInterstitialId;
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  /// Initialize Mobile Ads SDK and immediately preload an interstitial ad
  Future<InitializationStatus> initialize() async {
    final status = await _mobileAds.initialize();
    loadInterstitialAd();
    return status;
  }

  /// Load Interstitial (Full Screen) Ad, falling back to Google Test Ad Unit if needed
  void loadInterstitialAd({String? customAdUnitId, bool isFallback = false}) {
    final adUnitId = customAdUnitId ?? interstitialAdUnitId;
    if (adUnitId.isEmpty || _isInterstitialAdLoading || _interstitialAd != null) return;

    _isInterstitialAdLoading = true;
    debugPrint('Loading InterstitialAd with ID: $adUnitId (isFallback: $isFallback)');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd loaded successfully!');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd failed to load ($adUnitId): $error');

          // If primary custom ad unit failed to load (e.g. Error code 3 / No Fill on new AdMob ID),
          // fallback to official Google Test Ad Unit ID so ads are guaranteed to show in testing!
          if (!isFallback && Platform.isAndroid && adUnitId != _androidTestInterstitialId) {
            debugPrint('Attempting fallback to Google Test Interstitial Ad Unit ID...');
            loadInterstitialAd(customAdUnitId: _androidTestInterstitialId, isFallback: true);
          }
        },
      ),
    );
  }

  /// Show Interstitial (Full Screen) Ad when game is over
  Future<void> showInterstitialAd({VoidCallback? onAdDismissed}) async {
    // 1. If ad is ready, present it immediately
    if (_interstitialAd != null) {
      _presentAd(onAdDismissed);
      return;
    }

    // 2. If ad is currently in flight, wait up to 2.5 seconds for it to finish loading
    if (_isInterstitialAdLoading) {
      debugPrint('InterstitialAd is still loading... waiting up to 2.5s');
      int waitedMs = 0;
      while (_isInterstitialAdLoading && waitedMs < 2500) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        waitedMs += 100;
      }

      if (_interstitialAd != null) {
        _presentAd(onAdDismissed);
        return;
      }
    }

    // 3. If ad is still null (e.g. failed or timed out), trigger callback & reload for next time
    debugPrint('No InterstitialAd available to show. Invoking callback and reloading.');
    onAdDismissed?.call();
    loadInterstitialAd();
  }

  void _presentAd(VoidCallback? onAdDismissed) {
    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('InterstitialAd dismissed.');
        ad.dispose();
        onAdDismissed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Failed to show InterstitialAd: $error');
        ad.dispose();
        onAdDismissed?.call();
        loadInterstitialAd();
      },
    );

    ad.show();
  }

  /// Clean up resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
