import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../core/utils/net_image.dart';

/// Edits a project's image list: upload several images to Cloudinary at once,
/// see them as thumbnails, reorder them (the first one is shown first on the
/// portfolio) and remove any of them.
///
/// Works on [images] in place and calls [onChanged] after every change.
class ProjectImagesEditor extends StatefulWidget {
  final List<String> images;
  final VoidCallback onChanged;

  const ProjectImagesEditor({
    super.key,
    required this.images,
    required this.onChanged,
  });

  @override
  State<ProjectImagesEditor> createState() => _ProjectImagesEditorState();
}

class _ProjectImagesEditorState extends State<ProjectImagesEditor> {
  final _urlCtrl = TextEditingController();
  bool _uploading = false;
  String _progress = '';

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  void _changed() {
    setState(() {});
    widget.onChanged();
  }

  Future<void> _upload() async {
    setState(() {
      _uploading = true;
      _progress = '';
    });
    try {
      await ImageUploadService().pickAndUploadMany(
        onUploaded: (url) {
          widget.images.add(url);
          _changed();
        },
        onProgress: (done, total) {
          // Shows which image is uploading now, e.g. "2/5".
          final current = done < total ? done + 1 : total;
          if (mounted && total > 1) {
            setState(() => _progress = ' $current/$total');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _addUrl() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;
    widget.images.add(url);
    _urlCtrl.clear();
    _changed();
  }

  void _move(int from, int to) {
    widget.images.insert(to, widget.images.removeAt(from));
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Images (${images.length})',
                style: const TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: _uploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.purple),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label:
                  Text(_uploading ? 'Uploading$_progress...' : 'Upload images'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                side: const BorderSide(color: AppColors.purple),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (images.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
            ),
            child: const Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.purple, size: 36),
                SizedBox(height: 8),
                Text('No images yet. Upload one or more.',
                    style: TextStyle(fontSize: 13)),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < images.length; i++)
                _Thumb(
                  url: images[i],
                  index: i,
                  isLast: i == images.length - 1,
                  onRemove: () {
                    images.removeAt(i);
                    _changed();
                  },
                  onLeft: i == 0 ? null : () => _move(i, i - 1),
                  onRight:
                      i == images.length - 1 ? null : () => _move(i, i + 1),
                ),
            ],
          ),
        if (images.length > 1) ...[
          const SizedBox(height: 6),
          const Text(
            '#1 is shown first. Use the arrows to change the order.',
            style: TextStyle(fontSize: 12, color: AppColors.cyan),
          ),
        ],
        const SizedBox(height: 12),
        // For images that are already online somewhere else.
        TextField(
          controller: _urlCtrl,
          onSubmitted: (_) => _addUrl(),
          decoration: InputDecoration(
            hintText: 'Or paste an image URL',
            isDense: true,
            suffixIcon: IconButton(
              tooltip: 'Add',
              icon: const Icon(Icons.add_rounded),
              onPressed: _addUrl,
            ),
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String url;
  final int index;
  final bool isLast;
  final VoidCallback onRemove;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  const _Thumb({
    required this.url,
    required this.index,
    required this.isLast,
    required this.onRemove,
    this.onLeft,
    this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    Widget small(IconData icon, VoidCallback? onTap, String tip) => Tooltip(
          message: tip,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    Colors.black.withValues(alpha: onTap == null ? 0.2 : 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 14,
                  color: onTap == null ? Colors.white38 : Colors.white),
            ),
          ),
        );

    return SizedBox(
      width: 140,
      height: 88,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetImage(
              url: url,
              loading: (_) => Container(
                color: AppColors.purple.withValues(alpha: 0.1),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.purple),
                  ),
                ),
              ),
              error: (_) => Container(
                color: Colors.red.withValues(alpha: 0.1),
                child:
                    const Icon(Icons.broken_image_outlined, color: Colors.red),
              ),
            ),
            Positioned(
              left: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppColors.purple
                      : Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: small(Icons.close_rounded, onRemove, 'Remove'),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: small(Icons.chevron_left_rounded, onLeft, 'Move earlier'),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: small(Icons.chevron_right_rounded, onRight, 'Move later'),
            ),
          ],
        ),
      ),
    );
  }
}
