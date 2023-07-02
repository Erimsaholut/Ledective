import 'package:flutter/material.dart';
import 'package:ledective/apps/tools/back_button.dart';
import 'package:ledective/data_base/datas.dart';
import 'new_message_page.dart';

class MatesApp extends StatefulWidget {
  const MatesApp({Key? key}) : super(key: key);

  @override
  State<MatesApp> createState() => _MatesAppState();
}

class _MatesAppState extends State<MatesApp> {

  void _newMessagePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewMessagePage(),
      ),
    );
  }
  DataDepo db = DataDepo();
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
                    ...(db.matesMessages),
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

