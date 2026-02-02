import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../providers/settings_provider.dart';
import 'legal/terms_screen.dart';
import 'legal/privacy_screen.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _SettingsSection(
                  title: 'General',
                  children: [_NotificationsTile(), _DefaultVolumeTile()],
                ),
                const Gap(24),
                _SettingsSection(
                  title: 'Timer',
                  children: [_AutoStartBreaksTile(), _FocusModeTile()],
                ),
                const Gap(24),
                _SettingsSection(
                  title: 'Legal',
                  children: [
                    _SettingsTile(
                      icon: Icons.description_rounded,
                      title: 'Terms of Service',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Gap(24),
                _SettingsSection(
                  title: 'About',
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Focus Timer & White Noise',
                      subtitle: 'Version 1.0.0',
                    ),
                  ],
                ),
                const Gap(24),
              ],
            ),
          ),
          const BannerAdWidget(horizontalMargin: 24),
          const Gap(16),
          _buildBottomNav(context),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
            isActive: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          _NavButton(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isActive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NotificationsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppTheme.primary,
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Timer reminders',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    settings.setNotificationsEnabled(value);
                  },
                  activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DefaultVolumeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.volume_up_rounded,
                    size: 24,
                    color: AppTheme.primary,
                  ),
                  const Gap(16),
                  Text(
                    'Default sound volume',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${settings.defaultSoundVolumePercent}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppTheme.primary,
                  inactiveTrackColor: AppTheme.onSurfaceSubtle.withValues(
                    alpha: 0.3,
                  ),
                  thumbColor: AppTheme.primary,
                ),
                child: Slider(
                  value: settings.defaultSoundVolume,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    settings.setDefaultSoundVolume(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AutoStartBreaksTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.coffee_rounded, size: 24, color: AppTheme.primary),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-start breaks',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Start break timer after session',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.autoStartBreaks,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    settings.setAutoStartBreaks(value);
                  },
                  activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FocusModeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.fullscreen_rounded,
                  size: 24,
                  color: AppTheme.primary,
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus mode',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Fullscreen minimal view when timer runs',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.focusModeEnabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    settings.setFocusModeEnabled(value);
                  },
                  activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.primary,
                ),
              ],
            ),
          ),
        );
      },
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.onSurfaceSubtle.withValues(alpha: 0.2),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTappable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isTappable ? AppTheme.primary : AppTheme.onSurfaceMuted,
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isTappable)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.onSurfaceMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
