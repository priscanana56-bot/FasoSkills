import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class GlassBottomNavItem {
  final IconData icon;
  final String label;

  const GlassBottomNavItem({required this.icon, required this.label});
}

/// Barre de navigation flottante avec effet glassmorphism premium.
class GlassBottomNavBar extends StatelessWidget {
  static const double barHeight = 64;
  static const double bottomMargin = 16;
  static const Duration animationDuration = Duration(milliseconds: 300);

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassBottomNavItem> items;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static double reservedHeight(BuildContext context) {
    return barHeight + bottomMargin + MediaQuery.paddingOf(context).bottom + 8;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: barHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.glassBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: AppTheme.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowMedium,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppTheme.primaryTint(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => _GlassNavItem(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  final GlassBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: GlassBottomNavBar.animationDuration,
        curve: Curves.easeInOutCubic,
        height: 48,
        width: isSelected ? null : 48,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 0),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.glassInactiveFill,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.shadowPrimary,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isSelected
                  ? AppTheme.onPrimary
                  : AppTheme.textColor.withValues(alpha: 0.45),
            ),
            ClipRect(
              child: AnimatedAlign(
                duration: GlassBottomNavBar.animationDuration,
                curve: Curves.easeInOutCubic,
                alignment: Alignment.centerLeft,
                widthFactor: isSelected ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(
                      color: AppTheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
