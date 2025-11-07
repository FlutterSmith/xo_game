import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/game_replay.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

/// Screen for viewing and replaying past games
class ReplayViewerScreen extends StatefulWidget {
  const ReplayViewerScreen({super.key});

  @override
  State<ReplayViewerScreen> createState() => _ReplayViewerScreenState();
}

class _ReplayViewerScreenState extends State<ReplayViewerScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<GameReplay> _replays = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReplays();
  }

  Future<void> _loadReplays() async {
    final replays = await _db.getReplays();
    setState(() {
      _replays = replays;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Replays'),
        centerTitle: true,
        actions: [
          if (_replays.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All Replays',
              onPressed: _showClearConfirmation,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _replays.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _replays.length,
                  itemBuilder: (context, index) {
                    return _buildReplayCard(_replays[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Game Replays',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Finish a game to save a replay!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReplayCard(GameReplay replay) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewReplay(replay),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      replay.result,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteReplay(replay.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip(replay.gameMode, Icons.gamepad),
                  const SizedBox(width: 8),
                  if (replay.gameMode == 'PvC')
                    _buildChip(replay.difficulty, Icons.psychology),
                  const SizedBox(width: 8),
                  _buildChip('${replay.boardSize}x${replay.boardSize}', Icons.grid_3x3),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Moves: ${replay.movesCount}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    _formatDate(replay.date),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM d, y h:mm a').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _viewReplay(GameReplay replay) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplayPlayerScreen(replay: replay),
      ),
    );
  }

  Future<void> _deleteReplay(int id) async {
    await _db.deleteReplay(id);
    _loadReplays();
  }

  Future<void> _showClearConfirmation() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Replays'),
        content: const Text(
          'Are you sure you want to delete all game replays? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _db.clearAllReplays();
              Navigator.pop(context);
              _loadReplays();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen for playing back a specific game replay
class ReplayPlayerScreen extends StatefulWidget {
  final GameReplay replay;

  const ReplayPlayerScreen({super.key, required this.replay});

  @override
  State<ReplayPlayerScreen> createState() => _ReplayPlayerScreenState();
}

class _ReplayPlayerScreenState extends State<ReplayPlayerScreen> {
  int _currentMoveIndex = 0;
  late List<int> _moves;
  late List<String> _board;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _moves = (jsonDecode(widget.replay.moves) as List).cast<int>();
    _board = List.filled(widget.replay.boardSize * widget.replay.boardSize, '');
    _updateBoardToMove(0);
  }

  void _updateBoardToMove(int moveIndex) {
    setState(() {
      _board = List.filled(widget.replay.boardSize * widget.replay.boardSize, '');
      for (int i = 0; i <= moveIndex && i < _moves.length; i++) {
        final player = i % 2 == 0 ? 'X' : 'O';
        _board[_moves[i]] = player;
      }
      _currentMoveIndex = moveIndex;
    });
  }

  Future<void> _playReplay() async {
    setState(() {
      _isPlaying = true;
    });

    for (int i = _currentMoveIndex; i < _moves.length; i++) {
      if (!_isPlaying) break;
      _updateBoardToMove(i);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    setState(() {
      _isPlaying = false;
    });
  }

  void _stopReplay() {
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replay'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildGameInfo(),
          Expanded(
            child: Center(
              child: _buildBoard(),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            widget.replay.result,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Move ${_currentMoveIndex + 1} of ${_moves.length}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    final size = widget.replay.boardSize;
    final cellSize = (MediaQuery.of(context).size.width - 64) / size;

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: size * size,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _board[index],
                style: TextStyle(
                  fontSize: cellSize * 0.5,
                  fontWeight: FontWeight.bold,
                  color: _board[index] == 'X' ? Colors.blue : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Slider(
            value: _currentMoveIndex.toDouble(),
            min: 0,
            max: (_moves.length - 1).toDouble(),
            divisions: _moves.length > 1 ? _moves.length - 1 : 1,
            onChanged: _isPlaying
                ? null
                : (value) {
                    _updateBoardToMove(value.toInt());
                  },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                onPressed: _isPlaying || _currentMoveIndex == 0
                    ? null
                    : () => _updateBoardToMove(0),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: 32,
                onPressed: _isPlaying || _currentMoveIndex == 0
                    ? null
                    : () => _updateBoardToMove(_currentMoveIndex - 1),
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
                onPressed: _isPlaying ? _stopReplay : _playReplay,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: 32,
                onPressed:
                    _isPlaying || _currentMoveIndex >= _moves.length - 1
                        ? null
                        : () => _updateBoardToMove(_currentMoveIndex + 1),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                onPressed:
                    _isPlaying || _currentMoveIndex >= _moves.length - 1
                        ? null
                        : () => _updateBoardToMove(_moves.length - 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
