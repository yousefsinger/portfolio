import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

/// Lets the admin pick an image from their device and uploads it to
/// Cloudinary using an unsigned upload preset (no secret in the app).
class ImageUploadService {
  /// Cloudinary's free plan rejects files above 10 MB.
  static const int maxBytes = 10 * 1024 * 1024;

  /// Opens the file picker and uploads the chosen image.
  ///
  /// Returns the public https URL, or null if the user cancelled.
  /// Throws an [Exception] with a readable message if the upload fails.
  Future<String?> pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return null;
    return _upload(file);
  }

  /// Lets the user pick several images and uploads them one after another.
  ///
  /// [onUploaded] is called with each URL as soon as that image is done, so
  /// finished uploads are kept even if a later one fails. [onProgress]
  /// reports (done, total). Returns the number of images picked (0 if the
  /// user cancelled). Throws on the first failed upload.
  Future<int> pickAndUploadMany({
    required void Function(String url) onUploaded,
    void Function(int done, int total)? onProgress,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    final files = result?.files ?? const <PlatformFile>[];
    for (var i = 0; i < files.length; i++) {
      onProgress?.call(i, files.length);
      onUploaded(await _upload(files[i]));
    }
    onProgress?.call(files.length, files.length);
    return files.length;
  }

  Future<String> _upload(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Could not read "${file.name}".');
    }
    if (bytes.length > maxBytes) {
      throw Exception('"${file.name}" is larger than 10 MB. '
          'Please choose a smaller image.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/'
          '${AppStrings.cloudinaryCloudName}/image/upload'),
    )
      ..fields['upload_preset'] = AppStrings.cloudinaryUploadPreset
      ..fields['folder'] = AppStrings.cloudinaryFolder
      ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name));

    final response = await http.Response.fromStream(await request.send());
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final message = (body['error'] as Map?)?['message'] ?? response.body;
      throw Exception('Upload failed: $message');
    }
    return body['secure_url'] as String;
  }
}
