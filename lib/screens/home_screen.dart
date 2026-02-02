import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/timer_provider.dart';
import '../providers/sound_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _background = Color(0xFF121212);
  static const Color _primary = Color(0xFFFFA500);
  static const Color _surfaceVariant = Color(0xFF2C2C2C);

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test banner ID
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
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: MediaQuery.of(context).size.height > 700 ? 32 : 16,
            ),
            child: Column(
              children: [
                const Gap(24),
                _buildHeader(),
                const Gap(40),
                _buildTimerSection(),
                const Gap(40),
                _buildSoundSection(),
                const Gap(32),
                _buildAdPlaceholder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Focus Timer',
      style: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildTimerSection() {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (timer.isCompleted) {
                  timer.reset();
                } else if (timer.isRunning) {
                  timer.pause();
                } else if (timer.isPaused) {
                  timer.resume();
                } else {
                  timer.start();
                }
              },
              child: CircularPercentIndicator(
                radius: 130,
                lineWidth: 12,
                percent: timer.progress,
                progressColor: _primary,
                backgroundColor: _surfaceVariant,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animateFromLastPercent: true,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timer.formattedTime,
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1.1,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _getTimerLabel(timer),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(32),
            _buildControlButtons(timer),
          ],
        );
      },
    );
  }

  String _getTimerLabel(TimerProvider timer) {
    if (timer.isCompleted) return 'Done! Tap to restart';
    if (timer.isRunning) return 'Tap to pause';
    if (timer.isPaused) return 'Tap to resume';
    return 'Tap to start';
  }

  Widget _buildControlButtons(TimerProvider timer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timer.status != TimerStatus.idle && !timer.isCompleted) ...[
          _ControlButton(
            icon: Icons.replay_rounded,
            label: 'Reset',
            onTap: () {
              HapticFeedback.lightImpact();
              timer.reset();
            },
          ),
          const Gap(24),
        ],
        _ControlButton(
          icon: timer.isRunning
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          label: timer.isRunning ? 'Pause' : 'Start',
          onTap: () {
            HapticFeedback.lightImpact();
            if (timer.isRunning) {
              timer.pause();
            } else if (timer.isPaused) {
              timer.resume();
            } else {
              timer.start();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSoundSection() {
    return Consumer<SoundProvider>(
      builder: (context, sound, _) {
        return Column(
          children: [
            Text(
              'White Noise',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SoundButton(
                  icon: Icons.water_drop_rounded,
                  label: 'Rain',
                  isActive: sound.activeSound == SoundType.rain,
                  onTap: () => _toggleSound(sound, SoundType.rain),
                ),
                const Gap(16),
                _SoundButton(
                  icon: Icons.forest_rounded,
                  label: 'Forest',
                  isActive: sound.activeSound == SoundType.forest,
                  onTap: () => _toggleSound(sound, SoundType.forest),
                ),
                const Gap(16),
                _SoundButton(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Fire',
                  isActive: sound.activeSound == SoundType.fire,
                  onTap: () => _toggleSound(sound, SoundType.fire),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleSound(SoundProvider sound, SoundType type) async {
    HapticFeedback.lightImpact();
    try {
      await sound.toggleSound(type);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Add rain.mp3, forest.mp3, fire.mp3 to assets/audio/',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _surfaceVariant,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildAdPlaceholder() {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
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
                color: _surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Center(
                child: Text(
                  'Banner Ad',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFA500).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFFFFA500), size: 24),
              const Gap(8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoundButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SoundButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80,
          height: 88,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFFA500).withValues(alpha: 0.2)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFFA500)
                  : Colors.white.withValues(alpha: 0.08),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFA500).withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isActive
                    ? const Color(0xFFFFA500)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const Gap(8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFFFFA500)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
