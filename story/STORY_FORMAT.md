# Hikâye dosyaları

Oyunun bütün hikâye içeriği `assets/story/` altındaki JSON dosyalarındadır.
Kod değiştirmeden yeni sohbet, belge, delil, mekân ve ipucu eklenebilir.

Bir dosyayı düzenledikten sonra kontrol et:

```bash
dart run tool/validate_story.dart
```

Araç hatalı bağlantıları (olmayan düğüm, hiçbir şeyin açmadığı bayrak,
bulunamayan görsel...) satır satır söyler. Sohbet ağaçlarını çizdirmek için:

```bash
dart run tool/validate_story.dart --graph
```

Şemalar `story/graphs/<kişi>.md` dosyalarına yazılır; GitHub ya da VS Code
Markdown önizlemesi bunları akış şeması olarak gösterir.

Bütün hikâyeyi tek bir tabloda görmek için:

```bash
dart run tool/validate_story.dart --table
```

Bu, [`story/HIKAYE_SEMASI.md`](HIKAYE_SEMASI.md) dosyasını yeniden üretir:
ana yolun kilometre taşları, her kişinin seçenekleri ve sonuçları, her
bayrağa nasıl ulaşıldığı ve neyi açtığı, sayıları neyin değiştirdiği,
harita görevleri, para, süreli olaylar ve final. JSON'u değiştirdikten sonra
yeniden üretmeyi unutma; testler tablonun güncel olup olmadığını kontrol
eder.

Araç üç tür sonuç verir: **HATA** oyunu bozar, **UYARI** büyük ihtimalle
bir yanlışlıktır, **NOT** ise yapılacaklar listesidir: `state.json`'da
planlanmış ama henüz hiçbir şeyin açmadığı bayraklar ve açılan ama henüz
hiçbir şeyin beklemediği "tohum" bayraklar.

Geliştirirken Settings'teki **Hikâye yazarı** bölümü işini kolaylaştırır:

