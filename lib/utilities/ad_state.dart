import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  static late Future<InitializationStatus> initStatusFuture;

  static String get bannerAdUnitId => 'NO!';

  static BannerAdListener get adListener => _adListener;

  static BannerAdListener _adListener = BannerAdListener(
    onAdLoaded: (ad) => print('Ad loaded: ${ad.adUnitId}.'),
    onAdClosed: (ad) => print('Ad closed: ${ad.adUnitId}.'),
    onAdFailedToLoad: (ad, error) =>
        print('Ad failed to load: ${ad.adUnitId}, $error'),
    onAdOpened: (ad) => print('Ad opened: ${ad.adUnitId}.'),
    onAdImpression: (ad) => print('Ad impression: ${ad.adUnitId}.'),
    onAdWillDismissScreen: (ad) => print('Ad dismiss: ${ad.adUnitId}.'),
  );
}
