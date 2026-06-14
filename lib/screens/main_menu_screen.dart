import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';
import '../blocs/theme_cubit.dart';
import '../blocs/settings_cubit.dart';
import '../blocs/statistics_cubit.dart';
import '../models/app_settings.dart';
import '../models/game_stats.dart';

/// Main Menu Screen - neon-arcade hero home screen.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Prompt for a name only once settings have actually loaded — avoids the
    // race where the seed default 'Player' fired the prompt on every launch.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptForName());
  }

  bool _namePromptHandled = false;

  void _maybePromptForName() {
    if (_namePromptHandled || !mounted) return;
    final cubit = context.read<SettingsCubit>();
    if (!cubit.isLoaded) {
      // Settings still loading; check again shortly.
      Future.delayed(const Duration(milliseconds: 150), _maybePromptForName);
      return;
    }
    _namePromptHandled = true;
    final name = cubit.state.playerName.trim();
    if (name.isEmpty || name == 'Player') {
      _showNamePromptDialog();
    }
  }

  void _showNamePromptDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.person_add, color: AppColors.pink),
              SizedBox(width: AppSpacing.sm),
              Text('Welcome!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter your name to personalize your gaming experience:',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              AppSpacing.vMd,
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.rSm,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    context
                        .read<SettingsCubit>()
                        .updatePlayerName(value.trim());
                    Navigator.of(dialogContext).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  context.read<SettingsCubit>().updatePlayerName(name);
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeSlideIn(
                  delay: AppMotion.stagger(0),
                  child: _buildGreetingBar(context),
                ),
                AppSpacing.vXl,
                FadeSlideIn(
                  delay: AppMotion.stagger(1),
                  child: _buildHero(context),
                ),
                AppSpacing.vXl,
                FadeSlideIn(
                  delay: AppMotion.stagger(2),
                  child: NeonButton(
                    label: 'PLAY',
                    icon: Icons.play_arrow_rounded,
                    large: true,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/game-setup'),
                  ),
                ),
                AppSpacing.vXl,
                FadeSlideIn(
                  delay: AppMotion.stagger(3),
                  child: _buildStatsPanel(context),
                ),
                AppSpacing.vXl,
                FadeSlideIn(
                  delay: AppMotion.stagger(4),
                  child: const SectionHeader(
                    icon: Icons.apps_rounded,
                    title: 'Explore',
                    subtitle: 'Stats, achievements and more',
                    accent: AppColors.teal,
                  ),
                ),
                AppSpacing.vLg,
                FadeSlideIn(
                  delay: AppMotion.stagger(5),
                  child: _buildNavGrid(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Greeting + theme toggle ────────────────────────────────────────────
  Widget _buildGreetingBar(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppPalette.of(context).textMuted;

    return Row(
      children: [
        Expanded(
          child: BlocBuilder<SettingsCubit, AppSettings>(
            builder: (context, settings) {
              final name = settings.playerName.trim().isEmpty
                  ? 'Player'
                  : settings.playerName.trim();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome back,',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
        AppSpacing.hSm,
        BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, theme) {
            final isDark = theme.brightness == Brightness.dark;
            return GlassIconButton(
              icon: isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: isDark ? AppColors.amber : AppColors.violet,
              tooltip: 'Toggle theme',
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
            );
          },
        ),
      ],
    );
  }

  // ── Hero logo + title ──────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Hero(
          tag: 'appLogo',
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.rXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.45),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                AnimatedMark(mark: 'X', markSize: 64, color: Colors.white),
                SizedBox(width: AppSpacing.xs),
                AnimatedMark(mark: 'O', markSize: 64, color: Colors.white),
              ],
            ),
          ),
        ),
        AppSpacing.vLg,
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.primaryGradient,
          ).createShader(bounds),
          child: Text(
            'XO Game',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        AppSpacing.vXs,
        Text(
          'Neon Tic Tac Toe',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: AppPalette.of(context).textMuted),
        ),
      ],
    );
  }

  // ── Win-rate ring + stat cards ─────────────────────────────────────────
  Widget _buildStatsPanel(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<StatisticsCubit, GameStats>(
      builder: (context, stats) {
        final winRate = stats.winRate; // 0..100
        return GlassPanel(
          glowColor: AppColors.violet,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  ProgressRing(
                    progress: winRate / 100,
                    size: 104,
                    strokeWidth: 11,
                    gradient: AppColors.primaryGradient,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountUpText(
                          value: winRate,
                          decimals: winRate.truncateToDouble() == winRate
                              ? 0
                              : 1,
                          suffix: '%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.violet,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Win rate',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppPalette.of(context).textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _miniStat(
                          context,
                          Icons.sports_esports_rounded,
                          'Games',
                          stats.totalGames,
                          AppColors.cyan,
                        ),
                        AppSpacing.vSm,
                        _miniStat(
                          context,
                          Icons.local_fire_department_rounded,
                          'Win streak',
                          stats.currentWinStreak,
                          AppColors.amber,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.vLg,
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'Wins',
                      value: stats.wins,
                      accent: AppColors.teal,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/statistics'),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: StatCard(
                      icon: Icons.shield_moon_rounded,
                      label: 'Perfect',
                      value: stats.perfectGames,
                      accent: AppColors.violet,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/statistics'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(
    BuildContext context,
    IconData icon,
    String label,
    int value,
    Color accent,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: AppRadius.rSm,
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CountUpText(
                value: value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: accent, fontWeight: FontWeight.w700),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Secondary navigation grid ──────────────────────────────────────────
  Widget _buildNavGrid(BuildContext context) {
    final tiles = <_NavTile>[
      const _NavTile(
        'Statistics',
        Icons.bar_chart_rounded,
        AppColors.cyan,
        '/statistics',
      ),
      const _NavTile(
        'Achievements',
        Icons.emoji_events_rounded,
        AppColors.amber,
        '/achievements',
      ),
      const _NavTile(
        'Replays',
        Icons.history_rounded,
        AppColors.teal,
        '/replays',
      ),
      const _NavTile(
        'Settings',
        Icons.settings_rounded,
        AppColors.violet,
        '/settings',
      ),
      const _NavTile(
        'Tutorial',
        Icons.school_rounded,
        AppColors.pink,
        '/tutorial',
      ),
      const _NavTile(
        'About',
        Icons.info_rounded,
        AppColors.rose,
        '/about',
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 0.95,
      children: [
        for (var i = 0; i < tiles.length; i++)
          FadeSlideIn(
            delay: AppMotion.stagger(6 + i),
            child: _buildNavTile(context, tiles[i]),
          ),
      ],
    );
  }

  Widget _buildNavTile(BuildContext context, _NavTile tile) {
    final theme = Theme.of(context);
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => Navigator.of(context).pushNamed(tile.route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: tile.accent.withValues(alpha: 0.16),
              borderRadius: AppRadius.rMd,
            ),
            child: Icon(tile.icon, color: tile.accent, size: 26),
          ),
          AppSpacing.vXs,
          Text(
            tile.label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NavTile {
  final String label;
  final IconData icon;
  final Color accent;
  final String route;

  const _NavTile(this.label, this.icon, this.accent, this.route);
}
