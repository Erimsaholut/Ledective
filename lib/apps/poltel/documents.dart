import '../../story/story_flags.dart';

/// A statement ("İfade Tutanağı") received over Poltel.
class Statement {
  const Statement({
    required this.name,
    required this.number,
    required this.daysBeforeFirstOpen,
    required this.education,
    required this.isMarried,
    required this.gender,
    required this.takenBy,
    this.questions = const [],
    this.answers = const [],
    this.testimonyFrom,
  });

  final String name;
  final String number;

  /// When the statement was taken, counted back from the first launch.
  final int daysBeforeFirstOpen;
  final String education;
  final String isMarried;
  final String gender;

  /// The officer who took the statement ("İfadeyi alan").
  final String takenBy;
  final List<String> questions;

  /// One answer per entry in [questions].
  final List<String> answers;

  /// For interrogations the player runs over MatesApp: the contact whose
  /// chat holds the questions and answers, instead of [questions].
  final String? testimonyFrom;
}

/// An entry in the Poltel inbox, delivered once [requires] is unlocked.
class PoltelDocument {
  const PoltelDocument({
    required this.id,
    required this.title,
    required this.requires,
    this.statement,
  });

  final String id;
  final String title;
  final String requires;

  /// The statement to show, or null for the autopsy report.
  final Statement? statement;
}

const List<PoltelDocument> poltelDocuments = [
  PoltelDocument(
    id: 'yusuf',
    title: 'Yusuf Kasap - İfade Tutanağı',
    requires: StoryFlags.part1Done,
    statement: Statement(
      name: "Yusuf Kasap",
      number: "354893428",
      daysBeforeFirstOpen: 2,
      education: "Lisans (eğitimi devam ediyor)",
      isMarried: "Bekar",
      gender: "Erkek",
      takenBy: "Atakan Kutay",
      questions: [
        "Berat'ı nereden tanıyorsun ve onu nasıl tarif edersin ?",
        "Kendisine zarar verebilecek birilerinden veya peşinde olan birilerinden bahsetti mi ?",
        "Daha önce şüpheli bir olaya karıştığını gördün  veya duydun mu ?",
        "Sen şu madde kullanan çocuğun ismini ver sonra gidebilirsin.",
      ],
      answers: [
        "Berat'ı fazla yakından olmamakla birlikte okuldan tanıyorum. Kendisi sanırım babasından dolayı biraz burnu havada biriydi. Zaten babası milletvekili olan birinin neden bu küçük şehirdeki, küçük bir üniversitede okuduğunu hiçbir zaman anlayamadım. Okula fazla gelip gitmezdi, geldiği zamanlarda da benimle beraber kahve içerdi. Genellikle kendine güvenen ve insanları küçük gören bir konuşma tarzı vardı.",
        "Hayır, peşinde birilerinin olduğunu sanmıyorum.",
        "Daha önce okulda yaşanan bir olay olmadı ama geçen hafta madde kullandığı bilinen bir öğrenciye ufak bir paket verirken yere düşürdüğünü görenler olmuş. Ben görmedim ama oradan geçen birkaç kişi gördüğünü söylüyor. Herkesin aklına aynı şey geldi ama kimse okuldan atılmak istemediği için üzerine gitmedi bu olayın",
        "İsmi Furkan, soyadını bilmiyorum ama bizim okulda kime sorsanız gösterir. Genelde okulun karşısındaki kafede takılıyor. Dağınık saçları olan hafif kambur bir çocuk.",
      ],
    ),
  ),
  PoltelDocument(
    id: 'deniz',
    title: 'Deniz Yılmaz - İfade Tutanağı',
    requires: StoryFlags.part1Done,
    statement: Statement(
      name: "Deniz Yılmaz",
      number: "987654321",
      daysBeforeFirstOpen: 2,
      education: "Yüksek Lisans",
      isMarried: "Bekar",
      gender: "Kadın",
      takenBy: "Doğa Aksu",
      questions: [
        "Maktulle yakınlığın nedir?",
        "Cesedi nasıl buldun?",
        "Evde dikkatini çeken bir şey oldu mu?",
        "Berat son zamanlarda tedirgin miydi?",
        "Berat'ın intihar edebileceğini düşünüyor musun?",
      ],
      answers: [
        "Berat'ın kuzeniyim. Aynı şehirde okuyoruz, ailesi buraya gelemediği için ara sıra ona ben bakardım.",
        "Berat iki gündür telefonlarımı açmıyordu. Akşam evine gittim, kapı aralıktı. İçeri girdiğimde onu salonda asılı halde buldum ve hemen 112'yi aradım.",
        "Her yer dağınıktı, sanki kavga edilmiş gibi. Sehpa devrilmişti, bardaklar kırıktı. Berat çok titiz biriydi, evi asla öyle bırakmazdı.",
        "Geçen hafta bana para lazım olduğunu söyledi. Babasından isteyemeyeceğini, birine borcu olduğunu söyledi. Kime diye sorduğumda konuyu değiştirdi.",
        "Asla. Berat kendini çok severdi. Gelecek ay yurtdışına gitmek için plan yapıyordu.",
      ],
    ),
  ),
  PoltelDocument(
    id: 'autopsy',
    title: 'Berat Yılmaz - Otopsi Raporu',
    requires: StoryFlags.part1Done,
  ),
  PoltelDocument(
    id: 'furkan',
    title: 'Furkan Şahin - İfade Tutanağı',
    requires: StoryFlags.furkanStatement,
    statement: Statement(
      name: "Furkan Şahin",
      number: "412578963",
      daysBeforeFirstOpen: 0,
      education: "Lisans (eğitimi devam ediyor)",
      isMarried: "Bekar",
      gender: "Erkek",
      takenBy: "Doğa Aksu",
      testimonyFrom: "Doğa",
    ),
  ),
];

