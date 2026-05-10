import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';
import 'admin_helpers.dart';

class OpinionsTab extends StatelessWidget {
  final List<CustomerOpinionEntity> opinions;

  const OpinionsTab({super.key, required this.opinions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Customer Opinions (${opinions.length})',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddOpinionDialog(context),
                  icon: const Icon(Icons.add_comment_rounded, size: 18),
                  label: const Text('Add Opinion'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: opinions.isEmpty
                ? const _OpinionsEmptyState()
                : ListView.separated(
                    itemCount: opinions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final opinion = opinions[index];

                      return GradientBorderCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  AppColors.purple.withValues(alpha: 0.15),
                              child: Text(
                                _initials(opinion.customerName),
                                style: const TextStyle(
                                  color: AppColors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          opinion.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      _RatingStars(rating: opinion.rating),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _subtitle(opinion),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    opinion.comment,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () => confirmDelete(
                                context,
                                'Delete opinion from "${opinion.customerName}"?',
                                () => context
                                    .read<AdminCubit>()
                                    .deleteOpinion(opinion.id),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddOpinionDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    final adminCubit = context.read<AdminCubit>();
    int rating = 5;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: adminCubit,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: const Text('Add Customer Opinion'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dialogField('Customer Name', nameCtrl),
                      const SizedBox(height: 12),
                      dialogField('Role / Title', roleCtrl),
                      const SizedBox(height: 12),
                      dialogField('Company', companyCtrl),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: rating,
                        decoration: const InputDecoration(labelText: 'Rating'),
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
                      dialogField('Opinion', commentCtrl, maxLines: 5),
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
                          content: Text(
                            'Customer name and opinion are required.',
                          ),
                        ),
                      );
                      return;
                    }

                    adminCubit.addOpinion(
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
                  },
                  child: const Text('Add Opinion'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) return '?';
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  String _subtitle(CustomerOpinionEntity opinion) {
    final segments = [
      if (opinion.customerRole.trim().isNotEmpty) opinion.customerRole.trim(),
      if (opinion.company.trim().isNotEmpty) opinion.company.trim(),
    ];

    return segments.isEmpty ? 'Customer' : segments.join(' · ');
  }
}

class _RatingStars extends StatelessWidget {
  final int rating;

  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.cyan,
          size: 18,
        ),
      ),
    );
  }
}

class _OpinionsEmptyState extends StatelessWidget {
  const _OpinionsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No customer opinions yet.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
