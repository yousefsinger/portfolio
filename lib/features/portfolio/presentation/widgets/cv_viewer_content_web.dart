import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class CvViewerContent extends StatefulWidget {
  final String cvUrl;

  const CvViewerContent({
    super.key,
    required this.cvUrl,
  });

  @override
  State<CvViewerContent> createState() => _CvViewerContentState();
}

class _CvViewerContentState extends State<CvViewerContent> {
  static final Set<String> _registeredViewTypes = <String>{};
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'cv-iframe-view-${widget.cvUrl.hashCode}';
    if (_registeredViewTypes.add(_viewType)) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        return html.IFrameElement()
          ..src = widget.cvUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppSizes.cardRadius),
        bottomRight: Radius.circular(AppSizes.cardRadius),
      ),
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
