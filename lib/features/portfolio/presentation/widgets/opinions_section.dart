import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../../core/utils/section_title.dart';
import '../../domain/entities/portfolio_entities.dart';
import '../cubit/pagination_cubit.dart';
import '../cubit/portfolio_cubit.dart';
import 'section_pagination_controls.dart';

class OpinionsSection extends StatefulWidget {
  final List<CustomerOpinionEntity> opinions;

  const OpinionsSection({super.key, required this.opinions});

  @override
  State<OpinionsSection> createState() => _OpinionsSectionState();
}

class _OpinionsSectionState extends State<OpinionsSection> {
  static const int _opinionsPerPage = 4;
  late final PaginationCubit<CustomerOpinionEntity> _paginationCubit;

  @override
  void initState() {
    super.initState();
    _paginationCubit = PaginationCubit<CustomerOpinionEntity>(
      items: widget.opinions,
      itemsPerPage: _opinionsPerPage,
    );
  }

  @override
  void didUpdateWidget(covariant OpinionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opinions != widget.opinions) {
      _paginationCubit.updateItems(widget.opinions);
    }
  }

  @override
  void dispose() {
    _paginationCubit.close();
    super.dispose();
  }

  void _showAddOpinionDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    final portfolioCubit = context.read<PortfolioCubit>();
    int rating = 5;

    Widget dialogField(String label, TextEditingController ctrl,
        {int maxLines = 1}) {
      return TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: portfolioCubit,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: const Text('Add Your Opinion'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dialogField('Your Name *', nameCtrl),
                      const SizedBox(height: 12),
                      dialogField('Role / Title', roleCtrl),
                      const SizedBox(height: 12),
                      dialogField('Company', companyCtrl),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: rating,
                        decoration: InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        items: List.generate(
                          5,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              '${index + 1} Star${index == 0 ? '' : 's'}',
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => rating = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      dialogField('Your Opinion *', commentCtrl, maxLines: 4),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty ||
                        commentCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name and opinion are required.'),
                        ),
                      );
                      return;
                    }

                    portfolioCubit.submitOpinion(
                      CustomerOpinionEntity(
                        id: '',
                        customerName: nameCtrl.text.trim(),
                        customerRole: roleCtrl.text.trim(),
                        company: companyCtrl.text.trim(),
                        comment: commentCtrl.text.trim(),
                        rating: rating,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you! Your opinion was added.'),
                      ),
                    );
                  },
                  child: const Text('Submit Opinion'),
                ),
              ],
            );
          },
        ),
      ),
    );
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
            const SectionTitle(title: AppStrings.opinionsTitle),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddOpinionDialog(context),
              icon: const Icon(Icons.add_comment_rounded, size: 20),
              label: const Text('Add Your Opinion'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            BlocBuilder<PaginationCubit<CustomerOpinionEntity>,
                PaginationState<CustomerOpinionEntity>>(
              builder: (context, state) {
                if (state.items.isEmpty) {
                  return const _EmptyOpinionsState()
                      .animate()
                      .fadeIn(duration: 400.ms);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1000 ? 2 : 1;
                    final cardWidth =
                        (constraints.maxWidth - (crossAxisCount - 1) * 24) /
                            crossAxisCount;

                    return Column(
                      children: [
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children:
                              List.generate(state.visibleItems.length, (index) {
                            return SizedBox(
                              width: cardWidth,
                              child: _OpinionCard(
                                opinion: state.visibleItems[index],
                                delay: (index * 100).clamp(0, 300),
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
                                    .read<PaginationCubit<CustomerOpinionEntity>>()
                                    .previousPage
                                : null,
                            onNext: state.canGoNext
                                ? context
                                    .read<PaginationCubit<CustomerOpinionEntity>>()
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

class _OpinionCard extends StatelessWidget {
  final CustomerOpinionEntity opinion;
  final int delay;

  const _OpinionCard({
    required this.opinion,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBorderCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.purple,
            size: 34,
          ),
          const SizedBox(height: 16),
          Text(
            opinion.comment,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.purple.withValues(alpha: 0.14),
                child: Text(
                  _initials(opinion.customerName),
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opinion.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(opinion),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 2,
            children: List.generate(
              5,
              (index) => Icon(
                index < opinion.rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: AppColors.cyan,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.25, end: 0);
  }

  static String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) return '?';
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  static String _subtitle(CustomerOpinionEntity opinion) {
    final segments = [
      if (opinion.customerRole.trim().isNotEmpty) opinion.customerRole.trim(),
      if (opinion.company.trim().isNotEmpty) opinion.company.trim(),
    ];

    return segments.isEmpty ? 'Customer' : segments.join(' · ');
  }
}

class _EmptyOpinionsState extends StatelessWidget {
  const _EmptyOpinionsState();

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.reviews_outlined,
              color: AppColors.purple.withValues(alpha: 0.9),
              size: 38,
            ),
            const SizedBox(height: 14),
            Text(
              'No opinions added yet. Be the first to share your opinion!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
