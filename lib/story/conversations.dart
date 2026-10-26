import 'dialogue.dart';
import 'story_flags.dart';

/// MatesApp conversations, keyed by contact name. The flow follows
/// story/Hikaye.pdf: Kısım 1 is Özge, Kısım 2 is Orhun, Erdi and İnanç.
/// The interrogation with Doğa continues from where the design ends.
const Map<String, Conversation> conversations = {
  "Özge": Conversation(history: _ozgeHistory, dialogue: _ozgeDialogue),
  "Orhun": Conversation(history: _orhunHistory, dialogue: _orhunDialogue),
  "Atakan": Conversation(history: _atakanHistory, dialogue: _atakanDialogue),
  "Behram": Conversation(history: _behramHistory, dialogue: _behramDialogue),
  "İnanç": Conversation(history: _inancHistory, dialogue: _inancDialogue),
  "Doğa": Conversation(history: _dogaHistory, dialogue: _dogaDialogue),
  "Erdi": Conversation(dialogue: _erdiDialogue),
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

const List<ChatEntry> _atakanHistory = [
  DayMarker(daysAgo: 6),
  IncomingMessage("Amirim yarın izinliyim, Özge'ye haber verdim."),
  OutgoingMessage("tamam"),
];

const List<ChatEntry> _inancHistory = [
  DayMarker(daysAgo: 12),
  OutgoingMessage("Raporları cumaya kadar bitirin"),
  IncomingMessage("Emredersiniz amirim."),
];

const List<ChatEntry> _dogaHistory = [
  DayMarker(daysAgo: 9),
  IncomingMessage("Amirim nöbet çizelgesini masanıza bıraktım."),
];

/* Kısım 1: Özge */

const _ozgeCaseBriefing = [
  "3 gün önce akşam saatlerinde bir üniversite öğrencisinin kendini astığı ihbarı geldi. Olay yeri incelemesi ve"
      " otopsiden sonra olayın cinayet olduğu açığa çıktı. Maktül öldükten sonra asılmış ve her yerinde boğuşma izleri var",
  "Olaydan haberimiz olduktan yarım saat sonra şube müdürümüzden bir telefon geldi. Kendisini de il emniyet müdürü aramış."
      " Maktulün bir milletvekilinin oğlu olduğunu ve diğer davaları askıya alıp hepimizin bu davaya odaklanması söyledi.",
  "Size de ulaşmaya çalışmış ama telefonunuz kapalıymış",
];

const _ozgeStatementsTaken =
    "Atakan'la Doğa maktülün yakın arkadaşının ve cesedi bulan kişinin ifadesini aldılar ama görünüşe göre fazla arkadaşı yokmuş.";

const _ozgeDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(
      incoming: [
        "Amirim şu an yurtdışında olduğunuzu biliyorum ama yardımınızı gerektiren önemli bir durum var",
      ],
      [
        DialogueOption(
          label: "Kızım ben size izindeyken bana yazmayın demedim mi ?",
          replies: ["Amirim çok özür dilerim ama gerçekten ciddi bir olay"],
          traits: [Trait.anger],
          next: "whatHappened",
        ),
        DialogueOption(
          label: "Neymiş bu kadar önemli olan durum",
          replies: _ozgeCaseBriefing,
          traits: [Trait.curiosity],
          next: "questions",
        ),
      ],
    ),
    "whatHappened": DialogueNode([
      DialogueOption(
        label: "Neymiş bu kadar önemli olan durum",
        replies: _ozgeCaseBriefing,
        next: "questions",
      ),
    ]),
    "questions": DialogueNode([
      DialogueOption(
        label: "Yakınlarının ifadesini aldınız mı ?",
        replies: [_ozgeStatementsTaken],
        traits: [Trait.curiosity],
        next: "sendStatements",
      ),
      DialogueOption(
        label: "Hangi davaları askıya aldınız ?",
        replies: [
          "Borç meselesi yüzünden çıkan kavgada ölen adamın davasını askıya aldık ama sadece evrak işleri kalmıştı. Boş kaldığım bir zamanda hallederim ben onu.",
        ],
        traits: [Trait.curiosity],
        next: "afterCases",
      ),
      DialogueOption(
        label: "Kapalı değildi Erdiyi engelledim ben",
        replies: [
          "Anladım amirim. Atakan'la Doğa maktülün yakın arkadaşının ifadesini aldılar. Onları size \"poltel\" üzerinden gönderiyorum",
        ],
        traits: [Trait.indifference],
        unlocks: [StoryFlags.part1Done],
      ),
    ]),
    "afterCases": DialogueNode([
      DialogueOption(
        label:
            "Tamamdır hallet sen onu. Maktulün yakınlarının ifadesini aldınız mı ?",
        replies: [_ozgeStatementsTaken],
        traits: [Trait.curiosity],
        next: "sendStatements",
      ),
    ]),
    "sendStatements": DialogueNode([
      DialogueOption(
        label: "İfadeleri bana poltel üzerinden gönder",
        replies: ["Hemen gönderiyorum amirim."],
        unlocks: [StoryFlags.part1Done],
      ),
    ]),
  },
);

