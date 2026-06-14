import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';

import '../models/achievement.dart';
import '../services/achievement_service.dart';

/// Achievements screen displaying unlocked and locked achievements as a
/// rewarding neon-arcade badge dashboard.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final achievements = await _achievementService.getAchievements();
    setState(() {
      _achievements = achievements;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Achievements',
      showBack: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final unlocked = _achievements.where((a) => a.unlocked).toList();
    final locked = _achievements.where((a) => !a.unlocked).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: FadeSlideIn(child: _buildHeader(context)),
          ),
        ),
        if (unlocked.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: FadeSlideIn(
                delay: AppMotion.stagger(1),
                child: SectionHeader(
                  icon: Icons.emoji_events_rounded,
                  title: 'Unlocked',
                  subtitle: '${unlocked.length} earned',
                  accent: AppColors.amber,
                ),
              ),
            ),
          ),
        _buildGrid(context, unlocked, baseIndex: 2),
        if (locked.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: FadeSlideIn(
                delay: AppMotion.stagger(unlocked.length + 2),
                child: SectionHeader(
                  icon: Icons.lock_rounded,
                  title: 'In Progress',
                  subtitle: '${locked.length} to unlock',
                  accent: AppColors.violet,
                ),
              ),
            ),
          ),
        _buildGrid(context, locked, baseIndex: unlocked.length + 3),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<Achievement> items, {
    required int baseIndex,
  }) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 720 ? 3 : (width >= 480 ? 2 : 1);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          mainAxisExtent: 184,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeSlideIn(
              delay: AppMotion.stagger(baseIndex + index),
              child: _buildBadgeCard(context, items[index]),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final unlocked = _achievements.where((a) => a.unlocked).length;
    final total = _achievements.length;
    final ratio = total == 0 ? 0.0 : unlocked / total;
    final percent = (ratio * 100);

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.violet,
      glowBlur: 32,
      child: Row(
        children: [
          ProgressRing(
            progress: ratio,
            size: 112,
            strokeWidth: 11,
            gradient: AppColors.heroGradient,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountUpText(
                  value: percent,
                  suffix: '%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: palette.text,
                  ),
                ),
                Text(
                  'complete',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Trophies',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    CountUpText(
                      value: unlocked,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                      ),
                    ),
                    Text(
                      ' / $total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: palette.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'achievements unlocked',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context, Achievement achievement) {
    return achievement.unlocked
        ? _buildUnlockedCard(context, achievement)
        : _buildLockedCard(context, achievement);
  }

  Widget _buildUnlockedCard(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);

    return GlassPanel(
      glowColor: AppColors.amber,
      glowBlur: 22,
      borderColor: AppColors.amber.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadgeMedallion(achievement.icon, unlocked: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.win.withValues(alpha: 0.18),
                  borderRadius: AppRadius.rPill,
                  border: Border.all(
                    color: AppColors.win.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.win,
                      size: 14,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      'EARNED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.win,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            achievement.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Expanded(
            child: Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (achievement.unlockedDate != null)
            Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 13,
                  color: AppColors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: AppSpacing.xxs),
                Flexible(
                  child: Text(
                    _formatDate(achievement.unlockedDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLockedCard(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final hasTarget = achievement.target > 0;
    final ratio = hasTarget
        ? (achievement.progress / achievement.target).clamp(0.0, 1.0)
        : 0.0;

    return GlassPanel(
      borderColor: palette.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadgeMedallion(achievement.icon, unlocked: false),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: palette.surface2.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            achievement.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.text.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Expanded(
            child: Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.textMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasTarget) ...[
            ClipRRect(
              borderRadius: AppRadius.rPill,
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: palette.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.violet,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${achievement.progress}/${achievement.target}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'Locked',
              style: theme.textTheme.labelSmall?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeMedallion(String icon, {required bool unlocked}) {
    final palette = AppPalette.of(context);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.amber, AppColors.pink],
              )
            : null,
        color: unlocked ? null : palette.surface2,
        border: Border.all(
          color: unlocked
              ? AppColors.amber.withValues(alpha: 0.6)
              : palette.border,
          width: 1.5,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Opacity(
          opacity: unlocked ? 1.0 : 0.45,
          child: Text(
            icon,
            style: const TextStyle(fontSize: 26),
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }
}
