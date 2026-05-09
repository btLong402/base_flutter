import 'package:base_flutter/core/base/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A premium, custom-animated bottom navigation bar with a sliding indicator.
class SlidingBottomNavigationBar extends StatelessWidget {
  const SlidingBottomNavigationBar({
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.slate950 : Colors.white;
    final shadowColor = isDark ? Colors.black : AppColors.slate200;
    final unselectedColor = isDark ? AppColors.slate400 : AppColors.slate500;
    final selectedColor = isDark ? Colors.white : AppColors.slate900;
    const indicatorColor = AppColors.secondary500;

    return Container(
      height: 70.h + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sliding Indicator (Pill)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            // Calculate horizontal center for each of the 3 items
            left: (selectedIndex * (MediaQuery.of(context).size.width / 3)) +
                (MediaQuery.of(context).size.width / 6) -
                28.w, // Half of pill width (56.w / 2 = 28.w)
            top: 8.h, // Precisely align with the icon's vertical position
            child: Container(
              width: 56.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: indicatorColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Navigation Items
          Row(
            children: [
              _BottomNavItem(
                isSelected: selectedIndex == 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Home',
                unselectedColor: unselectedColor,
                selectedColor: selectedColor,
                onTap: () => onTap(0),
              ),
              _BottomNavItem(
                isSelected: selectedIndex == 1,
                icon: Icons.search_outlined,
                selectedIcon: Icons.search_rounded,
                label: 'Search',
                unselectedColor: unselectedColor,
                selectedColor: selectedColor,
                onTap: () => onTap(1),
              ),
              _BottomNavItem(
                isSelected: selectedIndex == 2,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'Settings',
                unselectedColor: unselectedColor,
                selectedColor: selectedColor,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.isSelected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.unselectedColor,
    required this.selectedColor,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color unselectedColor;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            SizedBox(height: 14.h), // Top padding to align icon with pill
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? Colors.white : unselectedColor,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
