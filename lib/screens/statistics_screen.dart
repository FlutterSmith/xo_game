import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocs/statistics_cubit.dart';
import '../models/game_stats.dart';
import 'dart:io';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

/// Statistics screen displaying game stats with charts
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Statistics',
            onPressed: () => _shareStatistics(context),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Import'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'export') {
                _exportStatistics(context);
              } else if (value == 'import') {
                _importStatistics(context);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<StatisticsCubit, GameStats>(
        builder: (context, stats) {
          if (stats.totalGames == 0) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverallStats(stats),
              const SizedBox(height: 16),
              _buildWinRateChart(stats),
              const SizedBox(height: 16),
              _buildGameModeStats(stats),
              const SizedBox(height: 16),
              _buildAIDifficultyStats(stats),
              const SizedBox(height: 16),
              _buildBoardSizeStats(stats),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Games Played Yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Start playing to see your statistics!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(GameStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Games', stats.totalGames, Icons.gamepad),
                _buildStatItem('Wins', stats.wins, Icons.emoji_events, Colors.green),
                _buildStatItem('Losses', stats.losses, Icons.close, Colors.red),
                _buildStatItem('Draws', stats.draws, Icons.horizontal_rule, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats.winRate / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.winRate >= 50 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Win Rate: ${stats.winRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWinRateChart(GameStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Win/Loss/Draw Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: stats.wins.toDouble(),
                      title: '${stats.wins}',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: stats.losses.toDouble(),
                      title: '${stats.losses}',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: stats.draws.toDouble(),
                      title: '${stats.draws}',
                      color: Colors.orange,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Wins', Colors.green),
                _buildLegendItem('Losses', Colors.red),
                _buildLegendItem('Draws', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildGameModeStats(GameStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Game Mode Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildModeRow('Player vs Player', stats.pvpGames, stats.pvpWins, stats.pvpDraws),
            const Divider(height: 24),
            _buildModeRow('Player vs Computer', stats.pvcGames, stats.pvcWins, stats.pvcDraws),
          ],
        ),
      ),
    );
  }

  Widget _buildModeRow(String mode, int games, int wins, int draws) {
    final winRate = games > 0 ? (wins / games * 100).toStringAsFixed(1) : '0.0';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mode,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Games: $games'),
            Text('Wins: $wins'),
            Text('Draws: $draws'),
            Text('Win Rate: $winRate%'),
          ],
        ),
      ],
    );
  }

  Widget _buildAIDifficultyStats(GameStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Difficulty Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDifficultyBar('Easy', stats.easyWins, stats.easyLosses, Colors.green),
            const SizedBox(height: 12),
            _buildDifficultyBar('Medium', stats.mediumWins, stats.mediumLosses, Colors.orange),
            const SizedBox(height: 12),
            _buildDifficultyBar('Hard', stats.hardWins, stats.hardLosses, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBar(String difficulty, int wins, int losses, Color color) {
    final total = wins + losses;
    final winRate = total > 0 ? (wins / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(difficulty, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$wins W - $losses L'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: winRate,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildBoardSizeStats(GameStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Board Size Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [stats.board3x3Games, stats.board4x4Games, stats.board5x5Games]
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble() * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('3x3');
                            case 1:
                              return const Text('4x4');
                            case 2:
                              return const Text('5x5');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: stats.board3x3Games.toDouble(),
                          color: Colors.blue,
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: stats.board4x4Games.toDouble(),
                          color: Colors.green,
                          width: 40,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: stats.board5x5Games.toDouble(),
                          color: Colors.purple,
                          width: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          await context.read<StatisticsCubit>().importStats(data);
          ScaffoldMessenger.of(context).showSnackBar(
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
