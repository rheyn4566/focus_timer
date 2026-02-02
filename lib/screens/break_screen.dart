import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/timer_provider.dart';
import '../providers/stats_provider.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({super.key});

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timer = context.read<TimerProvider>();
      final stats = context.read<StatsProvider>();
      final isLongBreak = (stats.todaySessions % 4) == 0;
      timer.startBreak(isLong: isLongBreak);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final timer = context.read<TimerProvider>();
        if (timer.isRunning) {
          final shouldSkip = await _showSkipDialog(context);
          if (shouldSkip == true && context.mounted) {
            timer.skipBreak();
            Navigator.pop(context);
          }
        } else {
          timer.skipBreak();
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Break Time'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final timer = context.read<TimerProvider>();
              final nav = Navigator.of(context);
              if (timer.isRunning) {
                final shouldSkip = await _showSkipDialog(context);
                if (shouldSkip == true) {
                  timer.skipBreak();
                  nav.pop();
                }
              } else {
                timer.skipBreak();
                nav.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Consumer<TimerProvider>(
            builder: (context, timer, _) {
              if (timer.isCompleted && timer.isBreakMode) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  timer.skipBreak();
                  if (mounted) Navigator.pop(context);
                });
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Icon(
                        Icons.coffee_rounded,
                        size: 88,
                        color: AppTheme.accent.withValues(alpha: 0.9),
                      ),
                      const Gap(32),
                      Text(
                        timer.modeLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(16),
                      Text(
                        'Take a breath. You\'ve earned it.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                      const Gap(48),
                      CircularPercentIndicator(
                        radius: 110,
                        lineWidth: 12,
                        percent: timer.progress,
                        progressColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceVariant,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animateFromLastPercent: true,
                        center: Text(
                          timer.formattedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Gap(48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              timer.skipBreak();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.skip_next_rounded),
                            label: Text(
                              'Skip Break',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(
                                color: AppTheme.primary.withValues(alpha: 0.6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool?> _showSkipDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        title: Text(
          'Skip break?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Taking breaks helps you stay focused and productive.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Continue Break',
              style: GoogleFonts.poppins(color: AppTheme.onSurfaceMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
