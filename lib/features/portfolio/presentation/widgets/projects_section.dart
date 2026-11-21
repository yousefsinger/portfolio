import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/section_title.dart';
import '../../../../core/utils/snap_carousel.dart';
import '../cubit/pagination_cubit.dart';
import '../../domain/entities/portfolio_entities.dart';
import 'project_card.dart';
import 'section_pagination_controls.dart';

class ProjectsSection extends StatefulWidget {
  final List<ProjectEntity> projects;

  const ProjectsSection({super.key, required this.projects});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  static const int _projectsPerPage = 4;
  late final PaginationCubit<ProjectEntity> _paginationCubit;

  @override
  void initState() {
    super.initState();
    _paginationCubit = PaginationCubit<ProjectEntity>(
      items: widget.projects,
      itemsPerPage: _projectsPerPage,
    );
  }

  @override
  void didUpdateWidget(covariant ProjectsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projects != widget.projects) {
      _paginationCubit.updateItems(widget.projects);
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
        padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 700 ? 0 : 60,
          vertical: MediaQuery.sizeOf(context).width < 700 ? 24 : AppSizes.sectionPadding,
        ),
        child: Column(
          children: [
            const SectionTitle(title: AppStrings.projects),
            SizedBox(height: MediaQuery.sizeOf(context).width < 700 ? 28 : 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1000
                    ? 4
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;
                final cardWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * 20) /
                        crossAxisCount;

                return BlocBuilder<PaginationCubit<ProjectEntity>,
                    PaginationState<ProjectEntity>>(
                  builder: (context, state) {
                    if (SnapCarousel.useOn(context)) {
                      return SnapCarousel(
                        children: [
                          for (final item in state.items) ProjectCard(project: item, delay: 0),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children:
                              List.generate(state.visibleItems.length, (index) {
                            return SizedBox(
                              width: cardWidth,
                              child: ProjectCard(
                                project: state.visibleItems[index],
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
                                ? context
                                    .read<PaginationCubit<ProjectEntity>>()
                                    .previousPage
                                : null,
                            onNext: state.canGoNext
                                ? context
                                    .read<PaginationCubit<ProjectEntity>>()
                                    .nextPage
                                : null,
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
