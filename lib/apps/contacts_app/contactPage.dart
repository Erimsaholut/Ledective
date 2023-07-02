import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class ContactsPage extends StatelessWidget {
  final String name;
  final String number;
  final String? nickName;

  const ContactsPage({
    Key? key,
    required this.name,
    required this.number,
    this.nickName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: Text(name),
        shadowColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.green.shade200),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                height: 100.0,
                color: Colors.white,
                child: Center(child: Text("Name:$name")),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                height: 100.0,
                color: Colors.white,
                child: Center(child: Text("Number:$number")),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                height: 100.0,
                color: Colors.white,
                child:TextButton(
                  onPressed: () {
                    showPlatformDialog(
                      context: context,
                      builder: (context) => BasicDialogAlert(
                        title: const Text("Error"),
                        content:
                        const Text("You can't delete this contact."),
                        actions: <Widget>[
                          BasicDialogAction(
                            title: const Text("Okay"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color?>(
                      Colors.blue.withOpacity(0.1), // Silik mavi efekt
                    ),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.black, // Yazı rengi siyah
                    ),
                  ),
                ),
              ),],
          ),
        ),
      ),
    );
  }
}
