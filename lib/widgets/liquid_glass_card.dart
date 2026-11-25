import 'package:flutter/material.dart';

/// Lightweight Liquid Glass container for scrolling cards and list items.
/// Uses a translucent iridescent gradient and crisp glass border without
/// per-item BackdropFilter to prevent scroll flickering and keep 60/120fps.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool highlight;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlight
              ? [
                  primary.withValues(alpha: isDark ? 0.24 : 0.16),
                  Colors.cyanAccent.withValues(alpha: isDark ? 0.03 : 0.04),
                  Colors.purpleAccent.withValues(alpha: isDark ? 0.025 : 0.03),
                  Colors.white.withValues(alpha: isDark ? 0.06 : 0.25),
                ]
              : [
                  Colors.white.withValues(alpha: isDark ? 0.07 : 0.50),
                  Colors.cyanAccent.withValues(alpha: isDark ? 0.015 : 0.025),
                  Colors.purpleAccent.withValues(alpha: isDark ? 0.015 : 0.025),
                  Colors.white.withValues(alpha: isDark ? 0.04 : 0.25),
                ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.70),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