/* Kısım 2: Orhun */

const _orhunFoundAddress =
    "Amirim okulu biraz soruşturduk ve Beratla görülen madde kullanan çocuğun adresini bulduk.";

const _orhunDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(
      waitFor: StoryFlags.part1Done,
      incoming: [
        "Amirim, Özgeyle konuşmuşsunuz sanırım. Dava ile ilgili bilgileri size ben iletebilirim.",
      ],
      [
        DialogueOption(
          label: "İlet bakalım",
          replies: [_orhunFoundAddress],
          next: "statement",
        ),
        DialogueOption(
          label: "Madde kullanan çocuğu buldunuz mu ?",
          replies: [
            "Bulduk amirim gerçekten yusufun anlattığı yerde takılıyormuş",
          ],
          next: "statement",
        ),
        DialogueOption(
          label: "Otopsi raporu ne zaman çıktı",
          replies: [
            "Amirim bu dava yüzünden bütün yöneticilerin eli ayağı karıştı bu yüzden çok hızlı bir şekilde geldi otopsi raporu",
          ],
          next: "status",
        ),
      ],
    ),
    "status": DialogueNode([
      DialogueOption(
        label: "Anladım, ne durumdasınız şu an",
        replies: [_orhunFoundAddress],
        next: "statement",
      ),
    ]),
    "statement": DialogueNode([
      DialogueOption(
        label: "İfadesini aldınız mı uygulamada gözükmüyor.",
        replies: ["İnanç alacak amirim ifadesini isterseniz ona bir yazın."],
        unlocks: [StoryFlags.orhunDone],
      ),
    ]),
  },
);

/* Kısım 2: Erdi (şube müdürü) */

const _erdiDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(
      waitFor: StoryFlags.part1Done,
      incoming: [
        "Neredesin sen telefonları da açmıyosun. Senin kadar sorumsuz herif görmedim ben. Bütün asayiş birbirine girdi sen tatil yapıyorsun",
      ],
      [
        DialogueOption(
          label: "Biliyorsun nerede olduğumu",
          replies: ["Kimse bilmiyor nerede olduğunu. İzin alacağın zamana bak"],
          next: "calm",
        ),
        DialogueOption(
          label:
              "Olaylardan haberim var buradan müdahale ediyorum. Türkiye'ye dönmem en az 3 gün sürer",
          replies: [
            "Bu dava özel bir dava elinizden geleni yapın gerekirse bütün imkanları devreye sokarız.",
          ],
          next: "calm",
        ),
        DialogueOption(
          label: "(Cevap verme)",
          silent: true,
          traits: [Trait.indifference],
        ),
      ],
    ),
    "calm": DialogueNode([DialogueOption(label: "Sen içini ferah tut")]),
  },
);

/* Kısım 2: İnanç */

