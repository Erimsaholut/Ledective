import 'package:flutter/material.dart';
import 'package:ledective/apps/mail_app/mail_container.dart';
import 'package:ledective/apps/tools/back_button.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

class MailApp extends StatefulWidget {
  const MailApp({Key? key}) : super(key: key);

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  int mailNumber = 1;
  List<dynamic> datalar = [];
  List<Widget> mailWidgets = [];

  Future<void> loadJson() async {
    print("loadladık");
    String jsonData = await rootBundle.loadString("assets/apps/mailApp/mails.json");
    Map<String, dynamic> data = json.decode(jsonData);
    datalar = data['mails'];
  }

  void printJsonMassage(String id) async {
    print(id);
    dynamic item = datalar.firstWhere((item) => item['name'] == id, orElse: () => null);
    if (item != null) {
      String description = item['message'];
      setState(() {
        mailWidgets.add(
          MailContainer(title: item["title"],message: description,));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadJson().then((_) {
      for (var _ in datalar) {
        printJsonMassage("Mail$mailNumber");
        mailNumber++;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.mail, size: 75),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.refresh,
                      size: 75,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.delete,
                      size: 75,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const BackButtonWidget()
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 15),
              children: [
                ...mailWidgets
              ],
            ),
          ),
        ],
      ),
    );
  }
}
