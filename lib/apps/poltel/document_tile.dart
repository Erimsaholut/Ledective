import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A Poltel inbox entry that opens [page] when tapped.
class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
    this.isNew = false,
    this.onOpen,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  final bool isNew;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: Container(
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: const Color(0xFF0B1F4D)),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle),
          trailing: isNew
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "YENİ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.separator,
                ),
          onTap: () {
            onOpen?.call();
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => page),
            );
          },
        ),
      ),
    );
  }
}
