import 'package:flutter/material.dart';
import '../apps/Tools/incoming_message.dart';
import '../apps/Tools/outcoming_message.dart';
import '../apps/matesApp_app/mates_massage.dart';
import '../apps/mail_app/mail_container.dart';
import '../apps/photos_app/photo_widget.dart';


class DataDepo {
  List<Widget> matesMessages = [ //todo buraya komple bir ayarlama gelecek mesjaları sohbetten çekmesi lazım
    const MatesMessage(
      message: "Amirim maktulü çok kötü bir halde bulduk",
      person: "Hayalet",
    ),
    const MatesMessage(message: "Eleman yakalandı", person: "Akbaba"),
    const MatesMessage(
        message: "Behzo yarın büroda görüşelim", person: "Ercüment"),
    const MatesMessage(message: "Çabuk büroya gel", person: "Tahsin"),
    const MatesMessage(message: "Amirim ben bir hata yaptım", person: "Harun"),
    const MatesMessage(message: "Amirim Harun Selimi yedi", person: "Eda"),
    const MatesMessage(message: "Tamam", person: "Selim"),
  ];

  Map<String, List<Widget>> matesAppMessages = {
    "hayalet": [
      const OutgoingMessage(message: "Nasıl yani"),
      const IncomingMessage(message: "Walla"),
      const OutgoingMessage(message: "Hay aksi"),
      const OutgoingMessage(
        message:
        "Hayalet bu işi bir an önce çözmemiz lazım",
      ),
      const IncomingMessage(message: "Özür dilerim 😭"),
    ],
    "akbaba": [
      const OutgoingMessage(message: "Baya baya yemiş mi"),
      const IncomingMessage(message: "Baya baya yemiş amirim"),
      const OutgoingMessage(message: "Hay aksi"),
      const OutgoingMessage(
        message:
        "Bu işi düzgün yapmazsan büroya gelip seninle konuşacağım",
      ),
      const IncomingMessage(message: "Özür dilerim"),
    ],
    "ercument": [
      const OutgoingMessage(message: "Nasıl yani"),
      const IncomingMessage(message: "Walla"),
      const OutgoingMessage(message: "Hay aksi"),
      const OutgoingMessage(
        message:
        "Hayalet bu işi bir an önce çözmemiz lazım",
      ),
      const IncomingMessage(message: "Özür dilerim 😭"),
    ],
    "harun": [
      const OutgoingMessage(message: "Nasıl yani"),
      const IncomingMessage(message: "Walla"),
      const OutgoingMessage(message: "Hay aksi"),
      const OutgoingMessage(
        message:
        "Hayalet bu işi bir an önce çözmemiz lazım",
      ),
      const IncomingMessage(message: "Özür dilerim 😭"),
    ],
  };

  List<Widget> galleryImages = [
    const PhotoWidget(adress: 'assets/apps/photosApp/images/1500x500.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/my_foto2.jpg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/my_foto4.jpg',scale: 1),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/myCat.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/benumit.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/kadr.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/kadr2.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/benKedi.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/my_foto1.jpg',scale: 0.6),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/gungun.jpeg'),
    const PhotoWidget(adress: 'assets/apps/photosApp/images/babba.jpeg',scale: 0.9),
  ];

  List<Widget> contacts = [
    const MatesMessage(
      person: "Hayalet",
      number: "0535 031 53 53",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Harun",
      number: "0535 035 53 53",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Akbaba",
      number: "0535 035 53 53",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Tahsin Müdür",
      number: "0238 010 67 67",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Eda",
      number: "0538 010 67 87",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Selim",
      number: "0538 010 77 67",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Şule",
      number: "0538 110 67 67",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Jale",
      number: "0538 011 67 67",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Berna",
      number: "0538 011 67 67",
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Selma",
      isContactsMode: false,
    ),
  ];

  List<Widget> recents = [
    const MatesMessage(
      person: "Hayalet",
      number: "0530303030",
      icon: Icons.call_end,
      isContactsMode: false,
    ),
    const MatesMessage(
      person: "Harun",
      number: "0303033003",
      isContactsMode: false,
    ),
  ];



}

