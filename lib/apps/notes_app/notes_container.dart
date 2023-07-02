import 'package:flutter/material.dart';

class NotesContainer extends StatefulWidget {
  final String initialValue;
  final String myNote;
  final ValueChanged<String> onChanged;

  const NotesContainer({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    this.myNote = "Yeni Not",
  }) : super(key: key);

  @override
  State<NotesContainer> createState() => _NotesContainerState();
}

class _NotesContainerState extends State<NotesContainer> {
  late String text;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    text = widget.initialValue;
    _textEditingController = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showEditDialog(context);
      },
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                text = widget.myNote;
                widget.onChanged(text);
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              padding: MaterialStateProperty.all(EdgeInsets.zero),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 2),
                  ),
                  child: Center(
                    child: Text(
                      "${widget.myNote.substring(0, 6)}...",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notu Düzenle'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: 'Not'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Kaydet'),
              onPressed: () {
                String newNote = _textEditingController.text;
                widget.onChanged(newNote);

                setState(() {
                  text = newNote;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
