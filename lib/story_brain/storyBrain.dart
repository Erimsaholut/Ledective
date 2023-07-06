import '../apps/Tools/incoming_message.dart';
import '../apps/Tools/outcoming_message.dart';

checkAnswer(int number, String person, List chatList) async {
  if (number == 1) {
    /* AGRESİF CEVAP */
    chatList.add(const OutgoingMessage(message: "Agresif cevap"));

    chatList.add(const IncomingMessage(message: "Gerçekten özür dilerim amirim ama ciddi bir olay olmasa sizi rahatsız etmezdim"));

  } else if (number == 2) {
    /* MERAKLI CEVAP */
    chatList.add(const OutgoingMessage(message: "Meraklı Cevap"));

    chatList.add(const IncomingMessage(message: "Amirim maktülün evinde boğuşma izleri var, olay yeri ekibi inceliyor"));

  } else {
    /* BAŞINDAN SAV */
    chatList.add(const OutgoingMessage(message: "Başından sav"));

    chatList.add(const IncomingMessage(message: "Amirim lütfen biraz ciddi olun, durum gerçekten kötü"));
  }
}
