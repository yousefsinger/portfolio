import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class GradientBorderCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.borderRadius = AppSizes.cardRadius,
    this.padding,
    this.fillColor,
  });

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard> {
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
    final fill =
        widget.fillColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard);

    return MouseRegion(
      onEnter: (_) => _hoveredNotifier.value = true,
      onExit: (_) => _hoveredNotifier.value = false,
      cursor: SystemMouseCursors.click,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hoveredNotifier,
        builder: (context, hovered, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: hovered
                ? (Matrix4.identity()
                  ..translate(-2.0, -2.0)
                  ..scale(1.02, 1.02))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: hovered
                  ? [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(4, 4),
                      ),
                    ]
                  : [],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: hovered
                    ? const LinearGradient(
                        colors: [AppColors.cyan, AppColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: hovered
                    ? null
                    : Border.all(
                        color: (isDark ? Colors.white : AppColors.purple)
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
              ),
              padding:
                  hovered ? const EdgeInsets.all(2) : const EdgeInsets.all(1),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius - (hovered ? 2 : 1),
                  ),
                ),
                padding: widget.padding ?? const EdgeInsets.all(24),
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
