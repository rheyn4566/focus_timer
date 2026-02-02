import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../providers/stats_provider.dart';
import '../providers/achievement_provider.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<StatsProvider>(
              builder: (context, stats, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(stats),
                      const Gap(32),
                      _buildTodaySection(stats),
                      const Gap(32),
                      _buildAchievementsSection(context),
                      const Gap(32),
                      _buildRecentSessions(stats),
                      const Gap(24),
                    ],
                  ),
                );
              },
            ),
          ),
          const BannerAdWidget(horizontalMargin: 20),
          const Gap(16),
          _buildBottomNav(context),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(StatsProvider stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurfaceMuted,
          ),
        ),
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline_rounded,
                value: '${stats.totalSessions}',
                label: 'Total Sessions',
                color: AppTheme.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _StatCard(
                icon: Icons.access_time_rounded,
                value: stats.totalTimeFormatted,
                label: 'Total Time',
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.currentStreak}',
                label: 'Day Streak',
                color: AppTheme.primary,
              ),
            ),
            const Gap(14),
            Expanded(
              child: _StatCard(
                icon: Icons.today_rounded,
                value: '${stats.todaySessions}',
                label: 'Today',
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySection(StatsProvider stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surface.withValues(alpha: 0.9),
            AppTheme.surfaceVariant.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
              const Gap(8),
              Text(
                'Today\'s Progress',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${stats.todaySessions}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    'Sessions',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.3),
              ),
              Column(
                children: [
                  Text(
                    stats.todayTimeFormatted,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                  Text(
                    'Focus Time',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (context, achievements, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Achievements',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${achievements.unlockedCount}/${achievements.totalCount}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: LinearProgressIndicator(
                value: achievements.progressPercent / 100,
                minHeight: 6,
                backgroundColor: AppTheme.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary,
                ),
              ),
            ),
            const Gap(16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AchievementId.values.map((id) {
                final achievement = Achievement.all[id]!;
                final unlocked = achievements.isUnlocked(id);
                return _AchievementBadge(
                  achievement: achievement,
                  unlocked: unlocked,
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSessions(StatsProvider stats) {
    final recentSessions = stats.sessionHistory.take(10).toList();

    if (recentSessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 64, color: Colors.white24),
              const Gap(16),
              Text(
                'No sessions yet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
              const Gap(8),
              Text(
                'Complete a focus session to see it here',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.onSurfaceSubtle,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurfaceMuted,
          ),
        ),
        const Gap(16),
        ...recentSessions.map((session) => _SessionTile(session: session)),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.95),
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
          _NavButton(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          _NavButton(
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
            isActive: true,
            onTap: () {},
          ),
          _NavButton(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const Gap(14),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Gap(4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementBadge({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: achievement.description,
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked
              ? AppTheme.primary.withValues(alpha: 0.15)
              : AppTheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: unlocked
                ? AppTheme.primary.withValues(alpha: 0.4)
                : AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              achievement.icon,
              size: 28,
              color: unlocked ? AppTheme.primary : Colors.white38,
            ),
            const Gap(6),
            Text(
              achievement.name,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: unlocked ? Colors.white : AppTheme.onSurfaceMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionRecord session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');
    final now = DateTime.now();
    final isToday =
        session.timestamp.day == now.day &&
        session.timestamp.month == now.month &&
        session.timestamp.year == now.year;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: AppTheme.primary,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.task.isEmpty ? 'Focus Session' : session.task,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Text(
                  '${session.durationMinutes} min · ${isToday ? 'Today' : dateFormat.format(session.timestamp)} · ${timeFormat.format(session.timestamp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
