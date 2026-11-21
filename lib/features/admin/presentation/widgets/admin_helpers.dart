import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_upload_service.dart';

/// "Upload image" button: picks an image from the device, uploads it to
/// Cloudinary and hands back the URL. Shows progress and errors itself.
class ImageUploadButton extends StatefulWidget {
  final ValueChanged<String> onUploaded;
  final String label;

  const ImageUploadButton({
    super.key,
    required this.onUploaded,
    this.label = 'Upload image',
  });

  @override
  State<ImageUploadButton> createState() => _ImageUploadButtonState();
}

class _ImageUploadButtonState extends State<ImageUploadButton> {
  bool _uploading = false;

  Future<void> _upload() async {
    setState(() => _uploading = true);
    try {
      final url = await ImageUploadService().pickAndUpload();
      if (url != null) widget.onUploaded(url);
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

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _uploading ? null : _upload,
      icon: _uploading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.purple),
            )
          : const Icon(Icons.cloud_upload_outlined, size: 18),
      label: Text(_uploading ? 'Uploading...' : widget.label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.purple,
        side: const BorderSide(color: AppColors.purple),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }
}

Widget dialogField(String label, TextEditingController ctrl,
    {int maxLines = 1, ValueChanged<String>? onChanged}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label),
  );
}

void confirmDelete(
    BuildContext context, String message, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