- **Hızlı görevler** harita görevlerini ve süreli olayları 30 kat hızlandırır.
- **Hikâye durumu** bütün sayıları ve bayrakları gösterir. Sayıları
  artırıp azaltabilir, planlanmış bayrakları açıp kapatabilir (örneğin
  komiseri görevden uzaklaştırıp Poltel'in kilitlendiğini görebilir) ve
  finali o anki seçimlerle önizleyebilirsin.
- **Reset Game Progress** hikâyeyi baştan başlatır.

---

## Bayraklar: hikâyenin omurgası

Hikâye **bayraklarla** ilerler. Bayrak, `"part1Done"` ya da `"heard:adil"`
gibi serbest bir isimdir. Bir şey bayrağı **açar** (`unlocks`), başka bir
şey onu **bekler** (`requires`, `waitFor`).

Bayrak açanlar:

| Nerede | Alan |
| --- | --- |
| Sohbet seçeneği | `unlocks` |
| Harita görevi bitince | `unlocks` |
| Laboratuvar incelemesi çözülünce | `inspection.unlocks` |
| Sinstagram profili açılınca | `unlocksOnView` |
| Sesli mesaj dinlenince | `unlocksOnListen` |
| Poltel belgesi açılınca | `unlocksOnView` |
| Haber okununca | `unlocksOnRead` |
| Mail açılınca | mails.json › `unlocksOnView` |
| SMS konuşması açılınca | sms.json › `unlocksOnView` |
| Para gönderilince | bank.json › `payees` › `unlocks` |
| Süreli olayın süresi dolunca | state.json › `timers` › `unlocks` |

Açılınca, dinlenince ya da okununca açılanlar sadece **ilk seferde**
uygulanır: aynı maili ya da sesli mesajı tekrar açmak `doubt += 1`'i ikinci
kez saymaz.

Bekleyenler `requires` (hepsi açık olmalı) ve `requiresAny` (en az biri açık
olmalı) alanlarını kullanır. İkisi de tek bir isim ya da isim listesi olabilir:

```json
"requires": "part1Done"
"requires": ["part1Done", "toxicology"]
"requiresAny": ["heard:adil", "furkanStatement"]
```

Koşulu olmayan her şey oyunun başından görünür.

### Olumsuzlama, sayılar ve karşılaştırma

Koşullarda bir bayrağın başına `!` koymak "bu bayrak açık değilse"
demektir. Sayılar `>=`, `<=`, `>`, `<`, `==`, `!=` ile karşılaştırılır:

```json
"requires": ["part1Done", "!status:suspended"]
"requiresAny": ["trust:Özge >= 70", "witness:protected"]
```

`unlocks` listesi de sadece bayrak açmaz:

| Yazım | Ne yapar |
| --- | --- |
| `"bayrak"` | Bayrağı açar |
| `"!bayrak"` | Bayrağı kapatır, ör. `"!status:suspended"` göreve iade |
| `"trust:Özge += 10"` | Sayıyı artırır |
| `"pressure -= 5"` | Sayıyı azaltır |
| `"integrity = 50"` | Sayıyı ayarlar |

```json
{"label": "Atakan'ı koru", "unlocks": ["trust:Atakan += 15", "trust:İnanç -= 10", "player:dirty-hands"]}
```

Sayılar `state.json`'da tanımlanır. İki tür sayı kendiliğinden vardır ve
sadece okunabilir:

- `trait:merhamet`, `trait:öfke`...: o kişilik özelliğinin puanı.
- `paid:<alıcı>`: o alıcıya gönderilen toplam para, **lira** cinsinden.

Bir karakterin güveni oyuncuya hiçbir zaman gösterilmez; sonuçları
sohbetlerde hissedilmeli. Örneğin Özge'nin bir sırrı söylediği düğüm
`"waitFor": ["part1Done", "trust:Özge >= 70"]` ile bekleyebilir; aynı bilgiye
güven düşükse başka bir yoldan (`requiresAny`) ulaşılabilmeli.

Yönlendirmeden keşif hissi için: bir ipucunu birden fazla yoldan
ulaşılabilir yap (`requiresAny`) ve oyuncuya neyi nerede arayacağını
söyleme. Rapor ve mesajlar sadece "orada bir şey var" demeli.

---

## chats.json: MatesApp sohbetleri

Anahtar kişinin rehberdeki adıdır (`assets/contacts/contacts.json`).

```json
"Orhun": {
  "history": [
    {"day": 5},
    {"in": "İmza işini hallettim amirim."},
    {"out": "tmmdır"},
    {"label": "10 Nisan"}
  ],
  "start": "start",
  "nodes": {
    "start": {
      "waitFor": "part1Done",
      "incoming": ["Amirim, Özgeyle konuşmuşsunuz sanırım."],
      "options": [
        {
          "label": "Klavyede görünen metin",
          "message": "Gönderilen metin (verilmezse label)",
          "replies": ["Karşı tarafın yanıtları, birer saniye arayla"],
          "next": "sonrakiDugum",
          "traits": ["merak"],
          "unlocks": ["orhunDone"]
        }
      ]
    }
  }
}
```

- `history`: oyun başlamadan önceki mesajlar. `in` gelen, `out` giden,
  `day` "N gün önce" ayracı (0 = bugün), `label` serbest tarih ayracı.
- `waitFor` / `waitForAny`: düğüm, bayrak açılana kadar bekler. Açılınca
  `incoming` mesajları gelir ve oyuncu yanıt verebilir. Böylece bir kişi,
  başka bir yerde bir şey olunca yazmaya başlar.
- `next` yoksa sohbet o seçenekte biter. Sonra devam edecekse, `next` ile
  `waitFor`'lu bir düğüme bağla (örnek: Özge'nin `afterMezbaha` düğümü).
- `options` olmayan düğüm sadece mesajlarını gönderir ve biter.
- `traits`: kişilik puanı. `öfke`, `merhamet`, `merak`, `cesur`,
  `umursamaz`, `temkinli`.
- `silent: true`: hiçbir şey göndermez, ör. `"label": "(Cevap verme)"`.
- `requires` / `requiresAny`: seçenek sadece koşul tutarken klavyede
  görünür. Örnek: `"label": "Plakayı kime sorgulattın?", "requires": "plate:mv"`.
- `testimony`: sorgularda şüphelinin cevabı. Bu seçenekler, `testimonyFrom`
  ile o sohbete bağlanan ifade tutanağına soru-cevap olarak yazılır.

### Sorular (`ask`): ekiple düzenli konuşmak

