import 'package:flutter/material.dart';

import 'document_maker.dart';
import 'document_texts.dart';

class PolDocument extends StatelessWidget {
  final String name;
  final bool visible;
  final bool isAutopsy;

  const PolDocument({
    Key? key,
    required this.name,
    this.visible = true,
    this.isAutopsy = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.black, width: 3.0),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isAutopsy == false
                        ? DocumentMaker(
                            name: documentTexts[name]["name"],
                            number: documentTexts[name]["number"],
                            madeDate: documentTexts[name]["madeDate"],
                            education: documentTexts[name]["education"],
                            isMarried: documentTexts[name]["isMarried"],
                            gender: documentTexts[name]["gender"],
                            questions: documentTexts[name]["questions"],
                            answers: documentTexts[name]["answers"],
                          )
                        : autopsyRaport(),
                  ),
                );
              },
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

Widget autopsyRaport() {
  return Scaffold(
    appBar: AppBar(title: const Text(" Berat Yılmaz otopsi raporu ")),
    body: Container(
      width: double.infinity,
      color: Colors.grey.shade400,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...otopsi],
            ),
          ),
        ],
      ),
    ),
  );
}
