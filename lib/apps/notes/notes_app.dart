import 'package:flutter/material.dart';

import '../../data/notes_repository.dart';
import '../../theme/app_theme.dart';

const _notesAccent = Color(0xFFE0A800);

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final NotesRepository _repository = NotesRepository();
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _repository.load().then((notes) {
      if (mounted) setState(() => _notes = notes);
    });
  }

  Future<void> _save() => _repository.save(_notes);

  /// Opens the editor for note [index], or for a new note when null.
  Future<void> _edit(int? index) async {
    final text = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (_) =>
            _NoteEditor(initialText: index == null ? '' : _notes[index]),
      ),
    );
    if (text == null) return;
    setState(() {
      final notes = [..._notes];
      if (text.trim().isEmpty) {
        if (index != null) notes.removeAt(index);
      } else if (index == null) {
        notes.add(text);
      } else {
        notes[index] = text;
      }
      _notes = notes;
    });
    await _save();
  }

  Future<void> _delete(int index) async {
    setState(() => _notes = [..._notes]..removeAt(index));
    await _save();
  }

  static String _title(String note) => note.trim().split('\n').first;

  static String _preview(String note) {
    final lines = note.trim().split('\n');
    return lines.length > 1 ? lines.skip(1).join(' ') : 'Ek metin yok';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text("Notes")),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      if (_notes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Not yok",
                            style: TextStyle(color: AppColors.secondaryLabel),
                          ),
                        ),
                      for (var i = _notes.length - 1; i >= 0; i--) ...[
                        Dismissible(
                          key: ObjectKey((i, _notes[i])),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _delete(i),
                          background: Container(
                            color: AppColors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              _title(_notes[i]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _preview(_notes[i]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _edit(i),
                          ),
                        ),
                        if (i > 0) const Divider(indent: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Spacer(),
              Text(
                "${_notes.length} Not",
                style: const TextStyle(fontSize: 12, color: AppColors.label),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  heightFactor: 1,
                  child: IconButton(
                    tooltip: "Add Note",
                    onPressed: () => _edit(null),
                    icon: const Icon(Icons.edit_square, color: _notesAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A full-screen note editor. Pops with the edited text.
class _NoteEditor extends StatefulWidget {
  const _NoteEditor({required this.initialText});

  final String initialText;

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return PopScope<String>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: _notesAccent,
          leading: IconButton(
            tooltip: "Notes",
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _done,
          ),
          actions: [
            TextButton(
              onPressed: _done,
              child: const Text(
                "Done",
                style: TextStyle(
                  color: _notesAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _controller,
            autofocus: widget.initialText.isEmpty,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            cursorColor: _notesAccent,
            style: const TextStyle(fontSize: 17, height: 1.4),
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              hintText: "Not",
            ),
          ),
        ),
      ),
    );
  }
}