const _inancDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(waitFor: StoryFlags.orhunDone, [
      DialogueOption(
        label: "Naptınız oğlum sorgu işini",
        replies: [
          "Amirim, elemanı evinden aldık biraz sonra sorguya girecektik",
        ],
        next: "plan",
      ),
    ]),
    "plan": DialogueNode([
      DialogueOption(
        label: "Benim söyleyeceğim sorularla alın ifadesini.",
        replies: [
          "Yurtdışından döndünüz mü amirim. Siz gelene kadar bekletelim elemanı",
        ],
        next: "notBack",
      ),
      DialogueOption(
        label:
            "Şimdi bürodaki kızlardan birini yanına al. Eleman ne söylüyorsa bana yazsın. Sen de benim sana sorduğum soruları sor ona",
        replies: [
          "Tamamdır doğaya haber verdim ben. Ona söylediğiniz zaman sorguya başlayabiliriz.",
        ],
        unlocks: [StoryFlags.inancDone],
      ),
    ]),
    "notBack": DialogueNode([
      DialogueOption(
        label: "Hayır gelmeme daha var. Buradan soracağım ben soruları",
        replies: [
          "Anladım amirim. Doğa'yı yanıma alıyorum, sorularınızı ona yazın.",
        ],
        traits: [Trait.courage],
        unlocks: [StoryFlags.inancDone],
      ),
    ]),
  },
);

/* Furkan'ın sorgusu: Doğa sorgu odasından yazıyor */

const _furkanHow = DialogueOption(
  label: "Berat'ı nereden tanıyorsun?",
  replies: [
    "Furkan: \"Okuldan abi. Bir iki kere okulun karşısındaki kafede oturduk, o kadar.\"",
  ],
  testimony:
      "Okuldan abi. Bir iki kere okulun karşısındaki kafede oturduk, o kadar.",
  traits: [Trait.curiosity],
  next: "package",
);

const _furkanPackage = DialogueOption(
  label: "Seni Berat'tan paket alırken görmüşler. O pakette ne vardı?",
  replies: ["Furkan: \"Ne paketi abi? Sigara verdi bana, sigara.\""],
  testimony: "Ne paketi abi? Sigara verdi bana, sigara.",
  traits: [Trait.courage],
  next: "package",
);

const _furkanPressure = DialogueOption(
  label: "Yalan söyleme! Kameralarda her şey var, pakette ne vardı?",
  replies: [
    "Furkan: \"Tamam tamam bağırmayın! Ot vardı abi. Berat satıyordu, ben de ondan alıyordum.\"",
  ],
  testimony:
      "Tamam tamam bağırmayın! Ot vardı abi. Berat satıyordu, ben de ondan alıyordum.",
  traits: [Trait.anger],
  next: "supplier",
);

const _furkanReassure = DialogueOption(
  label: "Doğruyu söylersen sana yardım ederiz. Pakette ne vardı?",
  replies: [
    "Furkan: \"Ot vardı abi... Berat satıyordu, ben sadece kendime alıyordum. Ailem duymasın ne olur.\"",
  ],
  testimony:
      "Ot vardı abi... Berat satıyordu, ben sadece kendime alıyordum. Ailem duymasın ne olur.",
  traits: [Trait.mercy],
  next: "supplier",
);

const _furkanAlibi = DialogueOption(
  label: "Olay gecesi neredeydin?",
  replies: [
    "Furkan: \"Kafedeydim abi, kapanana kadar. Kafeci de gördü, kameralara bakın.\"",
  ],
  testimony:
      "Kafedeydim abi, kapanana kadar. Kafeci de gördü, kameralara bakın.",
  traits: [Trait.caution],
  next: "packageAfterAlibi",
);

const _furkanWhere = DialogueOption(
  label: "Adil'i nerede bulabiliriz?",
  replies: [
    "Furkan: \"Sanayinin girişindeki çay ocağında takılır. Ama benden duymadınız abi, beni öldürür.\"",
    "İfadeyi tutanağa geçirdim amirim, poltele yükledim.",
  ],
  testimony:
      "Sanayinin girişindeki çay ocağında takılır. Ama benden duymadınız abi, beni öldürür.",
  traits: [Trait.courage],
  unlocks: [StoryFlags.furkanStatement],
);

