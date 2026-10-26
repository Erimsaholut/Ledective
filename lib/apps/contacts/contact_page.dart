import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';
import '../../widgets/grouped_list.dart';
import '../phone/call_screen.dart';

/// Shows a contact. Pops with `true` when the contact was deleted.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key, required this.contact, this.onDelete});

  final Contact contact;

  /// Deletes the contact. Story contacts can't be deleted.
  final Future<void> Function()? onDelete;

  Future<void> _delete(BuildContext context) async {
    if (!contact.userAdded || onDelete == null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Error"),
          content: const Text("You can't delete this contact."),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text("Okay"),
            ),
          ],
        ),
      );
      return;
    }

    await onDelete!();
    if (context.mounted) Navigator.pop(context, true);
  }

  void _call(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            CallScreen(number: contact.number, person: contact.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget action(IconData icon, String label, VoidCallback? onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: onTap == null
                          ? AppColors.separator
                          : AppColors.blue,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: onTap == null
                            ? AppColors.secondaryLabel
                            : AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Center(child: Avatar(name: contact.name, radius: 52)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              contact.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                action(Icons.message_rounded, "mesaj", null),
                action(Icons.call_rounded, "ara", () => _call(context)),
                action(Icons.videocam_rounded, "görüntülü", null),
                action(Icons.mail_rounded, "posta", null),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GroupedSection(
            children: [
              ListTile(
                title: const Text("mobil", style: TextStyle(fontSize: 13)),
                subtitle: Text(
                  contact.number,
                  style: const TextStyle(fontSize: 17, color: AppColors.blue),
                ),
                onTap: () => _call(context),
              ),
            ],
          ),
          GroupedSection(
            children: [
              ListTile(
                title: const Text(
                  "Delete Contact",
                  style: TextStyle(color: AppColors.red),
                ),
                onTap: () => _delete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
