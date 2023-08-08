import 'package:flutter/cupertino.dart';
import '../../../apps/Tools/incoming_message.dart';
import '../../../apps/Tools/outcoming_message.dart';

/* storyBrain'in cevapları buradan alması lazım*/

Map<String, List<Widget>> S0ozgeAppMessages = {
"0": [
const IncomingMessage(
message: "Amirim çok özür dilerim ama gerçekten ciddi bir olay",delaySec: 1),
],
  "1": [
    const IncomingMessage(
        message:
            "Amirim şu an yurtdışında olduğunuzu biliyorum ama yardımınızı gerektiren önemli bir durum var",delaySec: 1),
  ],
  "2": [
    const IncomingMessage(
        message:
            "3 gün önce akşam saatlerinde bir üniversite öğrencisinin kendini astığı ihbarı geldi. Olay yeri incelemesi ve"
            " otopsiden sonra olayın cinayet olduğu açığa çıktı. Maktül öldükten sonra asılmış ve her yerinde boğuşma izleri var",delaySec: 1),
    const IncomingMessage(
        message:
            "Olaydan haberimiz olduktan yarım saat sonra şube müdürümüzden bir telefon geldi. Kendisini de il emniyet müdürü aramış."
            " Maktulün bir milletvekilinin oğlu olduğunu ve diğer davaları askıya alıp hepimizin bu davaya odaklanması söyledi.",delaySec: 1),
    const IncomingMessage(
        message: "Size de ulaşmaya çalışmış ama telefonunuz kapalıymış",delaySec: 1),
  ],
  "3.1": [
    const IncomingMessage(
        message:
            "Atakan'la Doğa maktülün yakın arkadaşının ve cesedi bulan kişinin ifadesini aldılar ama görünüşe göre fazla arkadaşı yokmuş."),
  ],
  "3.2": [
    const IncomingMessage(
        message:
            "Borç meselesi yüzünden çıkan kavgada ölen adamın davasını askıya aldık ama sadece evrak işleri kalmıştı. Boş kaldığım bir zamanda hallederim ben onu."),
  ],
  "3.3": [
    const IncomingMessage(
        message:
            "Anladım amirim. Atakan'la Doğa maktülün yakın arkadaşının ifadesini aldılar. Onları size \"poltel\" üzerinden gönderiyorum"),
  ],
  "4": [
    const IncomingMessage(message: "Hemen gönderiyorum amirim."),
  ],
};

Map<String, List<Widget>> S0userAppMessages = {
  "0": [
    const OutgoingMessage(
        message: "Kızım ben size izindeyken bana yazmayın demedim mi ? "),
  ],
  "1": [
    const OutgoingMessage(
        message: "Neymiş bu kadar önemli olan durum"),
  ],
  "2": [
    const OutgoingMessage(
        message:
        "3 gün önce akşam saatlerinde bir üniversite öğrencisinin kendini astığı ihbarı geldi. Olay yeri incelemesi ve"
            " otopsiden sonra olayın cinayet olduğu açığa çıktı. Maktül öldükten sonra asılmış ve her yerinde boğuşma izleri var"),
  ],
  "3.1": [
    const OutgoingMessage(
        message:
        "Yakınlarının ifadesini aldınız mı ?"),
  ],
  "3.2": [
    const OutgoingMessage(
        message:
        "Hangi davaları askıya aldınız ?"),
  ],
  "3.3": [
    const OutgoingMessage(
        message:
        "Kapalı değildi erdiyi engelledim ben "),
  ],
  "4": [
    const OutgoingMessage(message: "İfadeleri bana poltel üzerinden gönder"),
  ],
};
