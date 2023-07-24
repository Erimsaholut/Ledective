import 'package:ledective/story_brain/StoryBrainMatesAppMesages/ozge/ozge.dart';
import '../apps/Tools/incoming_message.dart';
import '../apps/Tools/outcoming_message.dart';

//TODO OBJECTİVE NEDİR BURASI KARAR MERCİ OLACAK VE BURADAKİ APP MASSAGES KISMINDAN GEREKLİ DOSYALARI GÖNDERECEK.

checkAnswer(int number, int section, String person, List chatList) async {
  if (section == 0) {

    if (person == "Özge") {




      if (number == 1) {
        chatList.add(const OutgoingMessage(
            message: "Kızım tatildeyken iş için yazmayın demedim mi ben size"));

        for (int i = 0; i < S0ozgeAppMessages["0"]!.length; i++) {
          chatList.add(S0ozgeAppMessages["0"]![i]);
        }
      }



      else if (number == 2) {
        chatList.add(const OutgoingMessage(
            message: "Neymiş bu kadar önemli olan durum"));

        for (int i = 0; i < S0ozgeAppMessages["2"]!.length; i++) {
          chatList.add(S0ozgeAppMessages["2"]![i]);
        }
      }



      else {
        chatList.add(const OutgoingMessage(
            message: "Yakınlarının ifadesini aldınız mı ?"));

        for (int i = 0; i < S0ozgeAppMessages["3.1"]!.length; i++) {
          chatList.add(S0ozgeAppMessages["3.1"]![i]);
        }
      }



    }


















    if (person == "Orhun") {
      if (number == 1) {
        chatList.add(const OutgoingMessage(
            message:
                "Orhun bak Özgeyi sikmek istediğim için cevap verirum sen de tatava yapıp sinirimi bozma benim"));
        chatList.add(const IncomingMessage(
            delaySec: 1, message: "Amirim ayıp oluyor ama "));
      } else if (number == 2) {
        chatList.add(const OutgoingMessage(message: "Meraklı Cevap"));

        chatList.add(const IncomingMessage(
          message:
              "Amirim maktül domuz bağı ile öldürülmüş ve her yanında soğanlar var. Ayrıca evdeki bütün ampüller patlamış",
          delaySec: 1,
        ));
      } else {
        chatList.add(const OutgoingMessage(message: "Başından sav"));

        chatList.add(const IncomingMessage(
            delaySec: 1,
            message:
                "Ehhh senle mi uğraşıcaz lan sabah akşam. Bir gün ayık gelmez işe, her gün başkasıyla kavga eder uğraştırır devlete zarardan başka bir şey değilsin amına koyduğum"));
      }
    }
  }
}
