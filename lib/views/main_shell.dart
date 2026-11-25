import 'dart:ui';
import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

/// Root navigation shell with a floating Liquid Glass bottom bar
/// containing 3 tabs: Beranda, Cari, and Favorit.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _goToHome() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      SearchScreen(onLocationSelected: _goToHome),
      FavoritesScreen(onLocationSelected: _goToHome),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _LiquidGlassBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _LiquidGlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LiquidGlassBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.35),
                blurRadius: 22,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: isDark ? 0.08 : 0.10),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.06 : 0.18),
                      Colors.cyanAccent.withValues(alpha: isDark ? 0.02 : 0.03),
                      Colors.purpleAccent
                          .withValues(alpha: isDark ? 0.02 : 0.03),
                      Colors.white.withValues(alpha: isDark ? 0.03 : 0.10),
                    ],
                  ),
                  color: (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: isDark ? 0.02 : 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.28 : 0.60),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      outlinedIcon: Icons.home_outlined,
                      label: 'Beranda',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.search_rounded,
                      outlinedIcon: Icons.search_rounded,
                      label: 'Cari',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.star_rounded,
                      outlinedIcon: Icons.star_border_rounded,
                      label: 'Favorit',
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.16
                        : 0.45,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? icon : outlinedIcon,
                size: 22,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
