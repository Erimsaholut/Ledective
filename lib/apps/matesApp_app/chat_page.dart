import 'package:flutter/material.dart';
import 'package:ledective/data_base/datas.dart';
import '../../story_brain/storyBrain.dart';

class MatesChatPAGE extends StatefulWidget {
  final String person;

  const MatesChatPAGE({Key? key, required this.person})
      : super(key: key);

  @override
  _MatesChatPAGEState createState() => _MatesChatPAGEState();
}

class _MatesChatPAGEState extends State<MatesChatPAGE> {
  DataDepo db = DataDepo();
  bool isKeyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> personMessages = db.matesAppFirstMessages[widget.person] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person),
        backgroundColor: Colors.green,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
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
                  child: ListView(
                    children: [
                      ...(personMessages),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isKeyboardVisible = !isKeyboardVisible;
                  });
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
                          isKeyboardVisible?"Close Keyboard":"Send Message",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.black.withOpacity(0.5)),
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
                            onPressed: () {
                              setState(() {
                                print(widget.person);
                                print(personMessages);
                                checkAnswer(1, widget.person, personMessages);

                              });
                            },
                            child: const Center(
                              child: Text(
                                "Choice 1",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                checkAnswer(2,widget.person,personMessages);
                              });
                            },
                            child: const Center(
                              child: Text(
                                "Choice 2",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                checkAnswer(3,widget.person,personMessages);
                              });
                            },
                            child: const Center(
                              child: Text(
                                "Choice 3",
                                style: TextStyle(color: Colors.black),
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
      ),
    );
  }
}