Sohbet bir düğümde beklerken (bir bayrak için ya da son mesajdan sonra)
oyuncu karşı tarafa soru sorabilir. Sorular sohbeti ilerletmez; sadece
cevaplanır. Koşullu yazılınca hikâye ilerledikçe yeni sorular açılır:

```json
"later": {
  "waitFor": "mezbaha-found",
  "incoming": ["Amirim... mezbahadaki fotoğraflardaki iki öğrenciyi tanıdık."],
  "options": [...],
  "ask": [
    {"label": "Basın ne diyor?", "requires": "part1Done",
     "replies": ["Kapıda iki muhabir bekliyor amirim."]},
    {"label": "Toksikoloji sonucunu gördün mü?", "requires": "toxicology",
     "replies": ["Gördüm amirim. Çocuğu önce bayıltmışlar."],
     "unlocks": ["trust:Özge += 5"]}
  ]
}
```

- Bir soru sorulunca kaybolur. Tekrar sorulabilsin istiyorsan `"once": false`.
- `waitFor` açılıp karşı taraf yazınca sorular, oyuncu cevabını verene kadar
  gizlenir.
- Her ekip üyesinin sohbeti bir "bekleme" düğümünde bitmeli: ya bir sonraki
  gelişmeyi bekleyen (`waitFor` + `incoming`) ya da sadece `ask` içeren bir
  düğüm. Böylece oyuncu her zaman bir şey sorabilir.
- Hiçbir şey içermeyen düğüm (`{}`) sohbetin sonudur.

### Olaylar (`events`): karşı taraf kendiliğinden yazar

Bir sohbet tek hat üzerinde ilerler, ama bazı kişiler hikâyenin farklı
yerlerinde olanlara, hangi sırayla olursa olsun tepki vermeli. Örneğin Erdi,
her sızıntı haberinde ayrı ayrı kızar. Bunun için bir "masa" düğümü kur;
olaylar oradan ilgili düğüme gider, o düğümün seçenekleri de masaya döner:

```json
"desk": {
  "ask": [...],
  "events": [
    {"requires": ["pressure:erdi", "toxicology"], "next": "leakTox"},
    {"requires": "plate:mv", "next": "leakPlate"},
    {"requiresAny": ["pressure:refused", "bribe:returned"], "next": "warning"}
  ]
},
"leakTox": {
  "incoming": ["Kim sızdırıyor bunları?"],
  "options": [{"label": "Bizden değil müdürüm.", "next": "desk"}]
}
```

- Sohbet bu düğümde beklerken (oyuncunun vereceği bir cevap yokken) bir
  olayın koşulu tutarsa sohbet o düğüme geçer ve karşı taraf yazar. Bildirim
  de çıkar.
- Her olay bir kez gerçekleşir. Aynı anda birden fazlası tutarsa listedeki
  sıraya göre, biri bitince diğeri gelir.
- Aynı anda gelen mesajlar oyunda birkaç saniye arayla tek tek düşer, her
  biri kendi bildirimiyle; o sırada sohbet listesinde "yazıyor..." görünür.
  Oyuncu sohbeti açarsa kalanları orada yazılarak gelir. Yazarken bir şey
  yapman gerekmez.

### Rehberde olmayan kişiler

MatesApp sadece içinde mesaj olan sohbetleri listeler; kimse yazmadan bir
kişi listede görünmez. chats.json'daki anahtar rehberde
(`assets/contacts/contacts.json`) yoksa sohbet o adla görünür. Bu yüzden
anahtar bir telefon numarası da olabilir: milletvekilinin gizli numarası gibi
(`"0532 190 19 07"`).

## documents.json: Poltel belgeleri

```json
{
  "id": "yusuf", "type": "statement", "title": "Yusuf Kasap - İfade Tutanağı",
  "requires": "part1Done", "daysBeforeFirstOpen": 2,
  "name": "Yusuf Kasap", "idNumber": "354893428", "education": "Lisans",
  "maritalStatus": "Bekar", "gender": "Erkek", "takenBy": "Atakan Kutay",
  "qa": [{"q": "Soru", "a": "Cevap"}]
}
```

`qa` yerine `"testimonyFrom": "Doğa"` verilirse sorular o sohbetten gelir.

