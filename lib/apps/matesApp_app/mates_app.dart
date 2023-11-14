import 'package:flutter/material.dart';
import 'package:ledective/apps/matesApp_app/mates_massage.dart';
import '../../widgets/back_button.dart';
import 'new_message_page.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class MatesApp extends StatefulWidget {
  const MatesApp({Key? key}) : super(key: key);

  @override
  State<MatesApp> createState() => _MatesAppState();
}

class _MatesAppState extends State<MatesApp> {
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
            MatesMessage(number: item['number'],person: item['name']));
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

  void _newMessagePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewMessagePage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MatesApp"),
        leading: const SizedBox(),
        backgroundColor: Colors.green.shade700,
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.green,
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
              color: Colors.green.shade700.withOpacity(1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const BackButtonWidget(
                  colour: Colors.white,
                  buttonSize: 40,
                ),
                TextButton(
                  onPressed: _newMessagePage,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                TextButton(
                  onPressed: () async {

                  },
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 40,
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