sealed class ReportLine {
  const ReportLine(this.text);
  final String text;
}

class ReportHeading extends ReportLine {
  const ReportHeading(super.text);
}

class ReportSubheading extends ReportLine {
  const ReportSubheading(super.text);
}

class ReportField extends ReportLine {
  const ReportField(super.text);
}

class ReportParagraph extends ReportLine {
  const ReportParagraph(super.text);
}

class ReportConclusion extends ReportLine {
  const ReportConclusion(super.text);
}

const String autopsySubject = "Berat Yılmaz";

const List<ReportLine> autopsyReport = [
  ReportHeading("CESEDİN KİMLİĞİ"),
  ReportField("Adı ve soyadı: Berat Yılmaz"),
  ReportField("Kimlik numarası: 3231"),
  ReportField("Otopsi tarihi: {autopsyDate}"),
  ReportField("Cinsiyeti: Erkek"),
  ReportField("Yaş: 20-25"),
  ReportHeading("DIŞ MUAYENE BULGULARI"),
  ReportField("Boy: 173 cm"),
  ReportField("Ağırlık 70-73 kg"),
  ReportField("Saç rengi: Açık kumral"),
  ReportField("Cilt rengi: Beyaz"),
  ReportField("Sünnet durumu: Sünnetli"),
  ReportParagraph(
    "Sırt ve bel bölgelerinde ölü lekeleri tespit edildi. Alın sol tarafında 3 cm uzunluğunda kanamalı radyal yara bulundu. Burun sırtında 1 cm çapında bir yara tespit edildi. Sağ parietal bölge orta alt kısmında 3x0,5 cm boyutlarında bir yara bulundu. Çene sağ tarafında 2x2 cm boyutlarında kurumuş bir sıyrık görüldü. Sağ kolun orta arka yüzünde 6 cm çapında bir yara izi bulundu. Sağ el sırtında 2x0,5 cm boyutlarında bir yara izi tespit edildi.Sol diz altında 0,5 cm çapında kurumuş bir sıyrık bulundu.Sağ temporal bölgede 5x7 cm boyutlarında bir alanda 8 adet 4 cm çapında bıçak izi saptandı. En yakın yara arası mesafe 1,5 cm, en uzak yara arası mesafe 15 cm olarak ölçüldü. En yakın yara arası mesafe 1 cm, en uzak yara arası mesafe 15 cm olarak ölçüldü. Vücutta harici darbe, kesici-delici alet yarası ve ateşli silah gibi bulgulara rastlanmadı.",
  ),
  ReportHeading("İÇ MUAYENE BULGULARI"),
  ReportSubheading("Baş Muayenesi"),
  ReportParagraph(
    "Saç derisi kaldırıldı ve sağ temporal bölgede yaygın ekimozlu bir bulgu tespit edildi. Kafatası açıldı. Beyin beyincik çıkarıldı ve tartıldı. Ağırlığı 1250 gr olarak ölçüldü. Sağ temporal bölgede yaygın 0,2 cm kalınlığında subdural kanama tespit edildi. Beyin beyincik yüzeyini etkileyen özellikle beynin sağ temporal lobunda yoğunluk gösteren subaraknoidal kanama saptandı. Kafa kaide kemiklerinin sağlam olduğu belirlendi.",
  ),
  ReportSubheading("Boyun Muayenesi"),
  ReportParagraph(
    "Boyun cimadında, kaslarda ve yumuşak dokularda kanama veya ekimoz bulguları gözlenmedi. Boyun çevresinde özellikle arka bölgede asma izleri bulundu. Asma izleri, boyundaki derinliklere nüfuz eden ve çizgi şeklindeki izler olarak tanımlandı. Boyun organlarında şu bulgular saptandı: Hyoid kemik, tiroid kartilaj ve boyun omurları sağlamdı. Özofagus ve trakea boş olarak bulundu.",
  ),
  ReportSubheading("Göğüs Muayenesi"),
  ReportParagraph(
    "Göğüs kafesi açıldı ve kalp incelendi. Kalbin sağ ventrikül bölgesinde 3 cm derinliğinde bıçak deliği tespit edildi. Delik, sol ventrikül arka duvarından kalbe girmiş ve kalpte büyük bir yırtılma meydana getirmiştir. Kalpte yaygın kanama ve kan pıhtıları gözlendi. Kalbin diğer bölgelerinde anormallik tespit edilmedi. Kalp krizi veya diğer doğal nedenlerden kaynaklanan herhangi bir patolojiye rastlanmadı.",
  ),
  ReportConclusion(
    "Bu otopsi raporu, incelenen erkek cesedin dış ve iç muayene bulgularını içermektedir. Ölüm sebebi, göğsünden aldığı bıçak darbesi sonucu kalpte meydana gelen yırtılma ve kanamadır. Asılma işlemi ve boyundaki izler ölümden sonra oluşmuştur. cesette boğuşma izleri görülmektedir.",
  ),
];
