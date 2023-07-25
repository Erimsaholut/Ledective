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
  int sm = 0; //todo  bunu ya shared üzerinden ya başka bir yerden al kişiye özel olması gerekiyor.
  //todo uygulama açıldığında önceki mesajları tekrar yazdırması lazım

  Future<void> getSection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    section = prefs.getInt('section')!;
  }

  @override
  void initState() {
    getSection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> personMessages = db.matesAppFirstMessages[widget.person] ?? [];
    List<String> keyboardTexts = ["Choice1","Choice2","Choice3"];

    String setKeyboardText(int num){
      if(keyboardTexts[num].isNotEmpty){
        print(keyboardTexts[num]);
        return keyboardTexts[num];
      }else{
        print("null");
        return "Null";
      }
    }

    void scrollToBottom() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

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
                    children: [
                      ...(personMessages),
                    ],
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
            ),/*keyboard text*/
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
                          onPressed: () {
                            setState(() {
                              checkAnswer(1, section, sm, widget.person, personMessages,keyboardTexts);
                              print(keyboardTexts);
                              sm++;
                              scrollToBottom();
                            });
                          },
                          child: Text(
                            setKeyboardText(0),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              checkAnswer(2, section, sm, widget.person, personMessages,keyboardTexts);
                              sm++;
                              scrollToBottom();
                            });
                          },
                          child: Center(
                            child: Text(
                              setKeyboardText(1),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              checkAnswer(3, section, sm, widget.person, personMessages,keyboardTexts);
                              sm++;
                              scrollToBottom();
                              print(sm);
                            });
                          },
                          child: Center(
                            child: Text(
                              setKeyboardText(2),
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
