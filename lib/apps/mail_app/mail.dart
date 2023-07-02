import 'package:flutter/material.dart';
import 'package:ledective/apps/tools/back_button.dart';
import 'package:ledective/data_base/datas.dart';

class MailApp extends StatefulWidget {
  const MailApp({Key? key}) : super(key: key);

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  DataDepo db = DataDepo();

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
                ...(db.mailMessages),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
