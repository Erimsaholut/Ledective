
import 'package:flutter/cupertino.dart';

Map<String, dynamic> documentTexts = {
  "Orhan Kasap": {
    "name": "Orhan Kasap",
    "number": "123456789",
    "madeDate": "01.01.2022",
    "education": "High School",
    "isMarried": "Married",
    "gender": "Male",
    "isAutopsy": "False",
    "questions": [
      "Berat'ı nereden tanıyorsun ve onu nasıl tarif edersin ?",
      "Kendisine zarar verebilecek birilerinden veya peşinde olan birilerinden bahsetti mi ?",
      "Daha önce şüpheli bir olaya karıştığını gördün  veya duydun mu ?",
      "Sen şu madde kullanan çocuğun ismini ver sonra gidebilirsin."
    ],
    "answers": [
      "Berat'ı fazla yakından olmamakla birlikte okuldan tanıyorum. Kendisi sanırım babasından dolayı biraz burnu havada biriydi. Zaten babası milletvekili olan birinin neden bu küçük şehirdeki, küçük bir üniversitede okuduğunu hiçbir zaman anlayamadım. Okula fazla gelip gitmezdi, geldiği zamanlarda da benimle beraber kahve içerdi. Genellikle kendine güvenen ve insanları küçük gören bir konuşma tarzı vardı.",
      "Hayır, peşinde birilerinin olduğunu sanmıyorum.",
      "Daha önce okulda yaşanan bir olay olmadı ama geçen hafta madde kullandığı bilinen bir öğrenciye ufak bir paket verirken yere düşürdüğünü görenler olmuş. Ben görmedim ama oradan geçen birkaç kişi gördüğünü söylüyor. Herkesin aklına aynı şey geldi ama kimse okuldan atılmak istemediği için üzerine gitmedi bu olayın",
      "İsmi Furkan, soyadını bilmiyorum ama bizim okulda kime sorsanız gösterir. Genelde okulun karşısındaki kafede takılıyor. Dağınık saçları olan hafif kambur bir çocuk."
    ],
  },
  "Furkan Kasap": {
    "name": "Furkan Kasap",
    "number": "123456789",
    "madeDate": "01.01.2022",
    "education": "High School",
    "isMarried": "Married",
    "gender": "Male",
    "isAutopsy": "False",
    "questions": [
      "Naptın olm ?",
      "Halka açık alanda masturbasyon yapmışsın ?",
    ],
    "answers": [
      "Abe kayıp mültecilerle bir alakam yok yemin edeirim",
      "Evet nolmuş kine ? ",
    ],
  },
  "Deniz Yılmaz": {
    "name": "Deniz Yılmaz",
    "number": "987654321",
    "madeDate": "05.03.2023",
    "education": "Yüksek Lisans",
    "isMarried": "Bekar",
    "gender": "Kadın",
    "isAutopsy": "False",
    "questions": [
      "Deniz'i nereden tanıyorsun ve onu nasıl tarif edersin?",
      "Son zamanlarda Deniz, kişisel hayatıyla ilgili sorunlar yaşadı mı?",
      "Daha önce Deniz'in şüpheli bir olaya karıştığını gördün veya duydun mu?",
      "Son zamanlarda okulda uyuşturucu kullanımıyla ilgili herhangi bir durum fark ettin mi?",
      "Deniz hakkında daha fazla detay verebilir misin?"
    ],
    "answers": [
      "Deniz'i üniversiteden tanıyorum. O oldukça zeki ve başarılı bir öğrenci. Sınıfta aktif olarak katılır ve sık sık tartışmalara katılır. Arkadaşları tarafından sevilen biri ve yardımsever bir kişiliği var.",
      "Son zamanlarda Deniz, kişisel hayatıyla ilgili bazı sorunlar yaşadı. Ailevi konulardan dolayı biraz stresli olduğunu söyledi ve bu durum derslerine yansıyor.",
      "Daha önce Deniz'in şüpheli bir olaya karıştığını görmedim veya duymadım.",
      "Son zamanlarda okulda uyuşturucu kullanımıyla ilgili herhangi bir durum fark etmedim. Okulda uyuşturucu kullanımıyla ilgili sıkı önlemler alınıyor ve öğrenciler bilinçlendiriliyor.",
      "Deniz, 25 yaşında bir kadın. Mavi gözlere ve kahverengi saçlara sahip. Hobileri arasında kitap okumak, seyahat etmek ve müzik dinlemek bulunuyor."
    ]
  }
};

