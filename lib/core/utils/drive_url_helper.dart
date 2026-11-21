/// For Cloudinary image links that don't already carry a transformation,
/// asks Cloudinary for an optimized copy: best format for the browser
/// (WebP/AVIF), automatic quality, and at most 1600px wide. Other URLs are
/// returned unchanged.
String optimizeCloudinaryUrl(String url) {
  const marker = '/image/upload/';
  final i = url.indexOf(marker);
  if (!url.contains('res.cloudinary.com') || i == -1) return url;

  final rest = url.substring(i + marker.length);
  // Untransformed links continue with the version ("v1234/") or the file.
  final hasTransformation = RegExp(r'^[a-z]{1,3}_[^/]*/').hasMatch(rest);
  if (hasTransformation) return url;

  return '${url.substring(0, i + marker.length)}'
      'f_auto,q_auto,w_1600,c_limit/$rest';
}

String convertDriveUrl(String url) {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) return normalizedUrl;

  final fileId = extractDriveFileId(normalizedUrl);
  if (fileId != null) {
    return 'https://lh3.googleusercontent.com/d/$fileId';
  }

  // Not a Google Drive URL
  return optimizeCloudinaryUrl(normalizedUrl);
}

String buildDrivePreviewUrl(String url) {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) return normalizedUrl;

  final fileId = extractDriveFileId(normalizedUrl);
  if (fileId != null) {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }

  return normalizedUrl;
}

List<String> buildDriveImageCandidates(String url) {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) return const [];

  final fileId = extractDriveFileId(normalizedUrl);
  if (fileId == null) {
    return [optimizeCloudinaryUrl(normalizedUrl)];
  }

  return {
    'https://drive.google.com/thumbnail?id=$fileId&sz=w2000',
    'https://lh3.googleusercontent.com/d/$fileId',
    'https://drive.google.com/uc?export=view&id=$fileId',
    normalizedUrl,
  }.toList();
}

String? extractDriveFileId(String url) {
  if (url.isEmpty) return null;

  String? fileId;

  final ucMatch =
      RegExp(r'drive\.google\.com/uc\?.*id=([a-zA-Z0-9_-]+)').firstMatch(url);
  if (ucMatch != null) {
    fileId = ucMatch.group(1);
  }

  if (fileId == null) {
    final fileMatch =
        RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (fileMatch != null) {
      fileId = fileMatch.group(1);
    }
  }

  if (fileId == null) {
    final openMatch = RegExp(r'drive\.google\.com/open\?.*id=([a-zA-Z0-9_-]+)')
        .firstMatch(url);
    if (openMatch != null) {
      fileId = openMatch.group(1);
    }
  }

  return fileId;
}
