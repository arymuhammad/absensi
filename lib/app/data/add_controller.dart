import 'package:get/get.dart';
import 'package:startapp_sdk/startapp.dart';

class AdController extends GetxController {
  final StartAppSdk startAppSdk = StartAppSdk();

  StartAppInterstitialAd? interstitialAd;
  @override
  void onInit() {
    super.onInit();

    startAppSdk.setTestAdsEnabled(
      false,
    ); // Ganti ke false kalau sudah siap release
    loadInterstitialAd();
  }

  Future<void> loadInterstitialAd() async {
    // startAppSdk.setTestAdsEnabled(
    //   false,
    // ); // Ganti ke false kalau sudah siap release
    try {
      await startAppSdk
          .loadInterstitialAd(
            prefs: const StartAppAdPreferences(adTag: 'splashscreen'),
            onAdDisplayed: () => print('Interstitial Ad Displayed'),
            onAdHidden: () {
              // print('Interstitial Ad Hidden');
              // Bisa reload iklan jika diperlukan
              interstitialAd?.dispose();
              interstitialAd = null;
              loadInterstitialAd();
            },
            onAdNotDisplayed: () {
              // print('Failed to load interstitial ad');
            },
          )
          .then((ad) {
            interstitialAd = ad;
          });
    } catch (e) {
      print('Failed to load interstitial ad: $e');
    }
  }

  void showInterstitialAd(Function onAdFinished) {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      onAdFinished();
    } else {
      // print('Interstitial not ready, langsung lanjut.');
      onAdFinished(); // Selalu lanjutkan bila iklan tidak siap
    }
  }

  @override
  void onClose() {
    interstitialAd?.dispose();
    super.onClose();
  }
}
