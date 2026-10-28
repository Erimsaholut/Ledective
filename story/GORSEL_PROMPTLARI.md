# Görsel üretim prompt'ları

[`GORSELLER.md`](GORSELLER.md) listesindeki her görsel için bir görsel
üreticiye (Midjourney, DALL·E / ChatGPT, Stable Diffusion, Flux, Ideogram,
Leonardo...) yapıştırılabilecek prompt'lar. Prompt'lar İngilizce, çünkü
üreticilerin çoğu İngilizceyle çok daha iyi sonuç veriyor. Her birinin
üstünde Türkçe kısa bir açıklama var.

## Nasıl kullanılır

1. **Stil eki:** Her prompt'un sonuna aşağıdaki stil ekini ekle. (Bazı
   prompt'larda kendi özel stili var; orada "stil eki yerine" diye belirttim.)
2. **Negatif prompt:** Araç destekliyorsa negatif prompt alanına aşağıdakini
   yapıştır. Desteklemiyorsa (ChatGPT gibi) prompt'un sonuna "Avoid: ..."
   diye ekle.
3. **Oran:** Her görselin oranı başlığında yazıyor. Midjourney'de `--ar 1:1`,
   `--ar 16:9`, `--ar 3:4`; ChatGPT'de "square / wide 16:9 / portrait 3:4"
   diye yaz.
