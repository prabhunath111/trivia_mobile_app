import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_mobile_app/core/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdService Unit Tests', () {
    test('bannerAdUnitId returns a non-empty test ID on supported mobile platforms', () {
      final bannerId = AdService.bannerAdUnitId;
      expect(bannerId, isNotNull);
    });

    test('interstitialAdUnitId returns a non-empty test ID on supported mobile platforms', () {
      final interstitialId = AdService.interstitialAdUnitId;
      expect(interstitialId, isNotNull);
    });

    test('showInterstitialAd invokes callback immediately when no ad is loaded', () {
      final adService = AdService();
      var callbackCalled = false;

      adService.showInterstitialAd(
        onAdDismissed: () {
          callbackCalled = true;
        },
      );

      expect(callbackCalled, isTrue);
      adService.dispose();
    });
  });
}
