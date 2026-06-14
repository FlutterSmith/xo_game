import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings_cubit.dart';
import '../blocs/statistics_cubit.dart';
import '../blocs/theme_cubit.dart';
import '../models/app_settings.dart';
import '../widgets/common/common.dart';

/// Settings screen with comprehensive configuration options.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _lastSyncedName = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitName(BuildContext context, String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      context.read<SettingsCubit>().updatePlayerName(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      showBack: true,
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          // Keep the text field in sync with persisted name without clobbering
          // the user's in-progress edits.
          if (settings.playerName != _lastSyncedName) {
            _lastSyncedName = settings.playerName;
            _nameController.text = settings.playerName;
            _nameController.selection = TextSelection.fromPosition(
              TextPosition(offset: _nameController.text.length),
            );
          }

          int i = 0;
          Widget step(Widget child) => FadeSlideIn(
                delay: AppMotion.stagger(i++),
                child: child,
              );

          return ListView(
            padding: AppSpacing.page,
            children: [
              step(_buildProfileSection(context, settings)),
              AppSpacing.vLg,
              step(_buildAudioSection(context, settings)),
              AppSpacing.vLg,
              step(_buildAppearanceSection(context, settings)),
              AppSpacing.vLg,
              step(_buildHelpSection(context)),
              AppSpacing.vLg,
              step(_buildDataSection(context)),
              AppSpacing.vLg,
              step(_buildAboutSection(context)),
              AppSpacing.vXl,
            ],
          );
        },
      ),
    );
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  Widget _buildProfileSection(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.person_rounded,
            title: 'Player Profile',
            subtitle: 'Your in-game identity',
            accent: AppColors.violet,
          ),
          AppSpacing.vMd,
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            style: theme.textTheme.titleMedium,
            cursorColor: AppColors.violet,
            decoration: InputDecoration(
              labelText: 'Player Name',
              filled: true,
              fillColor: p.surface2,
              prefixIcon: const Icon(
                Icons.badge_rounded,
                color: AppColors.violet,
              ),
              suffixIcon: IconButton(
                tooltip: 'Save name',
                icon: const Icon(Icons.check_circle_rounded,
                    color: AppColors.teal),
                onPressed: () => _submitName(context, _nameController.text),
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.rMd,
                borderSide: BorderSide(color: p.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.rMd,
                borderSide: BorderSide(color: p.border),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.rMd,
                borderSide: BorderSide(color: AppColors.violet, width: 1.6),
              ),
            ),
            onSubmitted: (value) => _submitName(context, value),
          ),
        ],
      ),
    );
  }

  // ── Audio & Haptics ─────────────────────────────────────────────────────────
  Widget _buildAudioSection(BuildContext context, AppSettings settings) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.graphic_eq_rounded,
            title: 'Audio & Haptics',
            subtitle: 'Feel and hear the game',
            accent: AppColors.pink,
          ),
          AppSpacing.vSm,
          _buildSwitchTile(
            context,
            icon: Icons.volume_up_rounded,
            accent: AppColors.pink,
            title: 'Sound Effects',
            subtitle: 'Play sounds during gameplay',
            value: settings.soundEnabled,
            onChanged: (_) => context.read<SettingsCubit>().toggleSound(),
          ),
          _buildDivider(context),
          _buildSwitchTile(
            context,
            icon: Icons.music_note_rounded,
            accent: AppColors.violet,
            title: 'Background Music',
            subtitle: 'Play music while gaming',
            value: settings.musicEnabled,
            onChanged: (_) => context.read<SettingsCubit>().toggleMusic(),
          ),
          _buildDivider(context),
          _buildSwitchTile(
            context,
            icon: Icons.vibration_rounded,
            accent: AppColors.teal,
            title: 'Vibration',
            subtitle: 'Haptic feedback for actions',
            value: settings.vibrationEnabled,
            onChanged: (_) => context.read<SettingsCubit>().toggleVibration(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    return InkWell(
      borderRadius: AppRadius.rMd,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: value ? 0.18 : 0.08),
                borderRadius: AppRadius.rSm,
              ),
              child: Icon(
                icon,
                color: value ? accent : p.textMuted,
                size: 22,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Divider(height: 1, color: p.border),
    );
  }

  // ── Appearance ──────────────────────────────────────────────────────────────
  Widget _buildAppearanceSection(BuildContext context, AppSettings settings) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.palette_rounded,
            title: 'Appearance',
            subtitle: 'Pick your vibe',
            accent: AppColors.cyan,
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  accent: AppColors.amber,
                  isSelected: settings.themeMode == 'light',
                  onTap: () {
                    context.read<SettingsCubit>().updateThemeMode('light');
                    context.read<ThemeCubit>().setLightTheme();
                  },
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: _buildThemeOption(
                  context,
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  accent: AppColors.violet,
                  isSelected: settings.themeMode == 'dark',
                  onTap: () {
                    context.read<SettingsCubit>().updateThemeMode('dark');
                    context.read<ThemeCubit>().setDarkTheme();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color accent,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.28),
                    accent.withValues(alpha: 0.10),
                  ],
                )
              : null,
          color: isSelected ? null : p.surface2,
          borderRadius: AppRadius.rMd,
          border: Border.all(
            color: isSelected ? accent : p.border,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? accent : p.textMuted,
            ),
            AppSpacing.vXs,
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? accent : p.text,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Help & Tutorial ──────────────────────────────────────────────────────────
  Widget _buildHelpSection(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    return GlassPanel(
      onTap: () => Navigator.pushNamed(context, '/tutorial'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.16),
              borderRadius: AppRadius.rSm,
            ),
            child: const Icon(Icons.school_rounded,
                color: AppColors.teal, size: 22),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('How to Play', style: theme.textTheme.titleLarge),
                Text(
                  'View tutorial and game instructions',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppSpacing.hSm,
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: p.textMuted),
        ],
      ),
    );
  }

  // ── Data Management ──────────────────────────────────────────────────────────
  Widget _buildDataSection(BuildContext context) {
    return GlassPanel(
      glowColor: AppColors.red,
      glowBlur: 18,
      borderColor: AppColors.red.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.warning_amber_rounded,
            title: 'Danger Zone',
            subtitle: 'These actions cannot be undone',
            accent: AppColors.red,
          ),
          AppSpacing.vMd,
          NeonButton(
            label: 'Reset Statistics',
            icon: Icons.delete_forever_rounded,
            variant: NeonButtonVariant.danger,
            onTap: () => _showResetConfirmationDialog(context),
          ),
          AppSpacing.vSm,
          NeonButton(
            label: 'Reset Tutorial',
            icon: Icons.restart_alt_rounded,
            variant: NeonButtonVariant.secondary,
            onTap: () {
              context.read<SettingsCubit>().resetTutorial();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tutorial will show again next time'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.delete_forever_rounded,
              color: AppColors.red, size: 36),
          title: const Text('Reset Statistics'),
          content: const Text(
            'Are you sure you want to reset all statistics and achievements? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<StatisticsCubit>().resetStatistics();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Statistics reset successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── About ────────────────────────────────────────────────────────────────────
  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: AppRadius.rSm,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 22),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('App Version', style: theme.textTheme.titleMedium),
                Text('1.0.0', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
