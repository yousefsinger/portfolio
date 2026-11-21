import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/drive_url_helper.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';
import 'admin_helpers.dart';

class ProjectsTab extends StatefulWidget {
  final List<ProjectEntity> projects;
  const ProjectsTab({super.key, required this.projects});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  /// Local copy so a drag shows its result immediately, before Firestore
  /// sends the updated list back.
  late List<ProjectEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.projects);
  }

  @override
  void didUpdateWidget(covariant ProjectsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projects != widget.projects) {
      _items = List.of(widget.projects);
    }
  }

  void _move(int from, int to) {
    if (from == to || to < 0 || to >= _items.length) return;
    setState(() => _items.insert(to, _items.removeAt(from)));
    context.read<AdminCubit>().reorderProjects([for (final p in _items) p.id]);
  }

  /// New projects go to the top. If the list was never reordered, leave the
  /// order empty: projects without one are already sorted newest first.
  int? _newProjectOrder() {
    final orders = _items.map((p) => p.order).whereType<int>();
    if (orders.isEmpty) return null;
    return orders.reduce((a, b) => a < b ? a : b) - 1;
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;

    return Padding(
      padding: EdgeInsets.all(compact ? 16 : 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text('Projects (${_items.length})',
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Drag the handle or use the arrows to set the order. '
                  '#1 shows first on the portfolio.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: _items.length,
              onReorderItem: _move,
              itemBuilder: (context, index) {
                final p = _items[index];
                return Padding(
                  key: ValueKey(p.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GradientBorderCard(
                    padding: EdgeInsets.symmetric(
                        horizontal: compact ? 10 : 20, vertical: 16),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: const MouseRegion(
                            cursor: SystemMouseCursors.grab,
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.drag_indicator_rounded,
                                  color: AppColors.textSecondaryDark),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? AppColors.purple
                                : AppColors.purple.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  index == 0 ? Colors.white : AppColors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (!compact) ...[
                          Container(
                            width: 80,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              image: p.imageUrls.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          convertDriveUrl(p.imageUrls.first)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: p.imageUrls.isEmpty
                                ? const Icon(Icons.image_outlined,
                                    color: AppColors.purple)
                                : null,
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title.isEmpty ? '(no title)' : p.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(p.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        // Position controls (also usable without dragging).
                        if (!compact)
                          IconButton(
                            tooltip: 'Move to top',
                            icon: const Icon(Icons.vertical_align_top_rounded),
                            color: AppColors.purple,
                            onPressed:
                                index == 0 ? null : () => _move(index, 0),
                          ),
                        IconButton(
                          tooltip: 'Move up',
                          visualDensity: VisualDensity.compact,
                          icon:
                              const Icon(Icons.arrow_upward_rounded, size: 20),
                          color: AppColors.purple,
                          onPressed:
                              index == 0 ? null : () => _move(index, index - 1),
                        ),
                        IconButton(
                          tooltip: 'Move down',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.arrow_downward_rounded,
                              size: 20),
                          color: AppColors.purple,
                          onPressed: index == _items.length - 1
                              ? null
                              : () => _move(index, index + 1),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.cyan,
                          ),
                          onPressed: () =>
                              _showProjectDialog(context, project: p),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red),
                          onPressed: () => confirmDelete(
                            context,
                            'Delete "${p.title}"?',
                            () =>
                                context.read<AdminCubit>().deleteProject(p.id),
                          ),
                        ),
                      ],
                    ),
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
    final imgUrlsCtrl = TextEditingController(
        text: existingProject?.imageUrls.join(', ') ?? '');
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
                  final urls = imgUrlsCtrl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  final previewUrl = urls.isNotEmpty ? urls.first : '';

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
                              child: previewUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        convertDriveUrl(previewUrl),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ImageUploadButton(
                                // Each upload is added to the list, so a
                                // project can have several images.
                                onUploaded: (url) => setState(() {
                                  final current = imgUrlsCtrl.text.trim();
                                  imgUrlsCtrl.text =
                                      current.isEmpty ? url : '$current, $url';
                                }),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: imgUrlsCtrl,
                              decoration: const InputDecoration(
                                  hintText:
                                      'Project Image URLs (comma separated)'),
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
                          final imageUrls = imgUrlsCtrl.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          final updatedProject = ProjectEntity(
                            id: existingProject?.id ?? '',
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            imageUrls: imageUrls,
                            tags: tags,
                            githubUrl: githubCtrl.text.trim().isEmpty
                                ? null
                                : githubCtrl.text.trim(),
                            playStoreUrl: playStoreCtrl.text.trim().isEmpty
                                ? null
                                : playStoreCtrl.text.trim(),
                            createdAt: existingProject?.createdAt,
                            order: isEditing
                                ? existingProject.order
                                : _newProjectOrder(),
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
