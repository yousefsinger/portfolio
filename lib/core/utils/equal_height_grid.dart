import 'package:flutter/material.dart';

/// Grid where every card in a row gets the height of the tallest one, so a
/// row never mixes big and small cards. Cards keep their column width; a
/// short last row stays left-aligned.
class EqualHeightGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double spacing;

  const EqualHeightGrid({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = columns.clamp(1, 12);
      final itemWidth =
          ((constraints.maxWidth - (cols - 1) * spacing) / cols).floorToDouble();

      final rows = <Widget>[];
      for (var start = 0; start < children.length; start += cols) {
        final rowItems = children.sublist(
            start, (start + cols).clamp(0, children.length));
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rowItems.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                SizedBox(width: itemWidth, child: rowItems[i]),
              ],
            ],
          ),
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            rows[i],
          ],
        ],
      );
    });
  }
}
