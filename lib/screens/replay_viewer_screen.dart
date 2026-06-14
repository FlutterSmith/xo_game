import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:advanced_xo_game/widgets/common/common.dart';
import '../models/game_replay.dart';
import '../services/database_service.dart';

/// Unified Replays screen — a neon-arcade gallery of past games with an
/// in-screen replay player. Merges the old History screen into this one.
class ReplayViewerScreen extends StatefulWidget {
  const ReplayViewerScreen({super.key});

  @override
  State<ReplayViewerScreen> createState() => _ReplayViewerScreenState();
}

class _ReplayViewerScreenState extends State<ReplayViewerScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<GameReplay> _replays = [];
  bool _loading = true;

  // The replay currently open in the in-screen player (null = list view).
  GameReplay? _active;

  @override
  void initState() {
    super.initState();
    _loadReplays();
  }

  Future<void> _loadReplays() async {
    try {
      final replays = await _db.getReplays();
      if (!mounted) return;
      setState(() {
        _replays = replays;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading replays: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteReplay(int id) async {
    await _db.deleteReplay(id);
    await _loadReplays();
  }

  Future<void> _confirmClearAll() async {
    final ok = await _showConfirmSheet(
      title: 'Clear All Replays',
      message:
          'Delete every saved replay? This action cannot be undone.',
      confirmLabel: 'Clear All',
    );
    if (ok == true) {
      await _db.clearAllReplays();
      await _loadReplays();
    }
  }

  Future<bool?> _showConfirmSheet({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    final theme = Theme.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: AppSpacing.page,
        child: GlassPanel(
          glowColor: AppColors.red,
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.16),
                      borderRadius: AppRadius.rMd,
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.red),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                ],
              ),
              AppSpacing.vSm,
              Text(message, style: theme.textTheme.bodyMedium),
              AppSpacing.vLg,
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      label: 'Cancel',
                      variant: NeonButtonVariant.secondary,
                      onTap: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: NeonButton(
                      label: confirmLabel,
                      icon: Icons.delete_forever_rounded,
                      variant: NeonButtonVariant.danger,
                      onTap: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReplay(GameReplay replay) {
    setState(() => _active = replay);
  }

  void _closeReplay() {
    setState(() => _active = null);
  }

  @override
  Widget build(BuildContext context) {
    final inPlayer = _active != null;
    return AppScaffold(
      title: inPlayer ? 'Replay' : 'Replays',
      showBack: true,
      onBack: inPlayer ? _closeReplay : null,
      actions: [
        if (!inPlayer && _replays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GlassIconButton(
              icon: Icons.delete_sweep_rounded,
              color: AppColors.red,
              tooltip: 'Clear all',
              onTap: _confirmClearAll,
            ),
          ),
      ],
      body: inPlayer
          ? _ReplayPlayer(
              key: ValueKey(_active!.id),
              replay: _active!,
            )
          : _buildListView(),
    );
  }

  Widget _buildListView() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.violet),
      );
    }
    if (_replays.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.violet,
      backgroundColor: AppPalette.of(context).surface,
      onRefresh: _loadReplays,
      child: ListView.separated(
        padding: AppSpacing.page,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _replays.length + 1,
        separatorBuilder: (_, __) => AppSpacing.vSm,
        itemBuilder: (context, index) {
          if (index == 0) {
            return FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: SectionHeader(
                  icon: Icons.movie_creation_rounded,
                  title: 'Game Replays',
                  subtitle:
                      '${_replays.length} saved ${_replays.length == 1 ? 'game' : 'games'} • tap to watch',
                  accent: AppColors.pink,
                ),
              ),
            );
          }
          final replay = _replays[index - 1];
          return FadeSlideIn(
            delay: AppMotion.stagger(index),
            child: _buildReplayCard(replay),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: FadeSlideIn(
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.45),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              AppSpacing.vLg,
              Text(
                'No Replays Yet',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              AppSpacing.vXs,
              Text(
                'Finish a game and it will be saved here for you to watch move by move.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppPalette.of(context).textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vLg,
              NeonButton(
                label: 'Play a Game',
                icon: Icons.sports_esports_rounded,
                expand: false,
                onTap: () => Navigator.of(context).pushNamed('/game-setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplayCard(GameReplay replay) {
    final theme = Theme.of(context);
    final isDraw = replay.winner == 'Draw';
    final accent =
        isDraw ? AppColors.draw : AppColors.markColor(replay.winner);

    return Dismissible(
      key: ValueKey('replay-${replay.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final ok = await _showConfirmSheet(
          title: 'Delete Replay',
          message:
              'Remove this game from your replays? This cannot be undone.',
          confirmLabel: 'Delete',
        );
        if (ok == true) {
          await _deleteReplay(replay.id);
        }
        return false; // We refresh the list ourselves; avoid double-remove.
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.18),
          borderRadius: AppRadius.rLg,
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.red),
      ),
      child: GlassPanel(
        onTap: () => _openReplay(replay),
        glowColor: accent,
        glowBlur: 18,
        borderColor: accent.withValues(alpha: 0.35),
        child: Row(
          children: [
            _resultBadge(replay, accent),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    replay.result,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vXs,
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: [
                      _chip(replay.gameMode, Icons.people_alt_rounded,
                          AppColors.violet),
                      _chip('${replay.boardSize}×${replay.boardSize}',
                          Icons.grid_view_rounded, AppColors.cyan),
                      if (replay.gameMode == 'PvC')
                        _chip(
                          replay.difficulty,
                          Icons.psychology_rounded,
                          AppColors.difficulty(replay.difficulty),
                        ),
                      _chip('${replay.movesCount} moves',
                          Icons.touch_app_rounded, AppColors.pink),
                    ],
                  ),
                  AppSpacing.vXs,
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppPalette.of(context).textMuted,
                      ),
                      AppSpacing.hXs,
                      Flexible(
                        child: Text(
                          _formatDate(replay.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppPalette.of(context).textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.hXs,
            const Icon(Icons.play_circle_fill_rounded,
                color: AppColors.violet, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _resultBadge(GameReplay replay, Color accent) {
    final isDraw = replay.winner == 'Draw';
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(
        isDraw
            ? Icons.handshake_rounded
            : Icons.emoji_events_rounded,
        color: accent,
        size: 26,
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color accent) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: AppRadius.rPill,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accent),
          AppSpacing.hXs,
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM d, y · h:mm a').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }
}

/// In-screen replay player — steps through the moves of a single [GameReplay]
/// on a mini neon board. Preserves the original playback logic (even index = X,
/// odd = O, 800 ms auto-play interval, slider + prev/next/play controls).
class _ReplayPlayer extends StatefulWidget {
  final GameReplay replay;

  const _ReplayPlayer({super.key, required this.replay});

  @override
  State<_ReplayPlayer> createState() => _ReplayPlayerState();
}

class _ReplayPlayerState extends State<_ReplayPlayer> {
  int _currentMoveIndex = 0;
  late List<int> _moves;
  late List<String> _board;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _moves = (jsonDecode(widget.replay.moves) as List).cast<int>();
    _board =
        List.filled(widget.replay.boardSize * widget.replay.boardSize, '');
    _updateBoardToMove(0);
  }

  void _updateBoardToMove(int moveIndex) {
    setState(() {
      _board =
          List.filled(widget.replay.boardSize * widget.replay.boardSize, '');
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
      if (!_isPlaying || !mounted) break;
      _updateBoardToMove(i);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (!mounted) return;
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
    final replay = widget.replay;
    final hasMoves = _moves.isNotEmpty;

    return ListView(
      padding: AppSpacing.page,
      children: [
        FadeSlideIn(child: _buildHeader(replay)),
        AppSpacing.vLg,
        FadeSlideIn(
          delay: AppMotion.stagger(1),
          child: Center(child: _buildBoard()),
        ),
        AppSpacing.vLg,
        if (hasMoves)
          FadeSlideIn(
            delay: AppMotion.stagger(2),
            child: _buildControls(),
          ),
      ],
    );
  }

  Widget _buildHeader(GameReplay replay) {
    final theme = Theme.of(context);
    final isDraw = replay.winner == 'Draw';
    final accent =
        isDraw ? AppColors.draw : AppColors.markColor(replay.winner);
    final total = _moves.isEmpty ? 0 : _moves.length;
    final shown = _moves.isEmpty ? 0 : _currentMoveIndex + 1;

    return GlassPanel(
      glowColor: accent,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: accent.withValues(alpha: 0.6), width: 2),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isDraw
                      ? Icons.handshake_rounded
                      : Icons.emoji_events_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      replay.result,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vXs,
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        _miniChip(replay.gameMode, AppColors.violet),
                        _miniChip('${replay.boardSize}×${replay.boardSize}',
                            AppColors.cyan),
                        if (replay.gameMode == 'PvC')
                          _miniChip(replay.difficulty,
                              AppColors.difficulty(replay.difficulty)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.12),
              borderRadius: AppRadius.rPill,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timeline_rounded,
                    size: 16, color: AppColors.violet),
                AppSpacing.hXs,
                Text(
                  'Move $shown of $total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color accent) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: AppRadius.rPill,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBoard() {
    final size = widget.replay.boardSize;
    final p = AppPalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSide =
            constraints.maxWidth.clamp(0, 420).toDouble();
        const gap = AppSpacing.xs;
        final cellSize = (boardSide - gap * (size - 1) - AppSpacing.md * 2) /
            size;

        return Container(
          width: boardSide,
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.violet.withValues(alpha: 0.10),
                AppColors.pink.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: AppRadius.rXl,
            border: Border.all(color: p.border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: 0.30),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
              crossAxisSpacing: gap,
              mainAxisSpacing: gap,
            ),
            itemCount: size * size,
            itemBuilder: (context, index) {
              final mark = _board[index];
              return Container(
                decoration: BoxDecoration(
                  color: p.surface.withValues(alpha: p.isDark ? 0.5 : 0.7),
                  borderRadius: AppRadius.rMd,
                  border: Border.all(color: p.border),
                ),
                alignment: Alignment.center,
                child: mark.isEmpty
                    ? null
                    : AnimatedMark(
                        key: ValueKey('cell-$index-$mark-$_currentMoveIndex'),
                        mark: mark,
                        markSize: cellSize * 0.78,
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    final theme = Theme.of(context);
    final maxIndex = _moves.length - 1;
    final atStart = _currentMoveIndex == 0;
    final atEnd = _currentMoveIndex >= maxIndex;

    return GlassPanel(
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.violet,
              inactiveTrackColor: AppColors.violet.withValues(alpha: 0.2),
              thumbColor: AppColors.pink,
              overlayColor: AppColors.violet.withValues(alpha: 0.2),
              trackHeight: 5,
            ),
            child: Slider(
              value: _currentMoveIndex.toDouble(),
              min: 0,
              max: maxIndex > 0 ? maxIndex.toDouble() : 1,
              divisions: maxIndex > 0 ? maxIndex : 1,
              onChanged: _isPlaying || maxIndex <= 0
                  ? null
                  : (value) => _updateBoardToMove(value.toInt()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppPalette.of(context).textMuted,
                    )),
                Text('End',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppPalette.of(context).textMuted,
                    )),
              ],
            ),
          ),
          AppSpacing.vMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ctrlButton(
                icon: Icons.first_page_rounded,
                onTap: _isPlaying || atStart
                    ? null
                    : () => _updateBoardToMove(0),
              ),
              _ctrlButton(
                icon: Icons.chevron_left_rounded,
                onTap: _isPlaying || atStart
                    ? null
                    : () => _updateBoardToMove(_currentMoveIndex - 1),
              ),
              _playButton(),
              _ctrlButton(
                icon: Icons.chevron_right_rounded,
                onTap: _isPlaying || atEnd
                    ? null
                    : () => _updateBoardToMove(_currentMoveIndex + 1),
              ),
              _ctrlButton(
                icon: Icons.last_page_rounded,
                onTap: _isPlaying || atEnd
                    ? null
                    : () => _updateBoardToMove(maxIndex),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playButton() {
    return Pressable(
      onTap: _isPlaying ? _stopReplay : _playReplay,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: 0.5),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }

  Widget _ctrlButton({required IconData icon, VoidCallback? onTap}) {
    final p = AppPalette.of(context);
    final enabled = onTap != null;
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: p.surface,
          shape: BoxShape.circle,
          border: Border.all(color: p.border),
        ),
        child: Icon(
          icon,
          color: enabled ? p.text : p.textMuted.withValues(alpha: 0.4),
          size: 26,
        ),
      ),
    );
  }
}
