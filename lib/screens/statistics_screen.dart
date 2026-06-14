import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';
import '../blocs/statistics_cubit.dart';
import '../models/game_stats.dart';

/// Statistics screen — a rewarding neon-arcade dashboard of game stats with
/// animated rings, count-up hero numbers, stat cards and themed charts.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Statistics',
      showBack: true,
      actions: [
        GlassIconButton(
          icon: Icons.ios_share_rounded,
          tooltip: 'Share Statistics',
          onTap: () => _shareStatistics(context),
        ),
        const SizedBox(width: AppSpacing.xs),
        _OptionsMenu(
          onExport: () => _exportStatistics(context),
          onImport: () => _importStatistics(context),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: BlocBuilder<StatisticsCubit, GameStats>(
        builder: (context, stats) {
          if (stats.totalGames == 0) {
            return _EmptyState(
              onPlay: () => Navigator.of(context).pushReplacementNamed('/menu'),
            );
          }
          return _Dashboard(stats: stats);
        },
      ),
    );
  }

  // ── Preserved behavior ──────────────────────────────────────────────────

  Future<void> _shareStatistics(BuildContext context) async {
    final stats = context.read<StatisticsCubit>().state;
    final text = '''
My Tic Tac Toe Statistics:
━━━━━━━━━━━━━━━━━━━━
📊 Total Games: ${stats.totalGames}
🏆 Wins: ${stats.wins}
❌ Losses: ${stats.losses}
➖ Draws: ${stats.draws}
📈 Win Rate: ${stats.winRate.toStringAsFixed(1)}%

👥 PvP Stats: ${stats.pvpWins}/${stats.pvpGames} wins
🤖 PvC Stats: ${stats.pvcWins}/${stats.pvcGames} wins

Download the app and challenge me!
''';

    await Share.share(text);
  }

  Future<void> _exportStatistics(BuildContext context) async {
    try {
      final stats = context.read<StatisticsCubit>().exportStats();
      final jsonString = jsonEncode(stats);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/xo_game_stats.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(file.path)],
          text: 'My Tic Tac Toe Statistics');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistics exported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importStatistics(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        if (context.mounted) {
          final messenger = ScaffoldMessenger.of(context);
          await context.read<StatisticsCubit>().importStats(data);
          messenger.showSnackBar(
            const SnackBar(content: Text('Statistics imported successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Options (export / import) menu — styled to match the glass app bar.
// ════════════════════════════════════════════════════════════════════════════
class _OptionsMenu extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;

  const _OptionsMenu({required this.onExport, required this.onImport});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return PopupMenuButton<String>(
      tooltip: 'More',
      color: p.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              const Icon(Icons.file_upload_outlined, color: AppColors.violet),
              const SizedBox(width: AppSpacing.sm),
              Text('Export', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'import',
          child: Row(
            children: [
              const Icon(Icons.file_download_outlined, color: AppColors.teal),
              const SizedBox(width: AppSpacing.sm),
              Text('Import', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'export') {
          onExport();
        } else if (value == 'import') {
          onImport();
        }
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        child: GlassIconButton(
          icon: Icons.more_vert_rounded,
          onTap: null,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Empty state.
// ════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final VoidCallback onPlay;

  const _EmptyState({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.heroGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.45),
                      blurRadius: 40,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              AppSpacing.vLg,
              Text(
                'No Games Played Yet',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.vSm,
              Text(
                'Play your first match to start tracking wins,\n'
                'streaks and your rise up the ranks.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.vXl,
              SizedBox(
                width: 260,
                child: NeonButton(
                  label: 'Play Now',
                  icon: Icons.sports_esports_rounded,
                  large: true,
                  onTap: onPlay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Dashboard.
// ════════════════════════════════════════════════════════════════════════════
class _Dashboard extends StatelessWidget {
  final GameStats stats;

  const _Dashboard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _HeroPanel(stats: stats),
      _StatGrid(stats: stats),
      _DistributionPanel(stats: stats),
      _DifficultyPanel(stats: stats),
      _BoardSizePanel(stats: stats),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: sections.length,
      separatorBuilder: (_, __) => AppSpacing.vLg,
      itemBuilder: (context, i) => FadeSlideIn(
        delay: AppMotion.stagger(i),
        child: sections[i],
      ),
    );
  }
}

// ── Hero: win-rate ring + count-up record ───────────────────────────────────
class _HeroPanel extends StatelessWidget {
  final GameStats stats;

  const _HeroPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate = stats.winRate;
    final ringGradient =
        rate >= 50 ? AppColors.winGradient : AppColors.primaryGradient;

    return GlassPanel(
      glowColor: AppColors.violet,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.military_tech_rounded,
            title: 'Overall',
            subtitle: 'Your lifetime record',
          ),
          AppSpacing.vLg,
          Row(
            children: [
              ProgressRing(
                progress: rate / 100,
                size: 132,
                strokeWidth: 14,
                gradient: ringGradient,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountUpText(
                      value: rate,
                      decimals: 1,
                      suffix: '%',
                      style: theme.textTheme.headlineMedium,
                    ),
                    Text('Win Rate', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    _RecordRow(
                      icon: Icons.gamepad_rounded,
                      label: 'Games',
                      value: stats.totalGames,
                      accent: AppColors.violet,
                    ),
                    AppSpacing.vSm,
                    _RecordRow(
                      icon: Icons.emoji_events_rounded,
                      label: 'Wins',
                      value: stats.wins,
                      accent: AppColors.win,
                    ),
                    AppSpacing.vSm,
                    _RecordRow(
                      icon: Icons.close_rounded,
                      label: 'Losses',
                      value: stats.losses,
                      accent: AppColors.lose,
                    ),
                    AppSpacing.vSm,
                    _RecordRow(
                      icon: Icons.remove_rounded,
                      label: 'Draws',
                      value: stats.draws,
                      accent: AppColors.draw,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color accent;

  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: AppRadius.rSm,
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        CountUpText(
          value: value,
          style: theme.textTheme.titleLarge?.copyWith(color: accent),
        ),
      ],
    );
  }
}

// ── Stat-card grid: streaks + perfect games ─────────────────────────────────
class _StatGrid extends StatelessWidget {
  final GameStats stats;

  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.md;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        final cards = <Widget>[
          StatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Current Streak',
            value: stats.currentWinStreak,
            accent: AppColors.amber,
          ),
          StatCard(
            icon: Icons.whatshot_rounded,
            label: 'Longest Streak',
            value: stats.longestWinStreak,
            accent: AppColors.pink,
          ),
          StatCard(
            icon: Icons.auto_awesome_rounded,
            label: 'Perfect Games',
            value: stats.perfectGames,
            accent: AppColors.teal,
          ),
          StatCard(
            icon: Icons.shield_moon_rounded,
            label: 'PvC Win Rate',
            value: stats.pvcWinRate,
            decimals: 1,
            suffix: '%',
            accent: AppColors.violet,
          ),
        ];
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

// ── Pie: win / loss / draw distribution ─────────────────────────────────────
class _DistributionPanel extends StatelessWidget {
  final GameStats stats;

  const _DistributionPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final slices = <_Slice>[
      _Slice('Wins', stats.wins.toDouble(), AppColors.win),
      _Slice('Losses', stats.losses.toDouble(), AppColors.lose),
      _Slice('Draws', stats.draws.toDouble(), AppColors.draw),
    ].where((s) => s.value > 0).toList();

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.donut_large_rounded,
            title: 'Results',
            subtitle: 'Win / loss / draw split',
            accent: AppColors.teal,
          ),
          AppSpacing.vLg,
          SizedBox(
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppMotion.celebrate,
              curve: AppMotion.decelerate,
              builder: (context, t, _) {
                return PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 46,
                    startDegreeOffset: -90,
                    sections: [
                      for (final s in slices)
                        PieChartSectionData(
                          value: s.value * t,
                          title: t > 0.6 ? s.value.toInt().toString() : '',
                          color: s.color,
                          radius: 64,
                          titleStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          AppSpacing.vMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _Legend(label: 'Wins', color: AppColors.win),
              _Legend(label: 'Losses', color: AppColors.lose),
              _Legend(label: 'Draws', color: AppColors.draw),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slice {
  final String label;
  final double value;
  final Color color;

  const _Slice(this.label, this.value, this.color);
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;

  const _Legend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ── AI difficulty performance bars ──────────────────────────────────────────
class _DifficultyPanel extends StatelessWidget {
  final GameStats stats;

  const _DifficultyPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.smart_toy_rounded,
            title: 'AI Difficulty',
            subtitle: 'Win rate vs the machine',
            accent: AppColors.pink,
          ),
          AppSpacing.vLg,
          _DifficultyBar(
            label: 'Easy',
            wins: stats.easyWins,
            losses: stats.easyLosses,
            color: AppColors.easy,
          ),
          AppSpacing.vMd,
          _DifficultyBar(
            label: 'Medium',
            wins: stats.mediumWins,
            losses: stats.mediumLosses,
            color: AppColors.medium,
          ),
          AppSpacing.vMd,
          _DifficultyBar(
            label: 'Hard',
            wins: stats.hardWins,
            losses: stats.hardLosses,
            color: AppColors.hard,
          ),
        ],
      ),
    );
  }
}

class _DifficultyBar extends StatelessWidget {
  final String label;
  final int wins;
  final int losses;
  final Color color;

  const _DifficultyBar({
    required this.label,
    required this.wins,
    required this.losses,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final total = wins + losses;
    final winRate = total > 0 ? wins / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
            Text(
              '$wins W · $losses L',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        AppSpacing.vXs,
        ClipRRect(
          borderRadius: AppRadius.rPill,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    color: p.border,
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: winRate),
                    duration: AppMotion.celebrate,
                    curve: AppMotion.decelerate,
                    builder: (context, v, _) {
                      return Container(
                        height: 10,
                        width: constraints.maxWidth * v,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.7), color],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Bar: board-size usage ───────────────────────────────────────────────────
class _BoardSizePanel extends StatelessWidget {
  final GameStats stats;

  const _BoardSizePanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final values = [
      stats.board3x3Games,
      stats.board4x4Games,
      stats.board5x5Games,
    ];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal == 0 ? 1 : maxVal) * 1.25;
    const barColors = [AppColors.violet, AppColors.pink, AppColors.teal];
    const labels = ['3×3', '4×4', '5×5'];

    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.grid_view_rounded,
            title: 'Board Size',
            subtitle: 'Games played per grid',
            accent: AppColors.cyan,
          ),
          AppSpacing.vLg,
          SizedBox(
            height: 200,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppMotion.celebrate,
              curve: AppMotion.decelerate,
              builder: (context, t, _) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY.toDouble(),
                    barTouchData: BarTouchData(enabled: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= labels.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xs),
                              child: Text(
                                labels[i],
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < values.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: values[i] * t,
                              width: 34,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.sm),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  barColors[i].withValues(alpha: 0.55),
                                  barColors[i],
                                ],
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY.toDouble(),
                                color: p.border,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
