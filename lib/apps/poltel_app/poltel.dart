import 'package:flutter/material.dart';
import 'document_maker.dart';

List<String> sorular = [
  "Berat'ı nereden tanıyorsun ve onu nasıl tarif edersin ?",
  "Kendisine zarar verebilecek birilerinden veya peşinde olan birilerinden bahsetti mi ?",
  "Daha önce şüpheli bir olaya karıştığını gördün  veya duydun mu ?"
];

List<String> cevaplar = [
  " Berat'ı fazla yakından olmamakla"
      " birlikte okuldan tanıyorum. Kendisi sanırım babasından dolayı biraz burnu havada biriydi. Zaten babası milletvekili olan birinin neden bu küçük şehirdeki, küçük bir üniversitede okuduğunu hiçbir zaman  anlayamadım. Okula fazla gelip gitmezdi, geldiği zamanlarda da benimle beraber kahve içerdi. Genellikle kendine güvenen ve insanları küçük gören bir konuşm"
      "a tarzı vardı.",
  "Hayır, peşinde birilerinin olduğunu sanmıyorum.",
  "Daha önce okulda yaşanan bir olay olmadı ama birkaç a"
      "y önce madde kullandığı bilinen bir öğrenciye ufak bir "
      "paket verirken yere düşürdüğünü görenler olmuş. Ben görmedim ama oradan geç"
      "en birkaç kişi gördüğünü söylüyor. Herkesin aklına aynı şey geldi ama kimse okuldan atılmak istemediği için üzerine gitmedi bu olayın",
];


class Poltel extends StatefulWidget {
  const Poltel({Key? key}) : super(key: key);

  @override
  State<Poltel> createState() => _PoltelState();
}


class _PoltelState extends State<Poltel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("Poltel"),
      ),
      body: Container(
        color: Colors.tealAccent,
        child: SingleChildScrollView(
          child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentMaker(
                      name: "John Doe",
                      number: "123456789",
                      madeDate: "01.01.2022",
                      education: "High School",
                      isMarried: "Married",
                      gender: "Male",
                      questions: sorular,
                      answers: cevaplar,
                    ),

                  ),
                );
              },
              child: Text("aaa")),
        ),
      ),
    );
  }
}
