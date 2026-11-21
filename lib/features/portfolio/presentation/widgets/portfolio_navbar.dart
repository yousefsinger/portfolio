import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:md_portfolio/core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_cubit.dart';
import 'nav_item.dart';

class PortfolioNavbar extends StatelessWidget {
  /// Section labels, in page order.
  final List<String> items;
  final int activeIndex;
  final bool isAdmin;
  final Function(int)? onNavItemTap;

  const PortfolioNavbar({
    super.key,
    required this.items,
    required this.activeIndex,
    this.isAdmin = false,
    this.onNavItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 900;
    final iconColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      height: AppSizes.navHeight,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBg : AppColors.lightBg)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : AppColors.purple)
                .withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 40),
        child: Row(
          children: [
            // Hidden admin exit (kept intentionally tiny).
            IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                size: 5,
                color: AppColors.purple,
              ),
              onPressed: () => context.go(AppRouter.roleSelection),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onNavItemTap?.call(0),
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  'YA.',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: compact
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(items.length, (index) {
                            return NavItem(
                              label: items[index],
                              isActive: activeIndex == index,
                              onTap: () => onNavItemTap?.call(index),
                            );
                          }),
                        ),
                      ),
                    ),
            ),
            SizedBox(width: compact ? 0 : 16),
            BlocBuilder<ThemeCubit, ThemeMode>(
              bloc: sl<ThemeCubit>(),
              builder: (_, mode) {
                return IconButton(
                  tooltip: mode == ThemeMode.dark ? 'Light mode' : 'Dark mode',
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.dark_mode_outlined,
                    color: iconColor,
                  ),
                  onPressed: sl<ThemeCubit>().toggleTheme,
                );
              },
            ),
            if (compact)
              IconButton(
                tooltip: 'Menu',
                icon: Icon(Icons.menu_rounded, color: iconColor),
                onPressed: () => _openMenu(context),
              ),
          ],
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (int i = 0; i < items.length; i++)
                        _MenuTile(
                          label: items[i],
                          isActive: i == activeIndex,
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            // Let the sheet close before scrolling.
                            Future.delayed(
                              const Duration(milliseconds: 250),
                              () => onNavItemTap?.call(i),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MenuTile({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive
            ? AppColors.purple.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.purple : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? AppColors.purple
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isActive
                      ? AppColors.purple
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
