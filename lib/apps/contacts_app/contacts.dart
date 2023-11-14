import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ledective/apps/contacts_app/contactsWidget.dart';

import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

import '../../widgets/back_button.dart';


class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  int contactNumber = 1;
  List<dynamic> datalar = [];
  List<Widget> contactWidgets = [];

  Future<void> loadJson() async {
    print("loadladık");
    String jsonData = await rootBundle.loadString("assets/contacts/contacts.json");
    Map<String, dynamic> data = json.decode(jsonData);
    datalar = data['contacts'];
  }

  void printJsonMassage(String id) async {
    print(id);
    dynamic item = datalar.firstWhere((item) => item['kod'] == id, orElse: () => null);
    if (item != null) {
      setState(() {
        contactWidgets.add(
            ContactWidget(number: item['number'],person: item['name'],));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadJson().then((_) {
      for (var _ in datalar) {
        printJsonMassage("C$contactNumber");
        contactNumber++;
      }
    });
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newNumber = "";
        String newName = "";
        return AlertDialog(
          title: const Text("Add Contact"),
          content: Column(
            children: [
              const Text("Name"),
              TextField(
                onChanged: (abc) {
                  newName = abc;

                },
              ),
              const SizedBox(height: 30,),
              const Text("Number"),
              TextField(
                onChanged: (value) {
                  newNumber = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if(newName.isNotEmpty && newNumber.isNotEmpty){
                  setState(() {
                    String newCode = "C$contactNumber";
                    contactNumber++;
                    Map<String, dynamic> newNoteData = {
                      "name": newName,
                      "number": newNumber,
                      "kod": newCode,
                    };
                    datalar.add(newNoteData);

                    contactWidgets.add(
                      ContactWidget(
                        person: newName,
                        number: newNumber,
                      ),
                    );
                  });

                  _saveJson();
                }


                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),

          ],
        );
      },
    );
  }

  Future<void> _saveJson() async {
    Map<String, dynamic> jsonData = {
      "contacts": datalar,
    };
    String jsonString = json.encode(jsonData);

    final file = await File("/../../../assets/contacts/contacts.json").writeAsString(jsonString);
    ///                      Ledective/lib/apps/contacts_app/contactPage.dart
    ///                      Ledective/assets/contacts/contacts.json
    ///                      ../../../../assets/contacts/contacts.json
    //todo almıyor amına koyduğumun pathlerini
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contacts"),
        leading: const SizedBox(),
        backgroundColor: Colors.green.shade200,
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green.shade200,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ...contactWidgets,
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade200.withOpacity(1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const BackButtonWidget(
                  colour: Colors.white,
                  buttonSize: 40,
                ),
                TextButton(
                  onPressed: () {
                    //todo contact ekleme kısmı buraya
                    _showAddContactDialog();
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

