import 'package:ledective/story_brain/StoryBrainMatesAppMesages/ozge/ozge.dart';
import '../widgets/incoming_message.dart';
import '../widgets/outcoming_message.dart';

checkAnswer(int userSelect, int section, int sm, String person, List chatList,
    Function setKeyboard) async {
  if (section == 0) {
    if (person == "Özge") {
      if (sm == 0) {
        setKeyboard([
          "Neymiş bu kadar önemli olan durum",
          "Kızım ben size izindeyken bana yazmayın demedim mi ?",
          "null"
        ]);
        if (userSelect == 1) {
          chatList.add(S0userAppMessages["0"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["0"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["0"]![i]);
          }
        } else if (userSelect == 2) {
          chatList.add(S0userAppMessages["1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["1"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["1"]![i]);
          }
        }
      }
      if (sm == 1) {
        setKeyboard([
          "Yakınlarının ifadesini aldınız mı ?",
          "Hangi davaları askıya aldınız ? ",
          "Kapalı değildi Erdiyi engelledim ben "
        ]);
        if (userSelect == 1) {
          chatList.add(S0userAppMessages["1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["2"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["2"]![i]);
          }
        }
      }
      if (sm == 2) {
        setKeyboard(["sm2", "sm2", "sm2"]);
        if (userSelect == 1) {
          chatList.add(S0userAppMessages["3.1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.1"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.1"]![i]);
          }
        } else if (userSelect == 2) {
          chatList.add(S0userAppMessages["3.2"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.2"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.2"]![i]);
          }
          sm++;
        } else {
          chatList.add(S0userAppMessages["3.3"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.3"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.3"]![i]);
          }
        }
      }
      if (sm == 3) {
        setKeyboard(["sm3", "null", "null"]);
        if (userSelect == 1) {
          chatList.add(S0userAppMessages["4"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["4"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["4"]![i]);
          }
          sm++;
        } else {
          chatList.add(S0userAppMessages["3.1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.1"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.1"]![i]);
          }
        }
      }
    }

    if (person == "Orhun") {
      if (sm == 0) {
        setKeyboard(["Evladım salak mısın sen", "Evladım", "Salak"]);

        if (userSelect == 1) {
          chatList.add(const OutgoingMessage(
              message:
                  "Orhun bak Özgeyi s@*mek istediğim için cevap veriyorum sen de tatava yapıp sinirimi bozma benim"));
          chatList.add(const IncomingMessage(
              delaySec: 1, message: "Amirim ayıp oluyor ama "));
        } else if (userSelect == 2) {
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
      if (sm == 1) {
        setKeyboard(["all", "mall", "null"]);

        if (userSelect == 1) {
          chatList.add(const OutgoingMessage(
              message:
                  "Orhun bak Özgeyi +½# istediğim için cevap verirum sen de tatava yapıp sinirimi bozma benim"));
          chatList.add(const IncomingMessage(
              delaySec: 1, message: "Amirim ayıp oluyor ama "));
        } else if (userSelect == 2) {
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
      if (sm == 2) {
        setKeyboard(["Seni işten attırırım", "Şakam yok", "Yaparım"]);

        if (userSelect == 1) {
          chatList.add(const OutgoingMessage(
              message:
                  "Orhun bak Özgeyi @+3≈! istediğim için cevap verirum sen de tatava yapıp sinirimi bozma benim"));
          chatList.add(const IncomingMessage(
              delaySec: 1, message: "Amirim ayıp oluyor ama "));
        } else if (userSelect == 2) {
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
}

firstKeyboard() {}
