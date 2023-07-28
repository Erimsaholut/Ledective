import 'package:flutter/material.dart';
import 'package:ledective/data_base/datas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../story_brain/storyBrain.dart';

class MatesChatPAGE extends StatefulWidget {
  final String person;

  const MatesChatPAGE({Key? key, required this.person}) : super(key: key);

  @override
  _MatesChatPAGEState createState() => _MatesChatPAGEState();
}

class _MatesChatPAGEState extends State<MatesChatPAGE> {
  final ScrollController _scrollController = ScrollController();
  bool isKeyboardVisible = false;
  DataDepo db = DataDepo();
  int section = 0;
  int sm = 0;

  List<Widget> personMessages = [];
  List<String> keyboardTexts = ["Kızım tatildeyken iş için yazmayın demedim mi ben size","Neymiş bu kadar önemli olan durum","Deneme"];

  @override
  void initState() {
    super.initState();
    getSection();
    personMessages = db.matesAppFirstMessages[widget.person] ?? [];
  }

  Future<void> getSection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    section = prefs.getInt('section')!;
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String setKeyboardText(int num) {
    return keyboardTexts[num - 1];
  }

  void sendMessage(int num) {
    setState(() {
      checkAnswer(num, section, sm, widget.person, personMessages,setKeyboard);
      sm++;
      scrollToBottom();
      print(sm);
    });
  }

  void setKeyboard(List<String> newList){
    keyboardTexts = newList;
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [...personMessages],
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    isKeyboardVisible = !isKeyboardVisible;
                  });
                  scrollToBottom();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: Center(
                      child: Text(
                        isKeyboardVisible ? "Close Keyboard" : "Send Message",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Visibility(
              visible: isKeyboardVisible,
              child: Expanded(
                flex: 3,
                child: Container(
                  color: Colors.grey,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => sendMessage(1),
                          child: Text(
                            setKeyboardText(1),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => sendMessage(2),
                          child: Center(
                            child: Text(
                              setKeyboardText(2),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => sendMessage(3),
                          child: Center(
                            child: Text(
                              setKeyboardText(3),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
