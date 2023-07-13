import '../apps/Tools/incoming_message.dart';
import '../apps/Tools/outcoming_message.dart';

//TODO OBJECTİVE NEDİR BURASI KARAR MERCİ OLACAK VE BURADAKİ APP MASSAGES KISMINDAN GEREKLİ DOSYALARI GÖNDERECEK.

checkAnswer(int number, String person, List chatList) async {
  if (person == "Özge") {
    if (number == 1) {
      /* AGRESİF CEVAP */
      chatList.add(const OutgoingMessage(message: "Agresif cevap"));

      chatList.add(const IncomingMessage(
          delaySec: 2,
          message:
              "Gerçekten özür dilerim amirim ama ciddi bir olay olmasa sizi rahatsız etmezdim"));
    } else if (number == 2) {
      /* MERAKLI CEVAP */
      chatList.add(const OutgoingMessage(message: "Meraklı Cevap"));

      chatList.add(const IncomingMessage(
        message:
            "Amirim maktülün evinde boğuşma izleri var, olay yeri ekibi inceliyor",
        delaySec: 2,
      ));
    } else {
      /* BAŞINDAN SAV */
      chatList.add(const OutgoingMessage(message: "Başından sav"));

      chatList.add(const IncomingMessage(
          delaySec: 2,
          message:
              "Amirim lütfen biraz ciddi olun, durum gerçekten kötü"));
    }



  }
  if (person == "Orhun") {
    if (number == 1) {
      /* AGRESİF CEVAP */
      chatList.add(const OutgoingMessage(message: "Orhun bak sırf Özge rica etti diye cevap veriyorum, sinirimi bozma benim"));
      chatList.add(const IncomingMessage(
          delaySec: 2,
          message:
              "Amirim ayıp oluyor ama "));
    } else if (number == 2) {
      /* MERAKLI CEVAP */
      chatList.add(const OutgoingMessage(message: "Meraklı Cevap"));

      chatList.add(const IncomingMessage(
        message:
            "Amirim maktülün evinde boğuşma izleri var, olay yeri ekibi inceliyor",
        delaySec: 2,
      ));
    } else {
      /* BAŞINDAN SAV */
      chatList.add(const OutgoingMessage(message: "Başından sav"));

      chatList.add(const IncomingMessage(
          delaySec: 2,
          message:
              "Amirim lütfen biraz ciddi olun, durum gerçekten kötü"));
    }
  }
}
