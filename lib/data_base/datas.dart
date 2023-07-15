import 'package:flutter/material.dart';
import 'package:ledective/apps/Tools/outcoming_message.dart';
import 'package:ledective/apps/contacts_app/contactsWidget.dart';
import 'package:ledective/apps/tools/dayPassed.dart';
import '../apps/Tools/incoming_message.dart';
import '../apps/mail_app/mail_container.dart';
import '../apps/photos_app/photo_widget.dart';

class DataDepo {
  /*Buraya başta yazacak oyun öncesi muhabbetleri ekle*/
  Map<String, List<Widget>> matesAppFirstMessages = {
    "Özge": [
      const DayPassed(day:8),
      const IncomingMessage(
          message: "İyi akşamlar amirim istediğiniz raporları müdüre ilettim."),
      const OutgoingMessage(message: "Aferin kızım"),
      const DayPassed(day:5),
      const IncomingMessage(
          message:
              "Palu cinayeti için savcılıkta imza vermeniz gerekiyormuş amirim."),
      const OutgoingMessage(message: "Atakanı yolla, atıversin benim yerime"),
      const IncomingMessage(message: "Atakan izinli amirim Orhuna haber verdim"),
      const OutgoingMessage(message: "ok"),
      const DayPassed(),
      const IncomingMessage(message: "Amirim yardımınızı gerektiren büyük bir cinayet olayı oldu. Büro olarak işin içinde çıkamadık."),
    ],
    "Orhun": [
      const DayPassed(day: 5),
      const IncomingMessage(message: "İmza işini hallettim amirim."),
      const OutgoingMessage(message: "tmmdır"),
      const DayPassed(),
      const IncomingMessage(message: "Akşama iki bira ok ?"),
    ],
    "Behram":[
      const DayPassed(customText: "10 Nisan"),
      const IncomingMessage(message: "Tüm polis teşkilatımızın polis haftası kutlu olsun."),
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
    const PhotoWidget(
        adress: 'assets/apps/photosApp/images/freeMason.jpg'),//todo sen gene de bunu kaldır telif melif oluryerine gizmli bişi ekle

    // freeMason.jpg
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
