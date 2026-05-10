import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';

class CvViewerContent extends StatelessWidget {
  final String cvUrl;

  const CvViewerContent({
    super.key,
    required this.cvUrl,
  });

  @override
  Widget build(BuildContext context) {
    final parsedUrl = Uri.tryParse(cvUrl);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.open_in_browser_rounded,
              color: AppColors.purple,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              'CV preview is available on Flutter web.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: parsedUrl == null ? null : () => launchUrl(parsedUrl),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open CV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                side: const BorderSide(color: AppColors.purple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
