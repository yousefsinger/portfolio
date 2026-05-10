import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';
import 'admin_helpers.dart';

class ExperiencesTab extends StatelessWidget {
  final List<ExperienceEntity> experiences;
  const ExperiencesTab({super.key, required this.experiences});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Experience (${experiences.length})',
                  style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () => _showAddExperienceDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Experience'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: experiences.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = experiences[index];
                return GradientBorderCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.work_rounded,
                            color: AppColors.purple),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.role,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${e.company} · ${e.startDate} - ${e.endDate}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    )),
                            const SizedBox(height: 6),
                            Text(
                              e.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded,
                            color: AppColors.cyan),
                        onPressed: () =>
                            _showAddExperienceDialog(context, experience: e),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red),
                        onPressed: () => confirmDelete(
                          context,
                          'Delete role "${e.role}" at "${e.company}"?',
                          () =>
                              context.read<AdminCubit>().deleteExperience(e.id),
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

  void _showAddExperienceDialog(BuildContext context,
      {ExperienceEntity? experience}) {
    final companyCtrl = TextEditingController(text: experience?.company ?? '');
    final roleCtrl = TextEditingController(text: experience?.role ?? '');
    final startCtrl = TextEditingController(text: experience?.startDate ?? '');
    final endCtrl = TextEditingController(text: experience?.endDate ?? '');
    final descCtrl = TextEditingController(text: experience?.description ?? '');

    final isEditing = experience != null;
    final adminCubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: adminCubit,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
          title: Text(isEditing ? 'Edit Experience' : 'Add New Experience'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  dialogField('Role / Position', roleCtrl),
                  const SizedBox(height: 12),
                  dialogField('Company', companyCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: dialogField(
                              'Start Date (e.g. Jan 2020)', startCtrl)),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              dialogField('End Date (e.g. Present)', endCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  dialogField('Description / Achievements', descCtrl,
                      maxLines: 5),
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
                final e = ExperienceEntity(
                  id: experience?.id ?? '',
                  company: companyCtrl.text.trim(),
                  role: roleCtrl.text.trim(),
                  startDate: startCtrl.text.trim(),
                  endDate: endCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );

                if (isEditing) {
                  adminCubit.updateExperience(e);
                } else {
                  adminCubit.addExperience(e);
                }
                Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
