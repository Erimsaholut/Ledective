import 'dialogue.dart';

/// MatesApp conversations, keyed by contact name.
const Map<String, Conversation> conversations = {
  "Özge": Conversation(history: _ozgeHistory, dialogue: _ozgeDialogue),
  "Orhun": Conversation(history: _orhunHistory, dialogue: _orhunDialogue),
  "Behram": Conversation(history: _behramHistory),
};

/* Oyun öncesi muhabbetler. Sonrası için bir etkisi olmayacak. */

const List<ChatEntry> _ozgeHistory = [
  DayMarker(daysAgo: 8),
  IncomingMessage("İyi akşamlar amirim istediğiniz raporları müdüre ilettim."),
  OutgoingMessage("Aferin kızım"),
  DayMarker(daysAgo: 5),
  IncomingMessage(
    "Palu cinayeti için savcılıkta imza vermeniz gerekiyormuş amirim.",
  ),
  OutgoingMessage("Atakanı yolla, atıversin benim yerime"),
  IncomingMessage("Atakan izinli amirim Orhuna haber verdim"),
  OutgoingMessage("ok"),
  DayMarker(),
  IncomingMessage(
    "Amirim yardımınızı gerektiren büyük bir cinayet olayı oldu. Büro olarak işin içinde çıkamadık.",
  ),
];

const List<ChatEntry> _orhunHistory = [
  DayMarker(daysAgo: 5),
  IncomingMessage("İmza işini hallettim amirim."),
  OutgoingMessage("tmmdır"),
  DayMarker(),
  IncomingMessage("Akşama iki bira ok ?"),
];

const List<ChatEntry> _behramHistory = [
  DayMarker(label: "10 Nisan"),
  IncomingMessage("Tüm polis teşkilatımızın polis haftası kutlu olsun."),
];

/* Özge */

const _ozgeCaseBriefing = [
  "3 gün önce akşam saatlerinde bir üniversite öğrencisinin kendini astığı ihbarı geldi. Olay yeri incelemesi ve"
      " otopsiden sonra olayın cinayet olduğu açığa çıktı. Maktül öldükten sonra asılmış ve her yerinde boğuşma izleri var",
  "Olaydan haberimiz olduktan yarım saat sonra şube müdürümüzden bir telefon geldi. Kendisini de il emniyet müdürü aramış."
      " Maktulün bir milletvekilinin oğlu olduğunu ve diğer davaları askıya alıp hepimizin bu davaya odaklanması söyledi.",
  "Size de ulaşmaya çalışmış ama telefonunuz kapalıymış",
];

const _ozgeAskStatements = DialogueOption(
  label: "Yakınlarının ifadesini aldınız mı ?",
  replies: [
    "Atakan'la Doğa maktülün yakın arkadaşının ve cesedi bulan kişinin ifadesini aldılar ama görünüşe göre fazla arkadaşı yokmuş.",
  ],
  next: "sendStatements",
);

const _ozgePhoneWasOn = DialogueOption(
  label: "Kapalı değildi Erdiyi engelledim ben",
  replies: [
    "Anladım amirim. Atakan'la Doğa maktülün yakın arkadaşının ifadesini aldılar. Onları size \"poltel\" üzerinden gönderiyorum",
  ],
);

const _ozgeDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode([
      DialogueOption(
        label: "Neymiş bu kadar önemli olan durum",
        replies: _ozgeCaseBriefing,
        next: "questions",
      ),
      DialogueOption(
        label: "Kızım ben size izindeyken bana yazmayın demedim mi ?",
        replies: [
          "Amirim çok özür dilerim ama gerçekten ciddi bir olay",
          "Amirim şu an yurtdışında olduğunuzu biliyorum ama yardımınızı gerektiren önemli bir durum var",
        ],
        next: "whatHappened",
      ),
    ]),
    "whatHappened": DialogueNode([
      DialogueOption(
        label: "Neymiş bu kadar önemli olan durum",
        replies: _ozgeCaseBriefing,
        next: "questions",
      ),
    ]),
    "questions": DialogueNode([
      _ozgeAskStatements,
      DialogueOption(
        label: "Hangi davaları askıya aldınız ?",
        replies: [
          "Borç meselesi yüzünden çıkan kavgada ölen adamın davasını askıya aldık ama sadece evrak işleri kalmıştı. Boş kaldığım bir zamanda hallederim ben onu.",
        ],
        next: "questionsAfterCases",
      ),
      _ozgePhoneWasOn,
    ]),
    "questionsAfterCases": DialogueNode([_ozgeAskStatements, _ozgePhoneWasOn]),
    "sendStatements": DialogueNode([
      DialogueOption(
        label: "İfadeleri bana poltel üzerinden gönder",
        replies: ["Hemen gönderiyorum amirim."],
      ),
    ]),
  },
);

/* Orhun */

const _orhunDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode([
      DialogueOption(
        label: "Evladım salak mısın sen",
        message:
            "Orhun bak sırf Özge rica etti diye cevap veriyorum, sinirimi bozma benim",
        replies: ["Amirim ayıp oluyor ama "],
      ),
      // TODO: "Meraklı Cevap" ve "Başından sav" yer tutucu metinler.
      DialogueOption(
        label: "Evladım",
        message: "Meraklı Cevap",
        replies: [
          "Amirim maktülün evinde boğuşma izleri var, olay yeri ekibi inceliyor",
        ],
      ),
      DialogueOption(
        label: "Salak",
        message: "Başından sav",
        replies: [
          "Amirim lütfen biraz ciddi olun, durum gerçekten kötü",
        ],
      ),
    ]),
  },
);
