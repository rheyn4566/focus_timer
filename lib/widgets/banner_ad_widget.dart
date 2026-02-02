import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/app_theme.dart';

/// Shared AdMob banner for Home, Stats, Settings. Shows real ad on mobile; placeholder on web.
class BannerAdWidget extends StatefulWidget {
  final double horizontalMargin;

  const BannerAdWidget({super.key, this.horizontalMargin = 20});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  static const String _adUnitId = 'ca-app-pub-7313832252521502/7932481126';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: widget.horizontalMargin),
      child: _isBannerAdLoaded && _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : Container(
              width: 320,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  'Banner Ad',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.onSurfaceSubtle,
                  ),
                ),
              ),
            ),
    );
  }
}
