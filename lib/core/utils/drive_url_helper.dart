String convertDriveUrl(String url) {
  final normalizedUrl = url.trim();
  if (normalizedUrl.isEmpty) return normalizedUrl;

  final fileId = extractDriveFileId(normalizedUrl);
  if (fileId != null) {
    return 'https://lh3.googleusercontent.com/d/$fileId';
  }

  // Not a Google Drive URL — return as-is
  return normalizedUrl;
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
    return [normalizedUrl];
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