const _furkanEnough = DialogueOption(
  label: "Bu kadar yeter. Doğa, ifadeyi tutanağa geçir.",
  replies: ["Tamamdır amirim, poltele yüklüyorum."],
  traits: [Trait.caution],
  unlocks: [StoryFlags.furkanStatement],
);

const _dogaDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(
      waitFor: StoryFlags.inancDone,
      incoming: [
        "Amirim sorgu odasındayız. Furkan karşımda, sorularınızı bekliyorum.",
      ],
      [
        _furkanHow,
        _furkanPackage,
        DialogueOption(
          label: "Önce bir su ver çocuğa, korkmuş gibi.",
          replies: ["Verdim amirim, biraz rahatladı. Sorularınızı alayım."],
          traits: [Trait.mercy],
          next: "calm",
        ),
      ],
    ),
    "calm": DialogueNode([_furkanHow, _furkanPackage]),
    "package": DialogueNode([_furkanPressure, _furkanReassure, _furkanAlibi]),
    "packageAfterAlibi": DialogueNode([_furkanPressure, _furkanReassure]),
    "supplier": DialogueNode([
      DialogueOption(
        label: "Berat malı kimden alıyordu?",
        replies: [
          "Furkan: \"Adil diye biri var, herkes Adil abi der. Berat ona borçlandığını söylemişti geçen hafta.\"",
        ],
        testimony:
            "Adil diye biri var, herkes Adil abi der. Berat ona borçlandığını söylemişti geçen hafta.",
        traits: [Trait.curiosity],
        next: "adil",
      ),
      DialogueOption(
        label: "Berat'ın başı birileriyle dertte miydi?",
        replies: [
          "Furkan: \"Adil abiye borcu vardı. Ödemezse başım yanar diyordu. Gülüyordu ama korkuyordu bence.\"",
        ],
        testimony:
            "Adil abiye borcu vardı. Ödemezse başım yanar diyordu. Gülüyordu ama korkuyordu bence.",
        traits: [Trait.caution],
        next: "adil",
      ),
    ]),
    "adil": DialogueNode([_furkanWhere, _furkanEnough]),
  },
);

/* Atakan ve Behram: hikâyenin ilerleyişine göre yazıyorlar */

const _atakanDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(
      waitFor: StoryFlags.part1Done,
      incoming: [
        "Amirim Yusuf'un ifadesini ben aldım, poltelde var. Çocuk bir şey saklıyor gibiydi.",
      ],
      [
        DialogueOption(
          label: "Neden öyle düşündün?",
          replies: [
            "Furkan'ın adını verirken etrafına bakınıp durdu. Kendisi de o kafeye takılıyormuş, Berat'la sandığından daha yakınlar bence.",
          ],
          traits: [Trait.curiosity],
        ),
        DialogueOption(
          label: "Tamam, gözünüzü üzerinden ayırmayın.",
          replies: ["Emredersiniz amirim."],
          traits: [Trait.caution],
        ),
      ],
    ),
  },
);

const _behramDialogue = Dialogue(
  start: "start",
  nodes: {
    "start": DialogueNode(
      waitFor: StoryFlags.furkanStatement,
      incoming: [
        "Komiserim, Furkan'ın ifadesini okudum. Adil bizim narkotik dosyasında da var, aylardır peşindeyiz.",
        "Bu işe birlikte bakmamız lazım. Döndüğünde ilk iş konuşalım.",
      ],
      [
        DialogueOption(
          label: "Tamam. Ben dönene kadar Adil'e kimse dokunmasın.",
          replies: ["Merak etme, uzaktan izliyoruz."],
          traits: [Trait.caution],
        ),
        DialogueOption(
          label: "Bekleyemem, adamlarını hazır tut. Gerekirse bu gece alın.",
          replies: ["Sen bilirsin komiserim. Ekip hazır."],
          traits: [Trait.courage],
        ),
      ],
    ),
  },
);
