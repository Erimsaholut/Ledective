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
            "Amirim maktül domuz bağı ile öldürülmüş ve her yanında soğanlar var. Ayrıca evdeki bütün ampüller patlamış",
        delaySec: 2,
      ));
    } else {
      /* BAŞINDAN SAV */
      chatList.add(const OutgoingMessage(message: "Başından sav"));

      chatList.add(const IncomingMessage(
          delaySec: 1,
          message:
              "Ehhh senle mi uğraşıcaz lan sabah akşam. Bir gün ayık gelmez işe, her gün başkasıyla kavga eder uğraştırır devlete zarardan başka bir şey değilsin amına koyduğum"));
    }



  }
  if (person == "Orhun") {
    if (number == 1) {
      /* AGRESİF CEVAP */
      chatList.add(const OutgoingMessage(message: "Orhun bak Özgeyi sikmek istediğim için cevap verirum sen de tatava yapıp sinirimi bozma benim"));
      chatList.add(const IncomingMessage(
          delaySec: 2,
          message:
              "Amirim ayıp oluyor ama "));
    } else if (number == 2) {
      /* MERAKLI CEVAP */
      chatList.add(const OutgoingMessage(message: "Meraklı Cevap"));

      chatList.add(const IncomingMessage(
        message:
            "Amirim maktül domuz bağı ile öldürülmüş ve her yanında soğanlar var. Ayrıca evdeki bütün ampüller patlamış",
        delaySec: 2,
      ));
    } else {
      /* BAŞINDAN SAV */
      chatList.add(const OutgoingMessage(message: "Başından sav"));

      chatList.add(const IncomingMessage(
          delaySec: 2,
          message:
              "Ehhh senle mi uğraşıcaz lan sabah akşam. Bir gün ayık gelmez işe, her gün başkasıyla kavga eder uğraştırır devlete zarardan başka bir şey değilsin amına koyduğum"));
    }
  }
}
