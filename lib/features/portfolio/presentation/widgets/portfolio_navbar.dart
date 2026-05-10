import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:md_portfolio/core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_cubit.dart';
import 'nav_item.dart';

class PortfolioNavbar extends StatelessWidget {
  final int activeIndex;
  final bool isAdmin;
  final Function(int)? onNavItemTap;

  final bool hasExperiences;

  const PortfolioNavbar({
    super.key,
    required this.activeIndex,
    this.isAdmin = false,
    this.hasExperiences = false,
    this.onNavItemTap,
  });

  List<String> get _getNavItems {
    final items = [
      AppStrings.home,
      AppStrings.about,
      AppStrings.skills,
      AppStrings.projects,
    ];
    if (hasExperiences) {
      items.add('Experience');
    }
    items.addAll([
      AppStrings.certificates,
      AppStrings.opinions,
      AppStrings.contact,
    ]);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            const Text(
              'YA.',
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // IconButton(
            //   icon: const Icon(
            //     Icons.logout_rounded,
            //     size: 20,
            //     color: AppColors.purple,
            //   ),
            //   onPressed: () => context.go(AppRouter.roleSelection),
            //   tooltip: 'Change Role',
            // ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_getNavItems.length, (index) {
                      final isActive = activeIndex == index;
                      return NavItem(
                        label: _getNavItems[index],
                        isActive: isActive,
                        onTap: () => onNavItemTap?.call(index),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            BlocBuilder<ThemeCubit, ThemeMode>(
              bloc: sl<ThemeCubit>(),
              builder: (_, mode) {
                return IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? Icons.wb_sunny_outlined
                        : Icons.dark_mode_outlined,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  onPressed: sl<ThemeCubit>().toggleTheme,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
