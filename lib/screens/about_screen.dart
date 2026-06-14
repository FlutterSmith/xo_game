import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';

/// About screen with app information — neon-arcade redesign.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _appVersion = '1.0.0';

  // Feature showcase as icon cards (not a checklist wall).
  static const List<_Feature> _features = [
    _Feature(Icons.grid_view_rounded, 'Board Sizes', '3×3 · 4×4 · 5×5', AppColors.violet),
    _Feature(Icons.smart_toy_rounded, 'AI Opponents', '4 difficulties', AppColors.pink),
    _Feature(Icons.people_alt_rounded, 'Local PvP', 'Pass & play', AppColors.teal),
    _Feature(Icons.undo_rounded, 'Undo / Redo', 'Take it back', AppColors.cyan),
    _Feature(Icons.bar_chart_rounded, 'Statistics', 'Full tracking', AppColors.amber),
    _Feature(Icons.emoji_events_rounded, 'Achievements', 'Earn badges', AppColors.rose),
    _Feature(Icons.movie_filter_rounded, 'Replays', 'Re-watch games', AppColors.violet),
    _Feature(Icons.dark_mode_rounded, 'Themes', 'Dark & light', AppColors.pink),
    _Feature(Icons.volume_up_rounded, 'Sound & Haptics', 'Feel every move', AppColors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);

    return AppScaffold(
      title: 'About',
      showBack: true,
      padding: AppSpacing.page,
      body: ListView(
        children: [
          FadeSlideIn(
            delay: AppMotion.stagger(0),
            child: _buildHero(context),
          ),
          AppSpacing.vXl,
          FadeSlideIn(
            delay: AppMotion.stagger(1),
            child: _buildDescription(context),
          ),
          AppSpacing.vLg,
          FadeSlideIn(
            delay: AppMotion.stagger(2),
            child: const SectionHeader(
              icon: Icons.auto_awesome_rounded,
              title: 'Features',
              subtitle: 'Everything packed into one game',
              accent: AppColors.pink,
            ),
          ),
          AppSpacing.vMd,
          FadeSlideIn(
            delay: AppMotion.stagger(3),
            child: _buildFeatureGrid(context),
          ),
          AppSpacing.vXl,
          FadeSlideIn(
            delay: AppMotion.stagger(4),
            child: _buildActionButtons(context),
          ),
          AppSpacing.vXl,
          FadeSlideIn(
            delay: AppMotion.stagger(5),
            child: _buildDeveloperSection(context),
          ),
          AppSpacing.vLg,
          FadeSlideIn(
            delay: AppMotion.stagger(6),
            child: _buildLegalSection(context, theme, p),
          ),
          AppSpacing.vLg,
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      glowColor: AppColors.violet,
      glowBlur: 40,
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.45),
                  blurRadius: 34,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  AnimatedMark(mark: 'X', markSize: 38, color: Colors.white, glow: false),
                  SizedBox(width: 2),
                  AnimatedMark(mark: 'O', markSize: 38, color: Colors.white, glow: false),
                ],
              ),
            ),
          ),
          AppSpacing.vLg,
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.heroGradient,
            ).createShader(bounds),
            child: Text(
              'XO Game',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          AppSpacing.vXs,
          Text(
            'Professional Tic Tac Toe',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppPalette.of(context).textMuted,
            ),
          ),
          AppSpacing.vMd,
          _versionPill(theme),
        ],
      ),
    );
  }

  Widget _versionPill(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.16),
        borderRadius: AppRadius.rPill,
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, size: 16, color: AppColors.teal),
          AppSpacing.hXs,
          Text(
            'Version $_appVersion',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── Description ─────────────────────────────────────────────────────────────
  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    return GlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.16),
              borderRadius: AppRadius.rSm,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: AppColors.violet, size: 22),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              'A professional, feature-complete Tic Tac Toe game with multiple '
              'board sizes, AI opponents with various difficulty levels, '
              'comprehensive statistics tracking, achievements, and game replays.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feature grid ────────────────────────────────────────────────────────────
  Widget _buildFeatureGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final cols = constraints.maxWidth > 520 ? 3 : 2;
        final tileWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final f in _features)
              SizedBox(
                width: tileWidth,
                child: _featureCard(context, f),
              ),
          ],
        );
      },
    );
  }

  Widget _featureCard(BuildContext context, _Feature f) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  f.color.withValues(alpha: 0.28),
                  f.color.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: AppRadius.rSm,
              border: Border.all(color: f.color.withValues(alpha: 0.35)),
            ),
            child: Icon(f.icon, color: f.color, size: 22),
          ),
          AppSpacing.vSm,
          Text(
            f.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.gapXxs,
          Text(
            f.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: p.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        NeonButton(
          label: 'Rate This App',
          icon: Icons.star_rounded,
          variant: NeonButtonVariant.primary,
          large: true,
          onTap: () => _rateApp(),
        ),
        AppSpacing.vSm,
        NeonButton(
          label: 'Share With Friends',
          icon: Icons.share_rounded,
          variant: NeonButtonVariant.secondary,
          onTap: () => _shareApp(),
        ),
      ],
    );
  }

  // ── Developer section ───────────────────────────────────────────────────────
  Widget _buildDeveloperSection(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.code_rounded,
            title: 'Developers',
            accent: AppColors.teal,
          ),
          AppSpacing.vMd,
          _creditRow(context, 'Ahmed Hamdy', AppColors.violet),
          AppSpacing.vSm,
          _creditRow(context, 'Ademero', AppColors.pink),
          AppSpacing.vMd,
          Divider(color: AppPalette.of(context).border, height: 1),
          AppSpacing.vMd,
          Row(
            children: [
              const Icon(Icons.flutter_dash_rounded,
                  color: AppColors.cyan, size: 20),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'Built with Flutter',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.of(context).textMuted,
                      ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          NeonButton(
            label: 'Learn more about Flutter',
            icon: Icons.open_in_new_rounded,
            variant: NeonButtonVariant.ghost,
            expand: false,
            onTap: () => _launchURL('https://flutter.dev'),
          ),
        ],
      ),
    );
  }

  Widget _creditRow(BuildContext context, String name, Color accent) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Icon(Icons.person_rounded, size: 20, color: accent),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ── Legal section ───────────────────────────────────────────────────────────
  Widget _buildLegalSection(
      BuildContext context, ThemeData theme, AppPalette p) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.gavel_rounded,
            title: 'Legal',
            accent: AppColors.amber,
          ),
          AppSpacing.vMd,
          Text(
            '© 2024 XO Game. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(color: p.textMuted),
          ),
          AppSpacing.gapXxs,
          Text(
            'This app is provided "as is" without warranty of any kind.',
            style: theme.textTheme.bodySmall?.copyWith(color: p.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Behavior (preserved verbatim) ───────────────────────────────────────────
  Future<void> _rateApp() async {
    // In a real app, this would open the app store
    // For now, it's a placeholder
  }

  Future<void> _shareApp() async {
    // Share functionality would be implemented here
    // For example: Share.share('Check out XO Game!');
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _Feature(this.icon, this.title, this.subtitle, this.color);
}
