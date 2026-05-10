import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../../portfolio/domain/entities/portfolio_entities.dart';
import '../cubit/admin_cubit.dart';
import 'admin_helpers.dart';

class SkillsTab extends StatelessWidget {
  final List<SkillEntity> skills;

  const SkillsTab({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skills (${skills.length})',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddSkillDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Skill'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: skills.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final skill = skills[index];
                return GradientBorderCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _SkillIconPreview(
                        iconUrl: skill.iconUrl,
                        svgContent: skill.svgContent,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          skill.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        onPressed: () => confirmDelete(
                          context,
                          'Delete "${skill.name}"?',
                          () =>
                              context.read<AdminCubit>().deleteSkill(skill.id),
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

  void _showAddSkillDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final iconUrlCtrl = TextEditingController();
    final adminCubit = context.read<AdminCubit>();
    String? svgContent;
    String? selectedFileName;

    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: adminCubit,
        child: StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickSvg() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: const ['svg'],
                withData: true,
              );

              final file = result?.files.single;
              if (file == null) return;

              final bytes = file.bytes;
              if (bytes == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not read the selected SVG file.'),
                    ),
                  );
                }
                return;
              }

              setState(() {
                svgContent = utf8.decode(bytes);
                selectedFileName = file.name;
              });
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              title: const Text('Add New Skill'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkillIconPreview(
                        iconUrl: iconUrlCtrl.text,
                        svgContent: svgContent,
                        size: 96,
                      ),
                      const SizedBox(height: 16),
                      dialogField('Skill Name', nameCtrl),
                      const SizedBox(height: 12),
                      dialogField(
                        'Asset / SVG URL (optional)',
                        iconUrlCtrl,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: pickSvg,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(
                          selectedFileName == null
                              ? 'Pick SVG From Device'
                              : 'Selected: $selectedFileName',
                        ),
                      ),
                      if (svgContent != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'The uploaded SVG will be saved with this skill and used in the portfolio.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
                    final skillName = nameCtrl.text.trim();
                    if (skillName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Skill name is required.'),
                        ),
                      );
                      return;
                    }

                    final skill = SkillEntity(
                      id: '',
                      name: skillName,
                      iconUrl: iconUrlCtrl.text.trim().isEmpty
                          ? null
                          : iconUrlCtrl.text.trim(),
                      svgContent: svgContent,
                    );
                    adminCubit.addSkill(skill);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Skill'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SkillIconPreview extends StatelessWidget {
  final String? iconUrl;
  final String? svgContent;
  final double size;

  const _SkillIconPreview({
    required this.iconUrl,
    required this.svgContent,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.purple.withValues(alpha: 0.15);
    final content = _buildIcon();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: content,
    );
  }

  Widget _buildIcon() {
    if (svgContent != null && svgContent!.trim().isNotEmpty) {
      return SvgPicture.memory(
        Uint8List.fromList(utf8.encode(svgContent!)),
        fit: BoxFit.contain,
      );
    }

    final source = iconUrl?.trim();
    if (source == null || source.isEmpty) {
      return const Icon(Icons.code_rounded, color: AppColors.purple);
    }

    if (source.startsWith('assets/')) {
      return SvgPicture.asset(source, fit: BoxFit.contain);
    }

    return SvgPicture.network(
      source,
      fit: BoxFit.contain,
      placeholderBuilder: (_) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