Raporlar (otopsi, toksikoloji...) `"type": "report"` ile yazılır; `authority`
sayfanın başındaki kurum adı, `heading` başlık, `lines` ise sırasıyla
`heading`, `subheading`, `field` ("Etiket: değer"), `paragraph` ve
`conclusion` satırlarıdır. Metindeki `{tarih}` belgenin tarihine dönüşür.

`daysBeforeFirstOpen`: belgenin tarihi, oyunun ilk açıldığı günden kaç gün
önce olduğu.

`category` belgenin Poltel'de hangi bölümde duracağını belirler:

| `category` | Bölüm |
| --- | --- |
| `case` (varsayılan) | Berat Yılmaz dosyası |
| `personnel` | Personel sicilleri |
| `internal` | İç denetim / disiplin soruşturmaları |

Sicil ve iç denetim belgelerinin altında "Bu belgeye erişiminiz kayıt altına
alındı" yazar. Erişimi gerçekten kayda geçirmek için `unlocksOnView` kullan:
`"unlocksOnView": ["poltel:atakan-file-read"]`. Görevden uzaklaştırma
soruşturmasında bu bayrak oyuncunun aleyhine kullanılabilir.

Sicil kayıtları gerçeği açıklayan sihirli belgeler olmamalı: amirin
değerlendirmesi yanlış, önyargılı ya da kasıtlı olabilir.

## map.json: Harita ve görevler

```json
{
  "image": "assets/story/images/city_map.png",
  "officers": ["Atakan", "Doğa", "Orhun", "İnanç"],
  "locations": [
    {
      "id": "cafe", "name": "Kampüs Kafe", "description": "...",
      "x": 0.66, "y": 0.27, "requires": "part1Done",
      "tasks": [
        {
          "id": "cafe-cctv", "label": "Kamera kayıtlarını iste", "minutes": 3,
          "requires": "cafe:witness",
          "report": "Subayın geri dönünce yazdığı rapor.",
          "unlocks": ["ev:cctv"]
        }
      ]
    }
  ]
}
```

- `officers` sadece isim olabileceği gibi koşullu da yazılabilir. Koşulu
  tutmayan subay "Ulaşılamıyor" görünür. Örnek: görevden uzaklaştırılan
  komisere sadece ona güvenenler yardım eder:
  `{"name": "Atakan", "requiresAny": ["!status:suspended", "trust:Atakan >= 60"]}`
- `x`, `y`: harita görselinde konum, 0 ile 1 arasında (sol üst 0,0).
- Bir subay aynı anda tek görevde olabilir; görev gerçek zamanla sürer
  (`minutes`, ondalık olabilir).
- Görevler `requires` açılana kadar görünmez.

## evidence.json: Delil Panosu ve laboratuvar

```json
{
  "id": "glass", "name": "Bardaktaki Parmak İzi", "description": "...",
  "image": "assets/...", "requires": "ev:glass", "links": ["torn-photo"],
  "inspection": {
    "type": "fingerprint", "instructions": "...",
    "options": ["Furkan Şahin", "Adil Karaca"], "answer": "Adil Karaca",
    "result": "Laboratuvarın vardığı sonuç.", "unlocks": ["print:adil"]
  }
}
```

İnceleme türleri:

| `type` | Oyun | Ek alanlar |
| --- | --- | --- |
| `jigsaw` | Yırtık parçaları yer değiştirerek birleştir | `rows`, `cols` (varsayılan 3), `image` gerekli |
| `fingerprint` | Olay yeri izini kayıtlı izlerle eşleştir | `options`, `answer` |
| `uv` | UV lambayla gizli yazıyı bul | `hiddenText`, `image` gerekli |

`links`: panoda kırmızı iple bağlanacak diğer deliller.

### Şifreli satır (`code`)

Bir delilin üzerinde şifreli bir satır olabilir. Oyuncu onu AppShop'taki
Şifre Çözücü ile çözünce oyun bunu kendisi fark eder ve `unlocks` uygulanır
(bir kez). Ardından bir sohbette `requires` ile o bayrağı bekleyen bir soru
açılabilir: "Şifreyi çözdüm".

```json
{"id": "notebook", "description": "... anlamsız bir satır var: IGI EÜEHM EĞREHMR. ÖEÜHIYN FNPNÇŞÜ.",
 "code": {"cipher": "caesar", "shift": 5, "text": "ECE ARADI AÇMADIM. KARDEŞİ BİLİYOR.",
          "unlocks": ["decoded:notebook"]}}
```

