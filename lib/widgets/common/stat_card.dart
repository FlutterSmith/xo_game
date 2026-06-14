import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'count_up_text.dart';
import 'glass_panel.dart';

/// Compact stat tile: accent icon chip + (count-up) value + label. The single
/// stat-card used by the menu, result, and statistics screens (the old UI had
/// three near-identical implementations).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final num? value;
  final String? text;
  final Color accent;
  final int decimals;
  final String suffix;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.text,
    this.accent = AppColors.violet,
    this.decimals = 0,
    this.suffix = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: AppRadius.rSm,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (value != null)
            CountUpText(
              value: value!,
              decimals: decimals,
              suffix: suffix,
              style: theme.textTheme.headlineMedium?.copyWith(color: accent),
            )
          else
            Text(
              text ?? '',
              style: theme.textTheme.headlineSmall?.copyWith(color: accent),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
