import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/game_replay.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameReplay> _replays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReplays();
  }

  Future<void> _loadReplays() async {
    try {
      final replays = await DatabaseService.instance.getReplays();
      setState(() {
        _replays = replays;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading replays: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: isDark ? const Color(0xFF1e293b) : Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0d1224),
                    const Color(0xFF1e1436),
                    const Color(0xFF0f172a),
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                    Colors.pink.shade50,
                  ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _replays.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No games played yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _replays.length,
                    itemBuilder: (context, index) {
                      final replay = _replays[index];
                      final date = DateTime.parse(replay.date);
                      final formattedDate =
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

                      Color resultColor;
                      if (replay.winner == 'Draw') {
                        resultColor = const Color(0xFF06b6d4);
                      } else {
                        resultColor = const Color(0xFF16f2b3);
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: resultColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: resultColor, width: 2),
                            ),
                            child: Icon(
                              replay.winner == 'Draw'
                                  ? Icons.handshake_rounded
                                  : Icons.emoji_events_rounded,
                              color: resultColor,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            replay.result,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildBadge(
                                    replay.gameMode,
                                    Icons.people,
                                    isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildBadge(
                                    '${replay.boardSize}×${replay.boardSize}',
                                    Icons.grid_on,
                                    isDark,
                                  ),
                                  if (replay.gameMode == 'PvC') ...[
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      replay.difficulty,
                                      Icons.psychology,
                                      isDark,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: const Color(0xFF8b5cf6),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/replay-viewer',
                              arguments: replay.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8b5cf6).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8b5cf6).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF8b5cf6),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