- `cipher`: `caesar` (Sezar, `shift` kadar kaydırma), `atbash`, `morse` ya da
  `reverse` (tersten).
- `text`: satırın çözülmüş hâli. Şifreli hâlini `description`'a sen yaz;
  doğrulayıcı doğru yazılıp yazılmadığını kontrol eder ve yanlışsa olması
  gerekeni söyler.
- Satır, delil bulunmadan tanınmaz. Pano'da açıklama seçilebilir, oyuncu
  satırı kopyalayıp Şifre Çözücü'ye yapıştırabilir.
- Oyuncu uygulamayı bilmiyor olabilir: state.json › `hints` ile AppShop'tan
  bir hatırlatma gönder (`hint-cipher`).

## sinstagram.json

- `feed`: ana akış. Büro ve rastgele kişilerin gönderileri.
- `profiles`: sadece **arayınca** bulunan hesaplar (şüpheliler). `requires`
  aranabilir olma koşuludur. Yorumdaki bir kullanıcı adına dokunmak profili
  koşuldan bağımsız açar; oyuncu ipucunu kendi bulmuş sayılır.
  `private: true` gizli hesap, `unlocksOnView` profil açılınca bayrak açar.

```json
{"handle": "furkan.shn", "name": "Furkan Şahin", "bio": "🍃",
 "followers": 367, "following": 590, "requires": "part1Done",
 "posts": [{"id": "furkan-debt", "caption": "...", "likes": 12, "daysAgo": 6,
            "comments": [{"author": "adil.abi", "text": "👀"}]}]}
```

## state.json: Sayılar, kilitler ve süreli olaylar

```json
{
  "stats": {
    "trust:Özge": {"label": "Özge'nin komisere güveni", "start": 50, "min": 0, "max": 100}
  },
  "flags": {
    "status:suspended": "Komiser görevden uzaklaştırıldı"
  },
  "locks": [
    {"app": "Poltel", "lockedWhenAny": ["status:suspended", "status:dismissed"],
     "title": "Erişim askıya alındı", "message": "..."}
  ],
  "timers": [
    {"id": "witness-leaves", "when": "heard:witness", "minutes": 30,
     "unless": "witness:questioned", "unlocks": ["witness:gone"],
     "alert": {"app": "MatesApp", "title": "Orhun", "body": "Tanık şehirden ayrılmış amirim."}}
  ]
}
```

- `stats`: hikâyenin tuttuğu sayılar. `min`/`max` verilirse değer bu
  aralıkta kalır. `label` sadece yazarlar içindir.
- `milestones`: ana yolun aşamaları sırayla (`{"flag": "part1Done", "title":
  "..."}`). Hikâye şemasının en başındaki "Ana yol" tablosu bunlardan çıkar.
- `flags`: bayrakların anlamları. Şemada "Anlamı" sütununda görünür. Burada tanımlı bir
  bayrağı bekleyen ama henüz hiçbir şeyin açmadığı yerler hata değil NOT
  olarak raporlanır; iskeleti önceden kurup sonra doldurabilirsin.
- `locks`: koşul tutarken bir uygulamayı kilitler. `app`, ana ekrandaki adı
  (Poltel, Harita, ZaferBank...). Kilit açılınca uygulama kendiliğinden
  geri gelir.
- `timers`: `when` tutmaya başladığında süre başlar; `minutes` dolunca
  `unlocks` uygulanır ve isteğe bağlı `alert` bildirimi çıkar. Süre dolmadan
  `unless` tutarsa olay iptal olur. Sadece **oyun içinde geçen süre**
  sayılır: oyuncu telefonu kapatınca süre durur, kimse uygulamayı kapattığı
  için tanığını kaybetmez.

### İpuçları (`hints`)

