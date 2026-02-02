import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../providers/timer_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'break_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TimerStatus? _previousTimerStatus;
  bool _focusModeDismissed = false;

  final TextEditingController _taskController = TextEditingController();
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timer, settings, _) {
        final showFocusMode =
            settings.focusModeEnabled &&
            (timer.isRunning || timer.isPaused) &&
            timer.isFocusMode &&
            !_focusModeDismissed;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: showFocusMode
                ? _buildFocusModeView(context)
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: MediaQuery.of(context).size.height > 700
                                  ? 10
                                  : 8,
                            ),
                            child: Column(
                              children: [
                                const Gap(4),
                                _buildHeader(),
                                const Gap(6),
                                _buildTodayStats(),
                                const Gap(10),
                                _buildTaskInput(),
                                const Gap(16),
                                _buildTimerSection(),
                                const Gap(14),
                                _buildDurationChips(),
                                const Gap(16),
                                _buildControlButtons(),
                                const Gap(20),
                                _buildSoundMixer(),
                                const Gap(24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const BannerAdWidget(horizontalMargin: 24),
                      const Gap(16),
                      _buildBottomButtons(),
                      const Gap(16),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFocusModeView(BuildContext context) {
    return Consumer3<TimerProvider, SoundProvider, SettingsProvider>(
      builder: (context, timer, sound, settings, _) {
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (timer.currentTask.trim().isNotEmpty) ...[
                            Text(
                              timer.currentTask,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurfaceMuted,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(24),
                          ],
                          _buildTimerSection(),
                          const Gap(40),
                          _buildFocusModeControls(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (timer.isRunning) timer.pause();
                        setState(() => _focusModeDismissed = true);
                      },
                      icon: const Icon(Icons.fullscreen_exit_rounded, size: 20),
                      label: Text(
                        'Exit Focus',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.onSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const BannerAdWidget(horizontalMargin: 24),
            const Gap(16),
          ],
        );
      },
    );
  }

  Widget _buildFocusModeControls() {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              icon: Icons.replay_rounded,
              label: 'Reset',
              onTap: () {
                HapticFeedback.lightImpact();
                timer.reset();
              },
            ),
            const Gap(24),
            _ControlButton(
              icon: timer.isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              label: timer.isRunning ? 'Pause' : 'Resume',
              onTap: () {
                HapticFeedback.lightImpact();
                if (timer.isRunning) {
                  timer.pause();
                } else {
                  timer.resume();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.6,
          ),
        ),
        Text(
          'Timer',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w300,
            color: AppTheme.onSurfaceMuted,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStats() {
    return Consumer<StatsProvider>(
      builder: (context, stats, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(
                  alpha: stats.todaySessions > 0 ? 0.12 : 0.06,
                ),
                AppTheme.accent.withValues(
                  alpha: stats.todaySessions > 0 ? 0.06 : 0.03,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.primary.withValues(
                alpha: stats.todaySessions > 0 ? 0.25 : 0.12,
              ),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stats.todaySessions > 0
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  size: 16,
                  color: stats.todaySessions > 0
                      ? AppTheme.accent
                      : AppTheme.onSurfaceSubtle,
                ),
              ),
              const Gap(10),
              Text(
                stats.todaySessions > 0
                    ? '${stats.todaySessions} session${stats.todaySessions != 1 ? 's' : ''} today'
                    : 'No sessions yet today',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: stats.todaySessions > 0
                      ? Colors.white
                      : AppTheme.onSurfaceMuted,
                ),
              ),
              if (stats.todaySessions > 0) ...[
                const Gap(6),
                Text(
                  '· ${stats.todayTimeFormatted}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskInput() {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _taskController,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'What are you focusing on?',
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                color: AppTheme.onSurfaceSubtle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
            onChanged: (value) => timer.setCurrentTask(value),
          ),
        );
      },
    );
  }

  Widget _buildTimerSection() {
    return Consumer3<TimerProvider, SettingsProvider, StatsProvider>(
      builder: (context, timer, settings, stats, _) {
        if (timer.isRunning && _previousTimerStatus == TimerStatus.idle) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _focusModeDismissed = false);
          });
        }
        if ((timer.isCompleted || timer.status == TimerStatus.idle) &&
            _focusModeDismissed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _focusModeDismissed = false);
          });
        }
        // Control sounds based on timer state (must happen BEFORE status update)
        final sound = context.read<SoundProvider>();
        if (timer.isRunning && _previousTimerStatus == TimerStatus.paused) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sound.resumeAll();
          });
        } else if (timer.isPaused &&
            _previousTimerStatus == TimerStatus.running) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sound.pauseAll();
          });
        } else if (timer.isCompleted &&
            _previousTimerStatus == TimerStatus.running) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sound.stopAll();
          });
        } else if (timer.status == TimerStatus.idle &&
            _previousTimerStatus != TimerStatus.idle &&
            _previousTimerStatus != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            sound.stopAll();
          });
        }

        // Handle timer completion
        if (timer.isCompleted &&
            _previousTimerStatus != TimerStatus.completed) {
          _previousTimerStatus = TimerStatus.completed;

          if (timer.isFocusMode) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await stats.recordSession(
                durationMinutes: timer.durationMinutes,
                task: timer.currentTask,
              );
              if (!context.mounted) return;
              final achievements = context.read<AchievementProvider>();
              achievements.checkAndUnlock(
                totalSessions: stats.totalSessions,
                totalMinutes: stats.totalMinutes,
                currentStreak: stats.currentStreak,
                sessionsWithTask: stats.sessionsWithTask,
                sessionDurationMinutes: timer.durationMinutes,
                sessionTime: DateTime.now(),
              );
              if (achievements.lastUnlocked != null && context.mounted) {
                _showAchievementSnackbar(context, achievements);
              }
              if (!context.mounted) return;
              if (settings.notificationsEnabled) {
                NotificationService.showTimerCompleteNotification();
              }
              if (settings.autoStartBreaks) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BreakScreen()),
                );
              }
            });
          }
        } else if (!timer.isCompleted) {
          _previousTimerStatus = timer.status;
        }

        // Control breathing animation
        if (timer.isRunning && !_breathController.isAnimating) {
          _breathController.repeat(reverse: true);
        } else if (!timer.isRunning && _breathController.isAnimating) {
          _breathController.stop();
          _breathController.reset();
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (timer.isCompleted) {
              timer.reset();
            } else if (timer.isRunning) {
              timer.pause();
            } else if (timer.isPaused) {
              timer.resume();
            } else {
              _startTimerWithSound(context);
            }
          },
          child: AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: timer.isRunning ? _breathAnimation.value : 1.0,
                child: child,
              );
            },
            child: CircularPercentIndicator(
              radius: 98,
              lineWidth: 10,
              percent: timer.progress,
              progressColor: AppTheme.primary,
              backgroundColor: AppTheme.surfaceVariant,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animateFromLastPercent: true,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timer.formattedTime,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 2,
                      height: 1.1,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    _getTimerLabel(timer),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Widget _buildDurationChips() {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: TimerProvider.durationOptions.map((minutes) {
            final isSelected = timer.durationMinutes == minutes;
            return FilterChip(
              selected: isSelected,
              label: Text(
                '${minutes}m',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primary,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.6)
                    : AppTheme.onSurfaceSubtle.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              onSelected: (_) {
                HapticFeedback.lightImpact();
                timer.setDuration(minutes);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _startTimerWithSound(BuildContext context) {
    final timer = context.read<TimerProvider>();
    final sound = context.read<SoundProvider>();

    timer.start();

    // Always set rain to 50% when timer starts so it actually plays
    // (after reset/complete, stopAll() stops the player but volume stays 0.5,
    // so we must call setVolume to start the player again)
    sound.setVolume(SoundType.rain, 0.5);
  }

  Widget _buildControlButtons() {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
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
              const Gap(18),
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
                  _startTimerWithSound(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSoundMixer() {
    return Consumer<SoundProvider>(
      builder: (context, sound, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ambient Sounds',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
            const Gap(12),
            _SoundMixerRow(
              icon: Icons.water_drop_rounded,
              label: 'Rain',
              volume: sound.getVolume(SoundType.rain),
              onVolumeChanged: (v) => _setSoundVolume(sound, SoundType.rain, v),
            ),
            const Gap(8),
            _SoundMixerRow(
              icon: Icons.forest_rounded,
              label: 'Forest',
              volume: sound.getVolume(SoundType.forest),
              onVolumeChanged: (v) =>
                  _setSoundVolume(sound, SoundType.forest, v),
            ),
            const Gap(8),
            _SoundMixerRow(
              icon: Icons.local_fire_department_rounded,
              label: 'Fire',
              volume: sound.getVolume(SoundType.fire),
              onVolumeChanged: (v) => _setSoundVolume(sound, SoundType.fire, v),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomNavButton(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: true,
            onTap: () {},
          ),
          _BottomNavButton(
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          _BottomNavButton(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setSoundVolume(
    SoundProvider sound,
    SoundType type,
    double v,
  ) async {
    try {
      await sound.setVolume(type, v);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Add rain.mp3, forest.mp3, fire.mp3 to assets/audio/',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAchievementSnackbar(
    BuildContext context,
    AchievementProvider achievements,
  ) {
    final id = achievements.lastUnlocked;
    if (id == null) return;
    final achievement = Achievement.all[id];
    if (achievement == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(achievement.icon, size: 28, color: AppTheme.primary),
            const Gap(12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievement Unlocked!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    achievement.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    achievement.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
    achievements.clearLastUnlocked();
  }
}

class _BottomNavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : AppTheme.onSurfaceMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const Gap(4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const Gap(6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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

class _SoundMixerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const _SoundMixerRow({
    required this.icon,
    required this.label,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: volume > 0
                  ? AppTheme.primary.withValues(alpha: 0.2)
                  : AppTheme.onSurfaceSubtle.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: volume > 0 ? AppTheme.accent : AppTheme.onSurfaceMuted,
            ),
          ),
          const Gap(12),
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: volume > 0 ? Colors.white : AppTheme.onSurfaceMuted,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.primary,
                inactiveTrackColor: AppTheme.onSurfaceSubtle.withValues(
                  alpha: 0.3,
                ),
                thumbColor: AppTheme.accent,
                overlayColor: AppTheme.primary.withValues(alpha: 0.2),
              ),
              child: Slider(value: volume, onChanged: onVolumeChanged),
            ),
          ),
          const Gap(6),
          SizedBox(
            width: 32,
            child: Text(
              '${(volume * 100).round()}%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