List<Widget> otopsi = [
  const Text(
    "CESEDİN KİMLİĞİ :\n",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text("\t Adı ve soyadı: Berat Yılmaz"),
  const Text("\t Kimlik numarası: 3231"),
  const Text("\t Otopsi tarihi: tarih gelecek"),
  const Text("\t Cinsiyeti: Erkek"),
  const Text("\t Yaş: 20-25"),
  const Text(
    "\n DIŞ MUAYENE BULGULARI :\n",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text("\t Boy: 173 cm"),
  const Text("\t Ağırlık 70-73 kg"),
  const Text("\t Saç rengi: Açık kumral"),
  const Text("\t Cilt rengi: Beyaz"),
  const Text("\t Sünnet durumu: Sünnetli"),
  const Text(
      "\nSırt ve bel bölgelerinde ölü lekeleri tespit edildi. Alın sol tarafında 3 cm uzunluğunda kanamalı radyal yara bulundu. Burun sırtında 1 cm çapında bir yara tespit edildi. Sağ parietal bölge orta alt kısmında 3x0,5 cm boyutlarında bir yara bulundu. Çene sağ tarafında 2x2 cm boyutlarında kurumuş bir sıyrık görüldü. Sağ kolun orta arka yüzünde 6 cm çapında bir yara izi bulundu. Sağ el sırtında 2x0,5 cm boyutlarında bir yara izi tespit edildi.Sol diz altında 0,5 cm çapında kurumuş bir sıyrık bulundu.Sağ temporal bölgede 5x7 cm boyutlarında bir alanda 8 adet 4 cm çapında bıçak izi saptandı. En yakın yara arası mesafe 1,5 cm, en uzak yara arası mesafe 15 cm olarak ölçüldü. En yakın yara arası mesafe 1 cm, en uzak yara arası mesafe 15 cm olarak ölçüldü. Vücutta harici darbe, kesici-delici alet yarası ve ateşli silah gibi bulgulara rastlanmadı."),
  const Text(
    "\n İÇ MUAYENE BULGULARI :\n",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text(
    "\n\t\t Baş Muayenesi :\n",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text(
      "Saç derisi kaldırıldı ve sağ temporal bölgede yaygın ekimozlu bir bulgu tespit edildi. Kafatası açıldı. Beyin beyincik çıkarıldı ve tartıldı. Ağırlığı 1250 gr olarak ölçüldü. Sağ temporal bölgede yaygın 0,2 cm kalınlığında subdural kanama tespit edildi. Beyin beyincik yüzeyini etkileyen özellikle beynin sağ temporal lobunda yoğunluk gösteren subaraknoidal kanama saptandı. Kafa kaide kemiklerinin sağlam olduğu belirlendi."),
  const Text(
    "\n\t\t Boyun Muayenesi :\n",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text(
      "	Boyun cimadında, kaslarda ve yumuşak dokularda kanama veya ekimoz bulguları gözlenmedi. Boyun çevresinde özellikle arka bölgede asma izleri bulundu. Asma izleri, boyundaki derinliklere nüfuz eden ve çizgi şeklindeki izler olarak tanımlandı. Boyun organlarında şu bulgular saptandı: Hyoid kemik, tiroid kartilaj ve boyun omurları sağlamdı."),
  const Text(
    "\n\t\t Göğüs Muayenesi :\n",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text(
      "Göğüs kafesi açıldı ve kalp incelendi. Kalbin sağ ventrikül bölgesinde 3 cm derinliğinde bıçak deliği tespit edildi. Delik, sol ventrikül arka duvarından kalbe girmiş ve kalpte büyük bir yırtılma meydana getirmiştir. Kalpte yaygın kanama ve kan pıhtıları gözlendi. Kalbin diğer bölgelerinde anormallik tespit edilmedi. Kalp krizi veya diğer doğal nedenlerden kaynaklanan herhangi bir patolojiye rastlanmadı. "),
  const Text(
    "\n\nBu otopsi raporu, incelenen erkek cesedin dış ve iç muayene bulgularını içermektedir. Ölüm sebebi, göğsünden aldığı bıçak darbesi sonucu kalpte meydana gelen yırtılma ve kanamadır. Asılma işlemi ve boyundaki izler ölümden sonra oluşmuştur. cesette boğuşma izleri görülmektedir.",
    style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
  ),
];
