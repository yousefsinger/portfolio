import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/drive_url_helper.dart';
import '../../../../core/utils/gradient_border_card.dart';
import '../../domain/entities/portfolio_entities.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final int delay;

  const ProjectCard({super.key, required this.project, required this.delay});

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadius),
              topRight: Radius.circular(AppSizes.cardRadius),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: project.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: convertDriveUrl(project.imageUrl),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.purple,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if ((project.githubUrl?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse(project.githubUrl!)),
                    icon: const Icon(Icons.code_rounded, size: 16),
                    label: const Text('View Code'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.purple,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.darkCard,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.purple,
        ),
      ),
    );
  }
}
