import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/drive_url_helper.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';
import 'admin_helpers.dart';

class ProjectsTab extends StatelessWidget {
  final List<ProjectEntity> projects;
  const ProjectsTab({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Projects (${projects.length})',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showProjectDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Project'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = projects[index];
                return GradientBorderCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          image: p.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image:
                                      NetworkImage(convertDriveUrl(p.imageUrl)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: p.imageUrl.isEmpty
                            ? const Icon(Icons.image_outlined,
                                color: AppColors.purple)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(p.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.cyan,
                        ),
                        onPressed: () =>
                            _showProjectDialog(context, project: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red),
                        onPressed: () => confirmDelete(
                          context,
                          'Delete "${p.title}"?',
                          () => context.read<AdminCubit>().deleteProject(p.id),
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

  void _showProjectDialog(BuildContext context, {ProjectEntity? project}) {
    final existingProject = project;
    final isEditing = existingProject != null;
    final titleCtrl = TextEditingController(text: existingProject?.title ?? '');
    final descCtrl =
        TextEditingController(text: existingProject?.description ?? '');
    final imgUrlCtrl =
        TextEditingController(text: existingProject?.imageUrl ?? '');
    final tagsCtrl =
        TextEditingController(text: existingProject?.tags.join(', ') ?? '');
    final githubCtrl =
        TextEditingController(text: existingProject?.githubUrl ?? '');
    final playStoreCtrl =
        TextEditingController(text: existingProject?.playStoreUrl ?? '');

    final adminCubit = context.read<AdminCubit>();

    showDialog(
        context: context,
        builder: (ctx) => BlocProvider.value(
              value: adminCubit,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardRadius)),
                    title: Text(isEditing ? 'Edit Project' : 'Add New Project'),
                    content: SizedBox(
                      width: 500,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Image Preview
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.purple
                                        .withValues(alpha: 0.2)),
                              ),
                              child: imgUrlCtrl.text.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        convertDriveUrl(imgUrlCtrl.text),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                                child: Icon(
                                                    Icons.broken_image_outlined,
                                                    color: Colors.red)),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppColors.purple,
                                          size: 40)),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: imgUrlCtrl,
                              decoration: const InputDecoration(
                                  hintText: 'Project Image URL'),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 12),
                            dialogField('Title', titleCtrl),
                            const SizedBox(height: 12),
                            dialogField('Description', descCtrl, maxLines: 3),
                            const SizedBox(height: 12),
                            dialogField('Tags (comma separated)', tagsCtrl),
                            const SizedBox(height: 12),
                            dialogField('GitHub URL (optional)', githubCtrl),
                            const SizedBox(height: 12),
                            dialogField(
                                'Play Store URL (optional)', playStoreCtrl),
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
                          final tags = tagsCtrl.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                          final updatedProject = ProjectEntity(
                            id: existingProject?.id ?? '',
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            imageUrl: imgUrlCtrl.text.trim(),
                            tags: tags,
                            githubUrl: githubCtrl.text.trim().isEmpty
                                ? null
                                : githubCtrl.text.trim(),
                            playStoreUrl: playStoreCtrl.text.trim().isEmpty
                                ? null
                                : playStoreCtrl.text.trim(),
                            createdAt: existingProject?.createdAt,
                          );
                          if (isEditing) {
                            adminCubit.updateProject(updatedProject);
                          } else {
                            adminCubit.addProject(updatedProject);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Add Project'),
                      ),
                    ],
                  );
                },
              ),
            ));
  }
}
