import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/section_title.dart';
import '../../../../core/utils/snap_carousel.dart';
import '../../domain/entities/portfolio_entities.dart';

class SkillsSection extends StatelessWidget {
  final List<SkillEntity> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 700 ? 0 : 60,
        vertical: MediaQuery.sizeOf(context).width < 700 ? 24 : AppSizes.sectionPadding,
      ),
      child: Column(
        children: [
          const SectionTitle(title: AppStrings.skills),
          SizedBox(height: MediaQuery.sizeOf(context).width < 700 ? 28 : 48),
          LayoutBuilder(builder: (context, constraints) {
            if (SnapCarousel.useOn(context)) {
              // Phones: two rows that scroll sideways.
              const rows = 2;
              // Three full cards visible plus a peek of the next column.
              final cardW = ((MediaQuery.sizeOf(context).width - 30 - 12 * 3) /
                      3.35)
                  .clamp(96.0, 130.0);
              return SnapCarousel(
                itemWidth: cardW,
                spacing: 12,
                equalHeight: false,
                showDots: false,
                children: [
                  for (int i = 0; i < skills.length; i += rows)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int j = i; j < i + rows && j < skills.length; j++)
                          Padding(
                            padding: EdgeInsets.only(top: j == i ? 0 : 12),
                            child: _SkillCard(skill: skills[j], delay: 0),
                          ),
                      ],
                    ),
                ],
              );
            }

            final crossAxisCount = constraints.maxWidth > 1000
                ? 6
                : constraints.maxWidth > 700
                    ? 4
                    : 2;
            final spacing = 16.0;
            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                    crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: List.generate(skills.length, (index) {
                return SizedBox(
                  width: itemWidth.clamp(80, 160),
                  child: _SkillCard(
                    skill: skills[index],
                    delay: (index * 60).clamp(0, 600),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _SkillCard extends StatefulWidget {
  final SkillEntity skill;
  final int delay;

  const _SkillCard({required this.skill, required this.delay});

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> {
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
      child: ValueListenableBuilder<bool>(
        valueListenable: _hoveredNotifier,
        builder: (context, hovered, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            // width removed to let parent SizedBox control it
            height: 120,
            transform: hovered
                ? (Matrix4.identity()..scale(1.05, 1.05))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: hovered
                  ? (isDark
                      ? AppColors.darkCardHover
                      : AppColors.lightCardHover)
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(
                color: hovered ? AppColors.cyan : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: hovered
                  ? [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.skill.iconUrl != null ||
                    widget.skill.svgContent != null)
                  _SkillIcon(skill: widget.skill)
                else
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '< ',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '>',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  widget.skill.name,
                  style: TextStyle(
                    color: hovered
                        ? AppColors.purple
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Purple underline like original
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

class _SkillIcon extends StatelessWidget {
  final SkillEntity skill;

  const _SkillIcon({required this.skill});

  @override
  Widget build(BuildContext context) {
    final svgContent = skill.svgContent?.trim();
    if (svgContent != null && svgContent.isNotEmpty) {
      return SvgPicture.memory(
        Uint8List.fromList(utf8.encode(svgContent)),
        width: 32,
        height: 32,
      );
    }

    final source = skill.iconUrl?.trim();
    if (source == null || source.isEmpty) {
      return const SizedBox.shrink();
    }

    if (source.startsWith('assets/')) {
      return SvgPicture.asset(
        source,
        width: 32,
        height: 32,
      );
    }

    return SvgPicture.network(
      source,
      width: 32,
      height: 32,
      placeholderBuilder: (_) => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
