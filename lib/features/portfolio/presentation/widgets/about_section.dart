import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../../core/utils/section_title.dart';

class AboutSection extends StatelessWidget {
  final String bio;
  final List<String> badges;

  const AboutSection({
    super.key,
    required this.bio,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 60,
        vertical: AppSizes.sectionPadding,
      ),
      child: Column(
        children: [
          const SectionTitle(title: AppStrings.aboutTitle),
          const SizedBox(height: 48),
          SizedBox(
            width: 700,
            child: GradientBorderCard(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(
                    bio,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: badges.map((badge) {
                      return _BadgeChip(label: badge);
                    }).toList(),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(
                  begin: 0.3,
                  end: 0,
                ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatefulWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  State<_BadgeChip> createState() => _BadgeChipState();
}

class _BadgeChipState extends State<_BadgeChip> {
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
    return MouseRegion(
      onEnter: (_) => _hoveredNotifier.value = true,
      onExit: (_) => _hoveredNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hoveredNotifier,
        builder: (context, hovered, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: hovered ? AppColors.cyan : AppColors.purple,
                width: 1.5,
              ),
              color: hovered
                  ? AppColors.purple.withValues(alpha: 0.15)
                  : Colors.transparent,
              boxShadow: hovered
                  ? [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.2),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            ),
            transform: hovered
                ? (Matrix4.identity()..scale(1.05, 1.05))
                : Matrix4.identity(),
            child: Text(
              widget.label,
              style: TextStyle(
                color: hovered ? AppColors.cyan : AppColors.purple,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
