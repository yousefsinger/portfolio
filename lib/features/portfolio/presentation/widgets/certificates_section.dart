import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../../core/utils/section_title.dart';
import '../cubit/pagination_cubit.dart';
import '../../domain/entities/portfolio_entities.dart';
import 'section_pagination_controls.dart';

class CertificatesSection extends StatefulWidget {
  final List<CertificateEntity> certificates;

  const CertificatesSection({super.key, required this.certificates});

  @override
  State<CertificatesSection> createState() => _CertificatesSectionState();
}

class _CertificatesSectionState extends State<CertificatesSection> {
  late final PaginationCubit<CertificateEntity> _paginationCubit;

  @override
  void initState() {
    super.initState();
    _paginationCubit =
        PaginationCubit<CertificateEntity>(items: widget.certificates);
  }

  @override
  void didUpdateWidget(covariant CertificatesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.certificates != widget.certificates) {
      _paginationCubit.updateItems(widget.certificates);
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
            const SectionTitle(title: AppStrings.certificates),
            const SizedBox(height: 48),
            LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              final cardWidth =
                  (constraints.maxWidth - (crossAxisCount - 1) * 20) /
                      crossAxisCount;
              return BlocBuilder<PaginationCubit<CertificateEntity>,
                  PaginationState<CertificateEntity>>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children:
                            List.generate(state.visibleItems.length, (index) {
                          return SizedBox(
                            width: cardWidth,
                            child: _CertificateCard(
                              certificate: state.visibleItems[index],
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
                                  .read<PaginationCubit<CertificateEntity>>()
                                  .previousPage
                              : null,
                          onNext: state.canGoNext
                              ? context
                                  .read<PaginationCubit<CertificateEntity>>()
                                  .nextPage
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

class _CertificateCard extends StatelessWidget {
  final CertificateEntity certificate;
  final int delay;

  const _CertificateCard({
    required this.certificate,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medal icon like original
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              color: AppColors.purple,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            certificate.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.business_outlined,
                  size: 14, color: AppColors.cyan),
              const SizedBox(width: 6),
              Text(
                certificate.issuer,
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondaryDark),
              const SizedBox(width: 6),
              Text(
                certificate.date,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if ((certificate.credentialUrl?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse(certificate.credentialUrl!)),
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: const Text('View Credential'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                side: const BorderSide(color: AppColors.purple),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }
}
