import 'package:flutter/material.dart';

import '../../data/notes_repository.dart';
import '../../widgets/back_button.dart';

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  static const _paper = Color.fromRGBO(255, 252, 121, 1.0);

  final NotesRepository _repository = NotesRepository();
  List<String> _notes = [];
  int? _selected;

  @override
  void initState() {
    super.initState();
    _repository.load().then((notes) {
      if (mounted) setState(() => _notes = notes);
    });
  }

  Future<void> _addNote() async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => const _AddNoteDialog(),
    );
    if (note == null) return;
    setState(() {
      _notes = [..._notes, note];
      _selected = _notes.length - 1;
    });
    await _repository.save(_notes);
  }

  Future<void> _deleteSelectedNote() async {
    final selected = _selected;
    if (selected == null) return;
    setState(() {
      _notes = [..._notes]..removeAt(selected);
      _selected = null;
    });
    await _repository.save(_notes);
  }

  BoxDecoration get _panel => BoxDecoration(
    color: _paper,
    border: Border.all(color: Colors.black, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(buttonSize: 35),
        backgroundColor: const Color.fromRGBO(255, 237, 95, 1.0),
        title: const Text(
          "Notes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
            color: Colors.black,
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: _panel,
              child: ListView(
                padding: const EdgeInsets.all(6),
                children: [
                  for (var i = 0; i < _notes.length; i++)
                    _NoteTile(
                      note: _notes[i],
                      selected: i == _selected,
                      onTap: () => setState(() => _selected = i),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: _panel,
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          selected == null
                              ? "Please Select Note"
                              : _notes[selected],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(width: 4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _NotesButton(label: "Add Note", onPressed: _addNote),
                          _NotesButton(
                            label: "Delete Note",
                            onPressed: selected == null
                                ? null
                                : _deleteSelectedNote,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? Colors.grey.shade300 : Colors.white,
        shape: const Border.fromBorderSide(BorderSide(width: 2)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesButton extends StatelessWidget {
  const _NotesButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.black,
            disabledForegroundColor: Colors.black38,
            padding: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: FittedBox(child: Text(label)),
        ),
      ),
    );
  }
}

class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final note = _controller.text.trim();
    if (note.isNotEmpty) Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Note"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(onPressed: _submit, child: const Text("Add")),
      ],
    );
  }
}
