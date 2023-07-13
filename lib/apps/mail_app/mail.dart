import 'package:flutter/material.dart';
import 'package:ledective/data_base/datas.dart';
import 'package:ledective/apps/tools/back_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MailApp extends StatefulWidget {
  const MailApp({Key? key}) : super(key: key);

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  List<Widget> mails = DataDepo().mails;
  List<Widget> myMails = [];
  int mailCount = 3;

  @override
  void initState() {
    super.initState();
    myMails = mails.take(mailCount).toList();
    _getMailCountFromSharedPreferences();
    /* mail sayısını değiştirmek için mailCount değerini alabilirsin burada*/
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
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _addMail(); // mail ekleme fonksiyonunu çağır
                      });
                    },
                    child: const Icon(
                      Icons.mail,
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
                ...myMails,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addMail() {
    if (mailCount < mails.length) {
      mailCount += 1;
      myMails = mails.take(mailCount).toList();
      _saveMailCountToSharedPreferences(mailCount); // shared_preferences'a mailCount değerini kaydet
    }
  }

  Future<void> _saveMailCountToSharedPreferences(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mailCount', count);
  }

  Future<void> _getMailCountFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? count = prefs.getInt('mailCount');
    if (count != null) {
      setState(() {
        mailCount = count;
        myMails = mails.take(mailCount).toList();
      });
    }
  }
}


