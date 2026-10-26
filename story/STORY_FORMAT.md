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

Geliştirirken **Settings → Hızlı görevler** harita görevlerini 30 kat
hızlandırır, **Reset Game Progress** hikâyeyi baştan başlatır.

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

Bekleyenler `requires` (hepsi açık olmalı) ve `requiresAny` (en az biri açık
olmalı) alanlarını kullanır. İkisi de tek bir isim ya da isim listesi olabilir:

```json
"requires": "part1Done"
"requires": ["part1Done", "toxicology"]
"requiresAny": ["heard:adil", "furkanStatement"]
```

Koşulu olmayan her şey oyunun başından görünür.

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
- `testimony`: sorgularda şüphelinin cevabı. Bu seçenekler, `testimonyFrom`
  ile o sohbete bağlanan ifade tutanağına soru-cevap olarak yazılır.

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

## Diğer dosyalar

- **mails.json**: `inbox` aşağı çekince sırayla gelen sıradan mailler,
  `story` ise `requires` açılınca en üstte beliren mailler.
- **sms.json**: `sender`, `messages`, `daysAgo`, isteğe bağlı `requires`.
- **bank.json**: tutarlar **kuruş** cinsindendir (`5000000` = 50.000,00 TL),
  eksi değer ödemedir. `requires` taşıyan işlemler hikâyede gelir ve bakiyeyi
  değiştirir; taşımayanlar başlangıç bakiyesine dahildir.
- **voicemail.json**: `kind` `voicemail` ya da `memo`; `transcript` dinlerken
  kelime kelime görünür. `audio` ile bir ses dosyası verilebilir
  (`pubspec.yaml`'daki assets listesine eklemeyi unutma).
- **calendar.json**: `dayOffset` (ilk açılıştan gün farkı) ya da her yıl
  tekrar eden `month` + `day`.

Görseller için yeni bir klasör kullanacaksan onu da `pubspec.yaml`'daki
`assets:` listesine ekle.
