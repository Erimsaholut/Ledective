import 'package:flutter/material.dart';
import 'package:ledective/apps/notes_app/notes_container.dart';
import 'package:ledective/apps/tools/back_button.dart';

class NotesApp extends StatefulWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  String currentNote = "Please Select Note";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonWidget(
          buttonSize: 35,
        ),
        backgroundColor: const Color.fromRGBO(255, 237, 95, 1.0),
        title: const Text(
          "Notes",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 35, color: Colors.black),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 252, 121, 1.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: ListView(
                  children: [
                    NotesContainer(
                      initialValue: currentNote,
                      myNote: "Behzat ç bir ankara polisiyesidir ve dünya dizi tarihinin gelmiş geçmiş en büyük yapımıdır...",
                      onChanged: (newNote) {
                        setState(() {
                          currentNote = newNote;
                        });
                      },
                    ),
                    NotesContainer(
                      initialValue: currentNote,
                      myNote: "Baba Naber",
                      onChanged: (newNote) {
                        setState(() {
                          currentNote = newNote;
                        });
                      },
                    ),
                    NotesContainer(
                      initialValue: currentNote,
                      myNote: "Sevgili Günlük",
                      onChanged: (newNote) {
                        setState(() {
                          currentNote = newNote;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 252, 121, 1.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(currentNote),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey),
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "   Add Note  ",
                                        style: TextStyle(color: Colors.black),
                                      )),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey),
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        "Delete Note",
                                        style: TextStyle(color: Colors.black),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ))
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
