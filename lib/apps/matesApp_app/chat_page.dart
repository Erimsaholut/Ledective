import 'package:flutter/material.dart';
import 'package:ledective/apps/Tools/incoming_message.dart';
import 'package:ledective/data_base/datas.dart';

class MatesChatPAGE extends StatefulWidget {
  final String message;
  final String person;

  MatesChatPAGE({Key? key, required this.message, required this.person})
      : super(key: key);

  @override
  _MatesChatPAGEState createState() => _MatesChatPAGEState();
}

class _MatesChatPAGEState extends State<MatesChatPAGE> {
  DataDepo db = DataDepo();

  @override
  Widget build(BuildContext context) {
    List<Widget> personMessages = db.matesAppMessages[widget.person] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person),
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              IncomingMessage(message: widget.message),
              ...(personMessages),
            ],
          ),
        ),
      ),
    );
  }
}
