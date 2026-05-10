import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class NavItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ValueListenableBuilder<bool>(
            valueListenable: _hoveredNotifier,
            builder: (context, hovered, _) {
              final isHighlighted = widget.isActive || hovered;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: isHighlighted
                          ? AppColors.purple
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                      fontWeight:
                          widget.isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: widget.isActive ? 24 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
