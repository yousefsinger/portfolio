import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'drive_url_helper.dart';

/// Network image that works for Google Drive links, on web and mobile.
///
/// * Tries several Drive URL formats in turn until one loads.
/// * On web, Drive hosts don't send CORS headers, so Flutter is allowed to
///   fall back to a plain HTML <img> element instead of fetching bytes.
/// * On mobile, cached_network_image keeps a disk cache.
class NetImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final WidgetBuilder loading;
  final WidgetBuilder error;

  const NetImage({
    super.key,
    required this.url,
    required this.loading,
    required this.error,
    this.fit = BoxFit.cover,
  });

  @override
  State<NetImage> createState() => _NetImageState();
}

class _NetImageState extends State<NetImage> {
  late List<String> _candidates;
  int _index = 0;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _candidates = buildDriveImageCandidates(widget.url);
  }

  @override
  void didUpdateWidget(covariant NetImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _candidates = buildDriveImageCandidates(widget.url);
      _index = 0;
      _advancing = false;
    }
  }

  Widget _onError(BuildContext context) {
    if (_index >= _candidates.length - 1) return widget.error(context);
    if (!_advancing) {
      _advancing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _index++;
          _advancing = false;
        });
      });
    }
    return widget.loading(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_candidates.isEmpty) return widget.error(context);
    final url = _candidates[_index];

    if (kIsWeb) {
      return Image.network(
        url,
        key: ValueKey(url),
        fit: widget.fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : widget.loading(context),
        errorBuilder: (context, _, __) => _onError(context),
      );
    }
    return CachedNetworkImage(
      key: ValueKey(url),
      imageUrl: url,
      fit: widget.fit,
      placeholder: (context, _) => widget.loading(context),
      errorWidget: (context, _, __) => _onError(context),
    );
  }
}