4. **Aynı karakter, aynı yüz:** Karakterli görsellerde önce o karakterin
   **profil portresini** üret, beğendiğin sonucu referans olarak kullan
   (Midjourney: `--cref <portre bağlantısı>`; ChatGPT: portreyi yükleyip "same
   person as in the attached image"; Stable Diffusion: aynı seed ya da IP-Adapter).
   Karakter kartındaki tarifi her prompt'a aynen koy.
5. **Yazılar:** Üreticiler okunur yazıda kötüdür ve ülkeyi ele verebilir. Tüm
   prompt'larda tabela ve yazılar bilerek "okunmuyor" diye tarif edildi.
   Saat damgası gibi yazıları sonradan ben eklerim.
6. Dosyayı listedeki adla `assets/story/images/` klasörüne koy.

### Stil eki (her prompt'un sonuna)

```
candid smartphone photo, realistic, natural available light, slight sensor noise, muted desaturated colors, cold color grading, documentary photography, shallow depth of field, ordinary everyday look, no text
```

### Negatif prompt

```
readable text, letters, words, watermark, logo, brand names, signature, flags, national symbols, celebrity likeness, famous person, cartoon, anime, illustration, 3d render, CGI, plastic skin, oversaturated, HDR, glamour lighting, studio backdrop, extra fingers, deformed hands, distorted face, duplicate person, gore, visible corpse
```

### Ortak kurallar

- Bütün kişiler **kurgusal**; hiçbir ünlüye ya da gerçek kişiye benzememeli.
- Şehirle ilgili kareler Türkiye'de küçük bir taşra üniversite şehri gibi
  görünmeli (beton apartmanlar, çay bardakları, sanayi sitesi), ama hiçbir
  tabela okunmamalı.
- **Komiserin "tatil" görselleri hiçbir ülkeyi ele vermemeli.** Deniz, palmiye,
  bilinen yapı, para, yazı, plaka olmaz.

---

## Karakter kartları

Her karakterli prompt'ta ilgili kartın İngilizce tarifini aynen kullan.

| Karakter | Tarif (prompt'a kopyala) |
| --- | --- |
| **Kerem Aydın** (katil, 24) | `a 24-year-old Turkish man, lean and slightly gaunt, narrow face, short unkempt black beard, short messy black hair, dark tired eyes with shadows under them, worn black leather jacket over a dark grey hoodie, a lanyard with a plain white plastic ID card around his neck` |
| **Berat Yılmaz** (maktul, 22) | `a 22-year-old Turkish man, handsome, light stubble, styled dark brown hair with short sides, expensive dark designer clothes, silver wristwatch, confident half-smile but empty, distant eyes` |
| **Haluk Yılmaz** (milletvekili, 60) | `a 60-year-old Turkish politician, grey swept-back hair, neatly trimmed grey mustache, tailored navy suit, white shirt, dark tie, small plain lapel pin, polished public smile, tired heavy eyes` |
| **Özge** (28) | `a 28-year-old Turkish woman, plainclothes police detective, dark hair tied back in a low ponytail, no makeup, tired but sharp eyes, dark blazer over a simple sweater` |
| **Atakan Kutay** (30) | `a 30-year-old Turkish man, tall, clean-shaven, neatly styled short hair, well-fitted dark coat, handsome but evasive gaze, looks slightly guarded` |
| **Orhun** (35) | `a 35-year-old Turkish man, broad and heavy-set, full dark beard, warm friendly face, slightly rumpled checked shirt, big-brother vibe` |
| **Doğa Aksu** (27) | `a 27-year-old Turkish woman, police officer, short dark bob haircut, warm empathetic eyes, simple dark jacket` |
| **İnanç** (40) | `a 40-year-old Turkish man, very short military-style haircut, clean-shaven, upright stiff posture, serious disciplined face, plain dark jacket` |
| **Behram** (50) | `a 50-year-old Turkish man, narcotics chief inspector, salt-and-pepper hair, thick grey mustache, hard weathered face, leather jacket` |
| **Erdi** (55) | `a 55-year-old Turkish police branch director, balding with grey sides, heavy jaw, angry impatient expression, grey suit, loosened tie` |
| **Kaymakam Cevdet Arslan** (50) | `a 50-year-old Turkish district governor, neat dark grey hair, clean-shaven, immaculate charcoal suit, diplomatic polite smile that does not reach the eyes` |
| **Selin Aras** (32) | `a 32-year-old Turkish woman, investigative journalist, short dark hair, round glasses, oversized trench coat, holding a small notebook, alert curious look` |
| **Deniz Yılmaz** (23) | `a 23-year-old Turkish woman, Berat's cousin, long dark hair, pale grieving face, black clothes` |
| **Yusuf Kasap** (21) | `a 21-year-old Turkish male student, thin, glasses, hoodie, nervous expression` |
| **Furkan Şahin** (20) | `a 20-year-old Turkish male student, messy dark hair, slightly hunched, oversized hoodie, scared restless eyes` |
| **Adil Karaca** (40) | `a 40-year-old Turkish man, thick neck, heavy build, gold chain, tracksuit jacket, menacing calm` (gizli hesabında yüz görünmesin) |
| **Ece Aydın** (20, üç yıl önce) | `a 20-year-old Turkish female university student, long wavy dark hair, warm genuine smile, simple casual clothes, photo looks a few years old` |
| **Danışman** (45) | `a 45-year-old man in an expensive black overcoat, face always partly hidden, turned away or in shadow` |
| **Komiser** (oyuncu) | Yüzü asla görünmez: `seen only from behind or as hands, face never visible` |

---

## 1. Şimdi lazım olanlar

### `kerem_gizli.jpg` — Yırtık fotoğraf (yapboz) · 1:1
Ağın Kerem'i habersizce çektiği uyarı fotoğrafı. Yapboza bölüneceği için
ortada belirgin bir figür olmalı.

```
A covert surveillance photo taken from across a street with a phone: [Kerem Aydın tarifi], standing alone on a cold evening outside the plain glass entrance of a modest office building, smoking and looking sideways, unaware he is being photographed. Shot slightly from above through a car window, a blurred edge of the window frame in the foreground. Overcast dusk, sodium streetlights starting to glow. The building entrance has a small sign that is completely out of focus and unreadable. Grainy, slightly underexposed, uneasy voyeuristic feeling. Subject centered in the frame.
```

### `kamera_karesi.jpg` — Kafe güvenlik kamerası, 23.41 · 1:1
Stil eki yerine aşağıdaki güvenlik kamerası stilini kullan.

```
Low-quality CCTV security camera still, high-angle fisheye view from above a small café entrance at night. A young man in dark designer clothes [Berat] walks out quickly, looking at his phone. Two steps behind him a second man follows: lean, short black beard, black leather jacket, hoodie, a lanyard with a white ID card around his neck [Kerem], face turned slightly away and partially obscured. Wet pavement reflecting café lights, a few plastic chairs outside. Black and white with a faint green tint, heavy compression artifacts, motion blur, noise, low resolution security footage look. Leave the top-left corner empty for a timestamp. No readable text.
```

### `berat_babasi.jpg` — Berat ve milletvekili babası bir davette · 1:1
Berat'ın gönderisi: "Babam bir milletvekili ama ben kendi yolumu çizerim."

```
A candid photo at a formal evening reception in a hotel ballroom: [Haluk Yılmaz tarifi] smiles broadly and shakes hands with guests, while his son [Berat Yılmaz tarifi] stands half a step behind him holding a glass, not looking at the camera, staring off to the side with a bored, hollow expression. Warm chandelier light, blurred guests in suits in the background, no flags, no banners, no readable text. The contrast between the father's public smile and the son's emptiness is the point of the image.
```

### `tatil.jpg` — Komiserin "Tatildeyim, aramayın 🌴" gönderisi · 1:1
**Ülke kesinlikle belli olmamalı.** Gizli son için de hafif tuhaf olmalı.

```
A vacation photo taken by a man of his own bare feet resting on a white sun lounger, a glass of iced drink on a small side table, an out-of-focus swimming pool beyond. The light is oddly flat and grey for a holiday, as if overcast, and the background is so blurred that the place could be anywhere. No sea, no palm trees, no landmarks, no signs, no people, no logos on the glass. Slightly off, quiet, lonely mood despite the holiday setting.
```

### `bos_koltuk.jpg` — Atakan'ın "Amirimiz işbaşında 😂" gönderisi · 1:1

```
An empty office chair behind a cluttered police detective's desk in a Turkish police station office: case folders piled up, a half-empty tulip-shaped Turkish tea glass gone cold on a saucer, an old desk lamp, a dark jacket hanging on the chair back. Fluorescent office light, beige walls, a window with closed blinds. Funny, slightly sad emptiness, as if the boss has been gone for days.
```

### `iki_bira.jpg` — Orhun'un "Akşam iki bira kimde? 🍺" gönderisi · 1:1

```
Two cold beer glasses with foam on a worn wooden table in a modest neighborhood bar in the evening, condensation on the glasses, a small plate of roasted chickpeas and cucumber slices beside them, an ashtray, warm yellow light, blurred background of a small bar. Unbranded glasses, no labels, no readable text.
```

### `komplo.jpg` — @gizli.tarih komplo sayfası · 1:1
İnsan olmamalı (eski görsel gerçek bir kişiydi).

```
A dramatic close-up of an old weathered stone doorway with a mysterious carved triangle and an eye-like circle in the keystone, moss in the cracks, dim light, a single shaft of light hitting the carving, conspiracy-page aesthetic. No people, no readable inscriptions.
```

### `dedektif_meme.jpg` — @dedektif.memes · 1:1
"Tatildeyken bile ipucu arayan polis olmak 🔍"

```
A humorous photo of a man on a beach towel, seen from behind only, wearing a sun hat and swim shorts, intensely examining a sandcastle with a large magnifying glass while holding a small evidence bag, sunscreen bottle beside him. Bright, funny, meme-like but still a real photo. Face not visible, no recognizable beach, no text.
```

### `sergi.jpg` — @sanat.galerisi yerel sergi · 1:1

```
Interior of a small local art exhibition hall in a provincial city cultural center, white walls with large abstract paintings in earthy and dark tones, a few visitors seen from behind looking at the paintings, polished concrete floor, track lighting. Calm Saturday afternoon. Paintings are original abstract shapes, not famous artworks.
```

### `ozge_kedi.jpg` — Özge'nin kedisi Pamuk (sadece kendi kedi fotoğrafın yoksa) · 1:1

```
A fluffy orange flat-faced cat sleeping on top of a stack of police case folders on an office desk, a computer keyboard and a tea glass nearby, soft window light, cozy and funny.
```

### `behram_operasyon.jpg` — Behram'ın "Bu haftaki operasyondan" gönderisi · 1:1

```
A police press display after a narcotics operation: a long table covered with a dark cloth, rows of wrapped packages, a digital scale, bundles of cash and a few confiscated phones neatly arranged. Two plainclothes officers stand behind the table with faces cropped out of the frame. Harsh overhead light, official, slightly grim. No logos, no readable text, no flags.
```

---

## 2. Berat ve şüphelilerin Sinstagram gönderileri

### `berat_kafe.jpg` — "Okulun karşısındaki kafe, her zamanki yer ☕" · 1:1

```
A phone photo from a café table across the street from a small university campus gate: a coffee cup, an expensive phone and car keys on the table, the blurred campus gate through the window. Evening light. Feels like a young rich man's everyday spot. No readable signs.
```

### `berat_kapi.jpg` — "Bazı kapılar bir kere açılınca kapanmıyor." · 1:1
İleride mezbahayı ima ediyor; kapıyı tanıtmadan.

```
A moody night photo of a heavy rusted metal sliding door of an old industrial building, slightly ajar, darkness behind it, a single flickering light above. Taken from a distance, slightly shaky, unsettling. No people, no readable text.
```

### `furkan_borc.jpg` — Furkan: "Bazı borçlar parayla ödenmez." · 1:1

```
A dim dorm room at night: a single bed with crumpled sheets, a phone face down on a pillow, scattered coins and a few small banknotes on a desk, a hoodie thrown on a chair, light from a streetlamp through cheap curtains. Lonely and anxious mood.
```

### `yusuf_sinav.jpg` — Yusuf: "Sınav haftası. Kahve olmadan yaşanmıyor ☕" · 1:1

```
A cluttered library desk during exam week: open textbooks, highlighters, handwritten notes, three empty paper coffee cups, glasses lying on a notebook, late-night lamp light. Ordinary student life.
```

### `deniz_yas.jpg` — Deniz: "Kuzenim, sana bunu kim yaptıysa bulacağız. 🖤" · 1:1

```
A small memorial on a windowsill at night: a lit candle, a framed photo turned slightly away so the face is not visible, a few white carnations, rain on the window glass. Grief, quiet anger.
```

---

## 3. Delil ve olay yeri

### `olay_yeri.jpg` — Berat'ın salonu · 1:1
Ceset yok.

```
Crime scene photo of a rented apartment living room at night after a struggle: an overturned coffee table, broken drinking glasses on the floor, scattered cushions, a toppled lamp still lit on the floor casting long shadows, a ceiling hook visible. Yellow evidence markers with no numbers on them. Flat forensic flash lighting, cold and clinical. No body, no blood pools.
```

### `mezbaha_ic.jpg` — Mezbahanın içi · 1:1

```
Interior of an abandoned municipal slaughterhouse at night, lit only by police flashlights: cracked white wall tiles stained with old rust-brown marks, rusted meat hooks on overhead rails, a single metal chair bolted to the concrete floor in the middle, cut pieces of rope on the floor, puddles, dust floating in the flashlight beams. Terrifying, cold, silent. No people, no gore.
```

### `mezbaha_duvar.jpg` — Duvardaki tarihli fotoğraflar · 1:1

```
Close-up of a stained tiled wall inside an abandoned slaughterhouse, three small printed photographs pinned to it with rusty nails, each showing a young person's portrait too blurred and faded to recognize, below each photo a handwritten date in marker that is smudged and unreadable. Harsh flashlight beam from the side, deep shadows. Creepy, evidential.
```

### `mezbaha_dis.jpg` — Mezbahanın dışı · 16:9

```
A long abandoned single-story industrial slaughterhouse building on the outskirts of a small Turkish town at night, broken windows, weeds through cracked concrete, a rusted gate, police tape fluttering across the entrance, blue police lights reflecting on the wet ground from outside the frame. Wide shot, ominous.
```

### `cay_ocagi.jpg` — Sanayi çay ocağı · 1:1

```
A small tea house in a Turkish industrial district: a narrow counter with a double teapot on a gas burner, tulip-shaped tea glasses on saucers, an old wood-burning stove with a pipe, low plastic stools, oil-stained floor, a calendar on the wall with no readable text. Afternoon light through a dusty window, empty, slightly sinister.
```

### `makam_araci.jpg` — Plakası okunmayan siyah sedan · 1:1

```
A long-lens surveillance photo at dusk of a black government-style luxury sedan parked beside a small tea house in an industrial area, rear window tinted, a figure in the back seat barely visible as a silhouette, the license plate blurred and unreadable. Shot through a dirty windshield, grainy, voyeuristic.
```

### `burs_sozlesmesi.jpg` — Burs sözleşmesi · 3:4
Yazıları ben de üretebilirim. Görseli sadece kâğıt dokusu için kullanacaksan:

```
A single printed contract page lying on a dark wooden desk, slightly crumpled, a paragraph underlined twice in red pen, a signature line at the bottom, a coffee ring stain in the corner, harsh desk lamp light from the side. The text is too small and blurred to read.
```

### `kayip_ilani_1.jpg`, `kayip_ilani_2.jpg` — Kayıp ilanları · 3:4
İkisi için ayrı öğrenci: biri genç kadın, biri genç erkek.

```
A faded missing person poster taped to a concrete wall at a bus stop, partially torn and rained on, a printed photo of a [young Turkish female university student with shoulder-length hair / young Turkish male university student with short hair] in the middle, large blurred header text, tear-off phone number strips at the bottom with some strips missing. Street light at night. The text is unreadable.
```

---

## 4. Kişi portreleri (profil fotoğrafı)

Hepsi 1:1, yüz ortada, omuzlardan yukarısı. Aşağıdaki şablona karakter
kartındaki tarifi ve bir ortam koy. Önce bunları üret; diğer karakterli
görsellerde bunları referans olarak kullan.

```
Casual social media profile photo of [karakter tarifi], [ortam], looking at the camera, natural expression, head and shoulders, centered, phone camera, soft natural light.
```

| Karakter | Ortam önerisi |
| --- | --- |
| Özge | `sitting in a parked car at night, streetlight on her face` |
| Atakan Kutay | `on a city street at dusk, collar up` |
| Orhun | `at a neighborhood tea garden, laughing` |
| Doğa Aksu | `in a police station corridor, soft fluorescent light` |
| İnanç | `standing outside a police building, rigid posture` |
| Behram | `in front of a dark office window, unsmiling` |
| Erdi | `in a formal office with a desk behind him, stern` |
| Kaymakam Cevdet Arslan | `official portrait in a government office, polite smile` |
| Haluk Yılmaz | `official parliamentary-style portrait, neutral background, no flag` |
| Berat Yılmaz | `leaning on a black car at night, smirking` |
| Deniz Yılmaz | `on a university campus, not smiling` |
| Yusuf Kasap | `in a campus library` |
| Furkan Şahin | `outside a café at night, hood half up` |
| Adil Karaca | **Yüzsüz:** `photo of only a thick hand with a gold ring holding a tea glass, a gold chain visible on the wrist, face not visible` |
| Ece Aydın | `on a sunny campus lawn three years ago, laughing, slightly faded photo` |
| Selin Aras | `in a newsroom, holding a notebook` |
| Danışman | `walking away from the camera in a black overcoat, face not visible` |
| Komiser | `hands holding a phone in a dark room, only the hands and the screen glow, face never visible` |

---

## 5. Haberler (News) · 16:9

Haber fotoğrafı havasında: stil ekinin sonuna `press photo, photojournalism` ekle.

### `haber_berat_bulundu.jpg`
```
Night press photo of police tape across the entrance of an ordinary five-story apartment building in a small Turkish city, police car lights reflecting on the wet street, a few neighbors watching from balconies, no faces clear.
```

### `haber_cenaze.jpg`
```
A crowded funeral in a hillside cemetery on a grey day, mourners in black, many umbrellas, men in suits around a coffin, photographed from a distance, no faces clear, no religious or political banners with text.
```

### `haber_milletvekili.jpg`
```
[Haluk Yılmaz tarifi] speaking to the press outside a building, a cluster of microphones without logos in front of him, flashes going off, photographed from a distance so his face is small and slightly blurred.
```

### `haber_yuruyus.jpg`
```
A silent march of university students on a campus walkway at dusk, holding candles and blank white placards, sad faces in the crowd, some placards showing printed photos too small to recognize.
```

### `haber_mezbaha.jpg`
```
Several police cars and a forensic van parked outside an abandoned industrial building at night, officers with flashlights at the entrance, police tape, long-lens press photo from behind a barrier.
```

### `haber_plaka.jpg`
```
Long-lens press photo of a black luxury sedan driving away from a small industrial street, license plate blurred, dust in the air, late afternoon.
```

### `haber_vakif.jpg`
```
The modern glass-and-stone facade of a charity foundation building in a provincial Turkish city, a large sign above the entrance completely out of focus and unreadable, a few students with backpacks walking in, overcast sky.
```

### Gündelik haberler (isteğe bağlı)
| Dosya | Prompt |
| --- | --- |
| `haber_kebap.jpg` | `A long queue of people outside a newly opened small kebab restaurant on a Turkish street, balloons at the door, a cook in white working at a grill in the window, cheerful, no readable signs` |
| `haber_kiraathane.jpg` | `Old men playing okey with tiles at a crowded traditional Turkish coffee house, tea glasses, cigarette smoke, one man frowning at the board, humorous tension` |
| `haber_avm.jpg` | `A ribbon-cutting ceremony at a new shopping mall, men in suits standing on an escalator looking confused, the escalator clearly moving down, funny moment, no logos` |
| `haber_kampus_kedi.jpg` | `A fluffy cat asleep in a large leather chair at the head of a formal meeting table in a university senate room, empty chairs around, funny` |
| `haber_firin.jpg` | `A small artisan sourdough bakery opening day, rustic loaves in the window, a long handwritten rules list on the door too blurry to read, people waiting` |

---

## 6. Komiserin galerisi (Fotoğraflar uygulaması)

Karışık, sıradan kareler; **tatil fotoğrafı yok.**

| Dosya | Prompt |
| --- | --- |
| `galeri_dosyalar.jpg` | `A phone photo of a stack of case files and a cold tea glass on a police desk late at night, a pen and reading glasses on top` |
| `galeri_kahve.jpg` | `A paper coffee cup and a phone on a car dashboard at dawn, foggy windshield, blurred street outside` |
| `galeri_ekran.jpg` | `A slightly crooked photo of a computer monitor in a dark office showing a blurred spreadsheet, taken with a phone, moiré pattern` |
| `galeri_olay_yeri.jpg` | `A distant phone photo of a police cordon at night in a residential street, taken from inside a car` |
| `galeri_karanlik_oda.jpg` | [?] Gizli son ipucu: `A dim room with heavy curtains completely closed during the day, a thin line of daylight at the edge, an unmade single bed, a pill organizer on the nightstand, the location impossible to tell` |
