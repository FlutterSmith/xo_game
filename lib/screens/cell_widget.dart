import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final int index;
  final String value;
  final bool highlight;
  final VoidCallback onTap;
  const CellWidget({super.key, required this.index, required this.value, required this.highlight, required this.onTap});
  @override
  Widget build(BuildContext context) {
    Color cellColor = highlight ? Colors.greenAccent : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: cellColor,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
            child: Text(value),
          ),
        ),
      ),
    );
  }
}
