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

  /// Test Ad Unit IDs provided by Google for Android and iOS
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {//ca-app-pub-42651592906018274646500323
      /// Test Ad Unit IDs provided by Google for Android and iOS
      // return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-4265159290601827/1193871288';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      /// Test Ad Unit IDs provided by Google for Android and iOS
      // return 'ca-app-pub-3940256099942544/1033173712';
      return 'ca-app-pub-4265159290601827/5511594080';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  /// Initialize Mobile Ads SDK
  Future<InitializationStatus> initialize() async {
    return await _mobileAds.initialize();
  }

  /// Load Interstitial (Full Screen) Ad
  void loadInterstitialAd() {
    final adUnitId = interstitialAdUnitId;
    if (adUnitId.isEmpty || _isInterstitialAdLoading || _interstitialAd != null) return;

    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Show Interstitial (Full Screen) Ad when game is over
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      onAdDismissed?.call();
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        debugPrint('Failed to show interstitial ad: $error');
        onAdDismissed?.call();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
  }

  /// Clean up resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
