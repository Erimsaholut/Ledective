import 'package:flutter/material.dart';
import 'package:ledective/apps/tools/back_button.dart';
import 'package:ledective/data_base/datas.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  DataDepo db = DataDepo();
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
                    ...(db.contacts),
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
                  onPressed: () {},
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

