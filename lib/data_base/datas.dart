import 'package:flutter/material.dart';
import '../apps/Tools/incoming_message.dart';
import '../apps/Tools/outcoming_message.dart';
import '../apps/matesApp_app/mates_massage.dart';
import '../apps/photos_app/photo_widget.dart';


class DataDepo {
  List<Widget> matesMessages = [ //todo Kişi isimlerini buradan çekiyor bunu yerine contactlardan çeksin
    const MatesMessage(
      person: "Hayalet",
    ),
    const MatesMessage(person: "Akbaba"),
    const MatesMessage(
        person: "Ercüment"),
    const MatesMessage(person: "Tahsin"),
    const MatesMessage(person: "Harun"),
    const MatesMessage(person: "Eda"),
    const MatesMessage(person: "Selim"),
  ];

  Map<String, List<Widget>> matesAppMessages = {
    "Özge": [
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



  List<Widget> recents = [
    const MatesMessage(
      person: "Hayalet",
      number: "0530303030",
    ),
    const MatesMessage(
      person: "Harun",
      number: "0303033003",
    ),
  ];



}

