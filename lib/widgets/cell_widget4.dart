import 'package:flutter/material.dart';
import 'animated_mark.dart';

class CellWidget4 extends StatelessWidget {
  final int index;
  final String value;
  final bool highlight;
  final VoidCallback onTap;
  const CellWidget4({
    super.key,
    required this.index,
    required this.value,
    required this.highlight,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    Color cellColor = highlight ? Colors.orangeAccent : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: cellColor,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: value.isEmpty
              ? const SizedBox.shrink()
              : AnimatedMark(mark: value, markSize: 60),
        ),
      ),
    );
  }
}
