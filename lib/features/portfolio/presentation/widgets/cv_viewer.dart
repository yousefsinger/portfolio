import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/drive_url_helper.dart';
import 'cv_viewer_content_stub.dart'
    if (dart.library.html) 'cv_viewer_content_web.dart';

class CvViewerDialog extends StatelessWidget {
  final String cvUrl;

  const CvViewerDialog({
    super.key,
    required this.cvUrl,
  });

  static void show(BuildContext context, {required String cvUrl}) {
    showDialog(
      context: context,
      builder: (_) => CvViewerDialog(cvUrl: cvUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewUrl = buildDrivePreviewUrl(cvUrl);

    final screen = MediaQuery.sizeOf(context);
    final mobile = screen.width < 700;

    return Dialog(
      insetPadding: mobile
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: SizedBox(
        width: mobile ? screen.width : screen.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Curriculum Vitae',
                      style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: CvViewerContent(cvUrl: previewUrl)),
          ],
        ),
      ),
    );
  }
}
