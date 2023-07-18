import 'package:flutter/material.dart';

class DocumentMaker extends StatelessWidget {
  final String type;
  final String name;
  final String number;
  final String madeDate;
  final String education;
  final String isMarried;
  final String gender;
  final List<String> questions;
  final List<String> answers;

  const DocumentMaker({
    Key? key,
    this.type = "İfade Tutanağı",
    required this.name,
    required this.number,
    required this.madeDate,
    required this.education,
    required this.isMarried,
    required this.gender,
    required this.questions,
    required this.answers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$name $type"),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.grey.shade400,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: statementRaport(),
            ),
          ],
        ),
      ),
    );
  }

  Column statementRaport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "İfade verenin kimliği :\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("\t Adı ve soyadı:\t$name"),
        Text("\t Kimlik numarası:\t$number"),
        Text("\t İfadenin alındığı tarih:\t$madeDate"),
        Text("\t Medeni Hali - Cinsiyeti:\t$isMarried - $gender"),
        const Text(
          "\n Sanığın ifadesi :\n",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        for (int i = 0; i < questions.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "\t Soruldu :\t",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          questions[i],
                        ),
                        const Text("\n"),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "\t Cevap:\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(answers[i]),
                        const Text("\n\n"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
