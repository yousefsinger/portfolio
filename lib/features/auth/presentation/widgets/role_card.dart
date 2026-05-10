import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int delay;
  final bool isPrimary;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.delay,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  late final ValueNotifier<bool> _hoveredNotifier;

  @override
  void initState() {
    super.initState();
    _hoveredNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _hoveredNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _hoveredNotifier.value = true,
      onExit: (_) => _hoveredNotifier.value = false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: _hoveredNotifier,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 200,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.isPrimary
                    ? AppColors.purple.withValues(alpha: hovered ? 1.0 : 0.85)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(
                  color: widget.isPrimary
                      ? AppColors.purple
                      : (hovered ? AppColors.purple : Colors.transparent),
                  width: 1.5,
                ),
                boxShadow: hovered
                    ? [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    widget.icon,
                    size: 48,
                    color: widget.isPrimary ? Colors.white : AppColors.purple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: widget.isPrimary
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.isPrimary
                              ? Colors.white70
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      )
          .animate(delay: Duration(milliseconds: widget.delay))
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.3, end: 0),
    );
  }
}