Sohbet dışında oyuncunun kendisinin başlatması gereken, kolayca gözden kaçan
seçenekler için (ör. ZaferBank'tan para göndermek). `when` tutmaya başladıktan
`minutes` sonra, `unless` hâlâ tutmuyorsa tek bir bildirim gelir:

```json
"hints": [
  {"id": "hint-bribe-return", "when": "mp:wrote", "minutes": 10,
   "unless": "sent:bribe-return", "app": "ZaferBank",
   "title": "Hesabınıza 50.000 TL geldi", "body": "... geri gönderebilirsiniz."}
]
```

Süreli olaylar gibi sadece oyun süresi sayılır, ama ipuçları hiçbir bayrak
açmaz. Oyuncu Settings › İpucu bildirimleri'ni kapatırsa gelmez. `unless`
yazmayı unutma: yoksa oyuncu seçeneği kullanmış olsa da ipucu gelir.
Kimlikler `timers` ile ortaktır, aynısı iki kez kullanılamaz.

## news.json: News uygulaması

```json
{
  "outlets": [{"id": "sehir-postasi", "name": "Şehir Postası", "color": "#B71C1C"}],
  "articles": [
    {"id": "old-case", "outlet": "sehir-postasi", "archive": true, "daysAgo": 1100,
     "title": "...", "summary": "...", "author": "Selin Aras",
     "body": ["Paragraf 1", "Paragraf 2"],
     "tags": ["takipsizlik", "öğrenci"], "unlocksOnRead": ["news:old-case-found"]}
  ]
}
```

- `archive: false` (varsayılan) haberler koşulu açılınca **Gündem**'e düşer ve
  bildirim çıkarır: medyanın olayı nasıl anlattığını gösterir. Hikâye
  haberleri Gündem'in en üstündeki **Manşet** bölümünde durur, zamansız
  haberler altındaki "Diğer haberler"de; böylece komik haberler davayı
  gömmez.
- `archive: true` haberler sadece **Arşiv** aramasında bulunur. Arama başlık,
  özet, metin, yazar, gazete adı ve `tags` içinde yapılır. Oyuncunun
  aklına gelebilecek kelimeleri `tags`'e ekle.
- `date` verilirse `daysAgo` yerine o yazı gösterilir ("14 Mart 2021").
- `dayOffset` verilirse haber, oyunun ilk açıldığı günden o kadar gün sonra
  `hour`'da (varsayılan 9) yayımlanır ve bildirim çıkarır:
  `"dayOffset": 7, "hour": 8` bir hafta sonra sabah sekizde. `requires` ile
  birlikte kullanılırsa ikisini de bekler.
- `afterMinutes` verilirse haber, koşulu açıldıktan o kadar dakika **oyun
  süresi** sonra çıkar: basının olayı öğrenip yazması zaman alır.
  `"requires": "plate:mv", "afterMinutes": 3`.

### Zamansız haberler (`filler`)

Gündem hiç boş kalmasın diye dükkân açılışları, mahalle olayları, spor ve
komik haberler bir havuzda durur:

```json
"filler": {
  "minMinutes": 5, "maxMinutes": 14, "start": 5, "keep": 8, "pauseAfter": 4,
  "articles": [
    {"id": "cakir-kebap", "outlet": "ekspres", "title": "...", "summary": "...", "body": ["..."]}
  ]
}
```

- Oyuncu oynadıkça her `minMinutes`–`maxMinutes` dakikada bir havuzdan bir
  haber yayımlanır ve bildirim çıkarır. Telefon kapalıyken geçen süre
  sayılmaz. Aralıklar ve sıra rastgeledir.
- Oyun başladığında ilk `start` haber zaten akıştadır (son bir iki güne
  yayılmış, bildirimsiz).
- Akışta en son `keep` zamansız haber durur, eskileri düşer.
- Oyuncu News'u açmadan `pauseAfter` (varsayılan 4) zamansız haber gelince
  havuz bekler; News açılınca birkaç dakika içinde kaldığı yerden devam
  eder. `0` hiç beklemez. Hikâye haberleri beklemez.
- Havuz bitince karıştırılıp baştan yayımlanır. Aynı haber üst üste iki kez
  gelmez ve her yeniden yayın okunmamış sayılır.
- Zamansız haberlerde `archive` ve `dayOffset` kullanılmaz; `requires`
  kullanılabilir (koşulu tutmayan haberin sırası atlanır).
- Haberler yanlış, eksik ya da yönlendirilmiş olabilir. Bir gazetenin
  yazdığı her şey gerçek kabul edilmemeli.

## endings.json: Final

```json
{
  "requires": "final:ready",
  "title": "Dosya Kapandı",
  "sections": [
    {"id": "career", "title": "Komiser", "variants": [
      {"requires": "status:dismissed", "text": "Meslekten çıkarıldı."},
      {"requires": "integrity < 40", "text": "Görevde kaldı ama..."},
      {"text": "Görevine devam ediyor."}
    ]}
  ]
}
```

`requires` tutunca oyun biter ve final ekranı açılır. Final tek bir metin
değil, bölümlerden oluşur: dosya, komiserin kariyeri, tanıklar, her ekip
üyesi... Her bölüm, koşulu tutan **ilk** seçenekle anlatılır; bu yüzden en
özel durumları üste, koşulsuz yedeği en alta yaz. Böylece birkaç düzine
kısa metinle yüzlerce farklı final birleşimi çıkar.

## Diğer dosyalar

- **mails.json**: iki bölüm. Mailler kendiliğinden gelir, aşağı çekip
  yenilemek yoktur.

  ```json
  {
    "pool": {"minMinutes": 6, "maxMinutes": 16, "start": 3, "pauseAfter": 4, "mails": [
      {"id": "pizza", "sender": "pizzaci.com.tr", "subject": "Seni özledik!", "body": "..."},
      {"id": "journalist-1", "sender": "haber@gundem24.com.tr", "subject": "Görüşme talebi",
       "body": "...", "requires": "part1Done"}
    ]},
    "story": [
      {"id": "leave-cancelled", "sender": "personel.emniyet.gov.tr", "subject": "Yıllık izniniz hakkında",
       "body": "...", "requires": "part1Done", "afterMinutes": 6}
    ]
  }
  ```

  - `pool`: gündelik mailler (reklam, fatura, kargo, eski arkadaş...). Oyun
    süresinde her `minMinutes`–`maxMinutes` dakikada bir, karışık sırayla
    biri gelir; her mail bir kez gelir. İlk `start` tanesi oyun başında
    gelen kutusundadır. `requires` taşıyan mail koşulu açılana kadar
    sırasını bekler: olaylardan sonra gelen gazeteci, okur, avukat mailleri.
    Oyuncu Mail'i açmadan `pauseAfter` (varsayılan 4) gündelik mail gelince
    havuz bekler, Mail açılınca devam eder. Hikâye mailleri beklemez.
  - `story`: hikâyenin mailleri, `requires` açılınca gelir. `afterMinutes`
    ile koşuldan o kadar dakika oyun süresi sonra gelir.
  - `subject` listede ve bildirimde görünür; `id` verilmezse gönderen ve
    metinden üretilir (sonradan metni değiştirince "okundu" bilgisi
    kaybolmasın diye `id` ver).
  - Yazarın hata ayıklama sayfasında (Ayarlar › Hikâye durumu) sıradaki
    maili ya da haberi beklemeden getiren düğmeler var.
- **sms.json**: `sender`, `messages`, `daysAgo`, isteğe bağlı `requires` ya da
  `requiresAny`, `unlocksOnView`.
- **bank.json**: tutarlar **kuruş** cinsindendir (`5000000` = 50.000,00 TL),
  eksi değer ödemedir. `requires` taşıyan işlemler hikâyede gelir ve bakiyeyi
  değiştirir; taşımayanlar başlangıç bakiyesine dahildir.
  `payees` oyuncunun **Para Gönder** ile para yollayabileceği alıcılardır
  (`id`, `name`, `iban`, `note`, `requires`, `minAmount`, `unlocks`). Her
  transfer `paid:<id>` sayısına eklenir ve `sent:<id>` bayrağını açar;
  `unlocks` ise sadece en az `minAmount` kuruşluk bir transferde uygulanır.
  Transferler geri alınamaz, bakiye gerçek bir kaynaktır ve oyuncunun
  yazdığı açıklama hesap hareketlerinde kalır.
- **voicemail.json**: `kind` `voicemail` ya da `memo`; `transcript` dinlerken
  kelime kelime görünür. `audio` ile bir ses dosyası verilebilir
  (`pubspec.yaml`'daki assets listesine eklemeyi unutma).
- **calendar.json**: `dayOffset` (ilk açılıştan gün farkı) ya da her yıl
  tekrar eden `month` + `day`.

Görseller için yeni bir klasör kullanacaksan onu da `pubspec.yaml`'daki
`assets:` listesine ekle.
