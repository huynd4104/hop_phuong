import 'package:flutter/material.dart';

class MiniChip extends StatelessWidget {
  const MiniChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    final effectiveBgColor = color != null 
        ? color!.withValues(alpha: 0.1) 
        : cs.secondaryContainer.withValues(alpha: 0.7);
    final effectiveBorderColor = color != null 
        ? color!.withValues(alpha: 0.2) 
        : cs.secondaryContainer;
    final effectiveContentColor = color ?? cs.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: effectiveContentColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: effectiveContentColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
