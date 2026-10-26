import 'package:flutter/material.dart';

import '../../data/contacts_repository.dart';

/// Shows a contact. Pops with `true` when the contact was deleted.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key, required this.contact, this.onDelete});

  final Contact contact;

  /// Deletes the contact. Story contacts can't be deleted.
  final Future<void> Function()? onDelete;

  Future<void> _delete(BuildContext context) async {
    if (!contact.userAdded || onDelete == null) {
      await showAdaptiveDialog<void>(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text("Error"),
          content: const Text("You can't delete this contact."),
          actions: [
            TextButton(
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

  Widget _field(Widget child) {
    return Container(
      width: double.infinity,
      height: 100.0,
      margin: const EdgeInsets.only(bottom: 25),
      color: Colors.white,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: Text(contact.name),
        shadowColor: Colors.green,
      ),
      backgroundColor: Colors.green.shade200,
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _field(Text("Name: ${contact.name}")),
          _field(Text("Number: ${contact.number}")),
          _field(
            SizedBox.expand(
              child: TextButton(
                onPressed: () => _delete(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  overlayColor: Colors.blue,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text("Delete"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
