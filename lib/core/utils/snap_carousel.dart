import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../constants/app_constants.dart';

/// Horizontal carousel that snaps card by card, reaches the screen edges and
/// shows page dots. Used on phones instead of stacking cards vertically.
class SnapCarousel extends StatefulWidget {
  /// Screens narrower than this use carousels instead of grids.
  static const double mobileBreakpoint = 700;

  static bool useOn(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  final List<Widget> children;

  /// Fixed item width. If null, uses [widthFraction] of the screen width.
  final double? itemWidth;
  final double widthFraction;
  final double maxItemWidth;
  final double spacing;
  final bool equalHeight;
  final bool showDots;

  const SnapCarousel({
    super.key,
    required this.children,
    this.itemWidth,
    this.widthFraction = 0.8,
    this.maxItemWidth = 380,
    this.spacing = 16,
    this.equalHeight = true,
    this.showDots = true,
  });

  @override
  State<SnapCarousel> createState() => _SnapCarouselState();
}

class _SnapCarouselState extends State<SnapCarousel> {
  final _controller = ScrollController();
  final _current = ValueNotifier<int>(0);
  double _extent = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final i = (_controller.offset / _extent)
          .round()
          .clamp(0, math.max(0, widget.children.length - 1))
          .toInt();
      if (_current.value != i) _current.value = i;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(builder: (context, constraints) {
      // Keep the first card aligned with the rest of the page content.
      final pad = math.max(0.0, (screenW - constraints.maxWidth) / 2);
      final itemW = widget.itemWidth ??
          math.min(screenW * widget.widthFraction, widget.maxItemWidth);
      _extent = itemW + widget.spacing;

      Widget row = Row(
        crossAxisAlignment: widget.equalHeight
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widget.children.length; i++)
            Padding(
              padding: EdgeInsets.only(
                right: i == widget.children.length - 1 ? 0 : widget.spacing,
              ),
              child: SizedBox(width: itemW, child: widget.children[i]),
            ),
        ],
      );
      if (widget.equalHeight) row = IntrinsicHeight(child: row);

      final scroller = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
          },
        ),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: _SnapScrollPhysics(itemExtent: _extent),
          // Vertical padding leaves room for card shadows / hover effects.
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 24),
          child: row,
        ),
      );

      return Column(
        children: [
          FullBleed(width: screenW, child: scroller),
          if (widget.showDots && widget.children.length > 1)
            ValueListenableBuilder<int>(
              valueListenable: _current,
              builder: (context, current, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.children.length, (i) {
                  final active = i == current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              colors: [AppColors.purple, AppColors.cyan],
                            )
                          : null,
                      color: active
                          ? null
                          : AppColors.purple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      );
    });
  }
}

/// Lays its child out at [width] (usually the screen width) while taking only
/// the parent's width itself, centring the child so it bleeds out evenly on
/// both sides. Lets a carousel inside padded content reach the screen edges.
class FullBleed extends SingleChildRenderObjectWidget {
  final double width;

  const FullBleed({super.key, required this.width, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderFullBleed(width);

  @override
  void updateRenderObject(BuildContext context, RenderFullBleed renderObject) {
    renderObject.width = width;
  }
}

class RenderFullBleed extends RenderShiftedBox {
  RenderFullBleed(this._width) : super(null);

  double _width;
  set width(double value) {
    if (value == _width) return;
    _width = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final c = constraints;
    if (child == null) {
      size = c.smallest;
      return;
    }
    child!.layout(
      BoxConstraints(
        minWidth: _width,
        maxWidth: _width,
        minHeight: c.minHeight,
        maxHeight: c.maxHeight,
      ),
      parentUsesSize: true,
    );
    size = c.constrain(Size(c.maxWidth, child!.size.height));
    (child!.parentData as BoxParentData).offset =
        Offset((size.width - _width) / 2, 0);
  }
}

/// Snaps the scroll position to multiples of [itemExtent].
class _SnapScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const _SnapScrollPhysics({required this.itemExtent, super.parent});

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) => _SnapScrollPhysics(
        itemExtent: itemExtent,
        parent: buildParent(const BouncingScrollPhysics().applyTo(ancestor)),
      );

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final tolerance = toleranceFor(position);
    double page = position.pixels / itemExtent;
    if (velocity < -tolerance.velocity) {
      page = page.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      page = page.ceilToDouble();
    } else {
      page = page.roundToDouble();
    }

    final target = (page * itemExtent)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < 0.5) return null;

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}
