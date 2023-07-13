import 'package:flutter/material.dart';
import 'package:ledective/apps/contacts_app/contactsWidget.dart';
import '../apps/Tools/incoming_message.dart';
import '../apps/mail_app/mail_container.dart';
import '../apps/photos_app/photo_widget.dart';

class DataDepo {
  Map<String, List<Widget>> matesAppMessages = {
    "Özge": [
      const IncomingMessage(
          message:
              "Şu an ulusal konferans için yurtdışında olduğunuzu biliyorum ama yardımınızı gerektiren bir durum var"),
    ],
  };

  List<Widget> galleryImages = [
    const PhotoWidget(adress: 'assets/apps/photosApp/images/1500x500.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/my_foto2.jpg'),
    const PhotoWidget(
        adress: 'assets/apps/photosApp/images/my_foto4.jpg', scale: 1),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/myCat.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/benumit.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/kadr.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/kadr2.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/benKedi.jpeg'),
    const PhotoWidget(
        adress: 'assets/apps/photosApp/images/my_foto1.jpg', scale: 0.6),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/gungun.jpeg'),
    const PhotoWidget(
        adress: 'assets/apps/photosApp/images/babba.jpeg', scale: 0.9),
  ];

  List<Widget> recents = [
    const ContactWidget(
      person: "Hayalet",
      number: "0530303030",
    ),
    const ContactWidget(
      person: "Harun",
      number: "0303033003",
    ),
  ];

  List<Widget> mails = [
    const MailContainer(
      title: "emniyet.gov.tr",
      message: "Konferansa davetlisiniz !",
    ),
    const MailContainer(
        title: "zaferbank.com",
        message:
            "Paranızı tanımdağınız milyonlarca kişi ile paylaştığınızın farkında mısınız ?"),
    const MailContainer(
        title: "besiktas.com",
        message: "Yeni sezon formalarda indirim. Sakın kaçırmayın"),
    const MailContainer(title: "xnxy.com", message: "SPAM MAIL !"),
    const MailContainer(
        title: "cexape.com",
        message: "Mansur aday olsa kürtler oy vermezdi ğğğğğ"),
    const MailContainer(
        title: "github.com",
        message:
            "Github aktivasyon kodunuz Æ!>2A4@@X?3_ß4523 girmek için 10 saniyeniz var !!!"),
  ];
}
