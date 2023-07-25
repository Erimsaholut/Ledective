import 'package:ledective/story_brain/StoryBrainMatesAppMesages/ozge/ozge.dart';
import '../apps/Tools/incoming_message.dart';
import '../apps/Tools/outcoming_message.dart';



checkAnswer(int userSelect, int section,int sm, String person, List chatList,List keyboardTexts) async {
  if (section == 0) {

    if (person == "Özge") {

      if(sm==0){
        keyboardTexts = ["deneme1","deneme2","deneme3"];

        if (userSelect == 1) {
          chatList.add(S0userAppMessages["0"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["0"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["0"]![i]);
          }
        }



        else if (userSelect == 2) {
          chatList.add(S0userAppMessages["1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["1"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["1"]![i]);
          }
        }


      }
      if(sm==1){
        keyboardTexts = ["sm1","sm2","sm3"];
        if (userSelect == 1) {
          chatList.add(S0userAppMessages["1"]![0]);

        for (int i = 0; i < S0ozgeAppMessages["2"]!.length; i++) {
          chatList.add(S0ozgeAppMessages["2"]![i]);
        }
      }


      }
      if(sm==2){
        keyboardTexts = ["sm31","sm22","sm343"];
        if (userSelect == 1) {
              chatList.add(S0userAppMessages["3.1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.1"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.1"]![i]);
          }
        }



        else if (userSelect == 2) {
          keyboardTexts = ["adsas","dfsfdas","sm343"];
          chatList.add(S0userAppMessages["3.2"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.2"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.2"]![i]);
          }
          sm++;

        }



        else {
          chatList.add(S0userAppMessages["3.3"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.3"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.3"]![i]);
          }
        }

      }
      if(sm==3){

        if (userSelect == 1) {
          chatList.add(S0userAppMessages["4"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["4"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["4"]![i]);
          }
          sm++;
        }





        else {
          chatList.add(S0userAppMessages["3.1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["3.1"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["3.1"]![i]);
          }
        }

      }
      if(sm==4){
        if (userSelect == 1) {
          chatList.add(S0userAppMessages["3.1"]![0]);

          for (int i = 0; i < S0ozgeAppMessages["4"]!.length; i++) {
            chatList.add(S0ozgeAppMessages["4"]![i]);
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

    }


















    if (person == "Orhun") {
      if (userSelect == 1) {
        chatList.add(const OutgoingMessage(
            message:
                "Orhun bak Özgeyi sikmek istediğim için cevap verirum sen de tatava yapıp sinirimi bozma benim"));
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
