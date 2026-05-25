import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  int _habitCompletionCount = 0;
  static const int _interstitialFrequency = 3;

  final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void incrementCompletionCount() {
    _habitCompletionCount++;
    if (_habitCompletionCount >= _interstitialFrequency) {
      _showInterstitial();
      _habitCompletionCount = 0;
    }
  }

  void _showInterstitial() {
    final ad = _interstitialAd;
    if (ad != null) {
      ad.show();
      _interstitialAd = null;
    } else {
      _loadInterstitial();
    }
  }

  AdWidget createBannerAdWidget() {
    if (_bannerAd == null) {
      _loadBanner();
    }
    return AdWidget(ad: _bannerAd!);
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
