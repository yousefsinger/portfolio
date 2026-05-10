import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../../core/utils/section_title.dart';
import '../cubit/pagination_cubit.dart';
import '../../domain/entities/portfolio_entities.dart';
import 'section_pagination_controls.dart';

class ExperienceSection extends StatefulWidget {
  final List<ExperienceEntity> experiences;

  const ExperienceSection({super.key, required this.experiences});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  late final PaginationCubit<ExperienceEntity> _paginationCubit;

  @override
  void initState() {
    super.initState();
    _paginationCubit = PaginationCubit<ExperienceEntity>(items: widget.experiences);
  }

  @override
  void didUpdateWidget(covariant ExperienceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.experiences != widget.experiences) {
      _paginationCubit.updateItems(widget.experiences);
    }
  }

  @override
  void dispose() {
    _paginationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paginationCubit,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: AppSizes.sectionPadding,
        ),
        child: Column(
          children: [
            const SectionTitle(title: 'Practical Experience'),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000
                  ? 3
                  : constraints.maxWidth > 700
                      ? 2
                      : 1;
              final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount;
              
              return BlocBuilder<PaginationCubit<ExperienceEntity>, PaginationState<ExperienceEntity>>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: List.generate(state.visibleItems.length, (index) {
                          return SizedBox(
                            width: cardWidth,
                            child: _ExperienceCard(
                              experience: state.visibleItems[index],
                              delay: (index * 100).clamp(0, 400),
                            ),
                          );
                        }),
                      ),
                      if (state.totalPages > 1) ...[
                        const SizedBox(height: 32),
                        SectionPaginationControls(
                          currentPage: state.currentPage,
                          totalPages: state.totalPages,
                          onPrevious: state.canGoPrevious
                              ? context.read<PaginationCubit<ExperienceEntity>>().previousPage
                              : null,
                          onNext: state.canGoNext
                              ? context.read<PaginationCubit<ExperienceEntity>>().nextPage
                              : null,
                        ),
                      ],
                    ],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceEntity experience;
  final int delay;

  const _ExperienceCard({
    required this.experience,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.work_history_rounded,
              color: AppColors.purple,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            experience.role,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 16, color: AppColors.cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  experience.company,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondaryDark),
              const SizedBox(width: 8),
              Text(
                '${experience.startDate} — ${experience.endDate}',
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            experience.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    )
    .animate(delay: Duration(milliseconds: delay))
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.3, end: 0);
  }
}
