import 'package:flutter/material.dart';

class AdvancedNeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final Duration animationDuration;
  final bool isEnabled;

  const AdvancedNeumorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _AdvancedNeumorphicButtonState createState() =>
      _AdvancedNeumorphicButtonState();
}

class _AdvancedNeumorphicButtonState extends State<AdvancedNeumorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isPressed
                        ? [
                            const Color(0xFFec4899).withOpacity(0.8),
                            const Color(0xFF8b5cf6).withOpacity(0.8),
                          ]
                        : [
                            const Color(0xFFec4899),
                            const Color(0xFF8b5cf6),
                          ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.5),
                      Colors.grey.withOpacity(0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isEnabled && !_isPressed
                ? [
                    BoxShadow(
                      color: const Color(0xFFec4899).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: const Color(0xFF8b5cf6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
