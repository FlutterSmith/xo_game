import 'package:flutter/material.dart';
import 'dart:ui';
import 'animated_mark.dart';

class CellWidget5 extends StatefulWidget {
  final int index;
  final String value;
  final bool highlight;
  final VoidCallback onTap;

  const CellWidget5({
    super.key,
    required this.index,
    required this.value,
    required this.highlight,
    required this.onTap,
  });

  @override
  State<CellWidget5> createState() => _CellWidget5State();
}

class _CellWidget5State extends State<CellWidget5> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color baseColor = widget.highlight
        ? (isDark ? const Color(0xFF16f2b3) : const Color(0xFF10b981))
        : (isDark ? const Color(0xFF1e293b) : Colors.white);

    Color borderColor = widget.highlight
        ? (isDark ? const Color(0xFF16f2b3) : const Color(0xFF10b981))
        : (isDark
            ? (_isHovered ? const Color(0xFF8b5cf6) : Colors.white.withOpacity(0.1))
            : (_isHovered ? const Color(0xFF8b5cf6) : const Color(0xFFe2e8f0)));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: widget.highlight
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF16f2b3).withOpacity(0.3),
                                  const Color(0xFF06b6d4).withOpacity(0.3),
                                ]
                              : [
                                  const Color(0xFF10b981).withOpacity(0.2),
                                  const Color(0xFF0ea5e9).withOpacity(0.2),
                                ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  baseColor.withOpacity(0.8),
                                  baseColor.withOpacity(0.6),
                                ]
                              : [
                                  baseColor,
                                  baseColor.withOpacity(0.95),
                                ],
                        ),
                  border: Border.all(
                    color: borderColor,
                    width: widget.highlight ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (widget.highlight)
                      BoxShadow(
                        color: (isDark ? const Color(0xFF16f2b3) : const Color(0xFF10b981))
                            .withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    if (_isHovered && !widget.highlight)
                      BoxShadow(
                        color: const Color(0xFF8b5cf6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.02),
                                ]
                              : [
                                  Colors.white.withOpacity(0.7),
                                  Colors.white.withOpacity(0.5),
                                ],
                        ),
                      ),
                      child: Center(
                        child: widget.value.isEmpty
                            ? const SizedBox.shrink()
                            : AnimatedMark(mark: widget.value, markSize: 40),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
