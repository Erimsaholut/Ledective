import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// An iOS-style "inset grouped" section: rows on a rounded white card with
/// hairline separators, an optional header above and footer below.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.dividerIndent = 16,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    const captionStyle = TextStyle(
      color: AppColors.secondaryLabel,
      fontSize: 13,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(header!.toUpperCase(), style: captionStyle),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: AppColors.surface,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) Divider(indent: dividerIndent),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(footer!, style: captionStyle),
            ),
        ],
      ),
    );
  }
}

/// A small rounded square with a white glyph, as used in settings rows.
class TileIcon extends StatelessWidget {
  const TileIcon(this.icon, {super.key, required this.color, this.size = 29});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.66),
    );
  }
}
