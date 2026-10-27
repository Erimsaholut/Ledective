# Görsel listesi

Oyundaki görsellerin çoğu test için konmuştu. Bir kısmı dizi ve film kareleri
ya da gerçek kişilerin fotoğrafları; bunlar kullanılamaz. Bu liste neyin
değişmesi, neyin eklenmesi gerektiğini ve her görselin nasıl olması
gerektiğini anlatıyor.

Getirdiğin görselleri `assets/story/images/` altına, aşağıdaki **dosya adı**
sütunundaki adlarla koyman yeterli. Bağlantılarını ben yaparım.

## Kurallar

- **Kaynak:** Kendi çektiğin fotoğraflar, izinli fotoğraflar, ücretsiz lisanslı
  stok fotoğraflar (Unsplash, Pexels) ya da yapay zekâ ile üretilmiş görseller.
  Dizi ve film karesi, haber fotoğrafı, ünlü ya da tanınabilir gerçek kişi olmaz.
- **İnsanlar:** Kendi fotoğraflarında tanıdık biri varsa iznini al. Stok
  fotoğraflarda yüz göründüğü sürece sorun yok, ama aynı karakter için hep aynı
  kişiyi kullan ki oyuncu tanıyabilsin.
- **Ülke gizli kalmalı:** Komiserin "tatil" görsellerinde ülkeyi ele veren
  hiçbir şey olmasın: tabela, yazı, plaka, para, bilinen bir yapı. "Hiç yurt
  dışında değildi" gizli sonu için en iyisi her yere uyabilecek, kapalı ve
  biraz tuhaf kareler (perdesi kapalı otel odası, bulanık bir havuz).
- **Şehir Türkiye'de:** Şehirle ilgili kareler (kafe, sanayi, kampüs, çay
  ocağı) Türkiye'de bir taşra üniversite şehri gibi görünmeli.
- **Ton:** Karanlık, gerçekçi, telefonla çekilmiş gibi. Parlak stok fotoğraf
  havası olmasın.
- **Boyut:** En az aşağıdaki çözünürlük. Daha büyük olabilir; ben küçültürüm.
  JPG ya da PNG.

| Kullanıldığı yer | Oran | En az |
| --- | --- | --- |
| Sinstagram gönderisi, Pano kartı | Kare (1:1) | 1080 × 1080 |
| News haberi | Yatay (16:9) | 1600 × 900 |
| Laboratuvar: yapboz | Kare (1:1) | 1200 × 1200 |
| Laboratuvar: UV lamba | Dikey (3:4) | 1200 × 1600 |
| Profil fotoğrafı | Kare, yüz ortada | 600 × 600 |
| Fotoğraflar uygulaması | Herhangi | 1200 kenar |

## 1. Hemen değişmesi gerekenler

Bunlar şu an oyunda görünüyor ve kullanılamaz.

| Şu anki dosya | İçeriği | Nerede görünüyor | Yerine ne lazım | Yeni dosya adı |
| --- | --- | --- | --- | --- |
| `my_foto1.jpg` | Behzat Ç. dizi karesi | Sinstagram (@dizi.replikleri), Fotoğraflar | Gönderi ve görsel kaldırılacak; yerine bir şey gerekmez | — |
| `my_foto2.jpg` | Behzat Ç. dizi karesi (silahlı) | Fotoğraflar | Kaldırılacak | — |
| `babba.jpeg` | Baba filmi karesi | Sinstagram (@berat.ylmz: "Babam bir milletvekili ama ben kendi yolumu çizerim") | Berat ile babası bir resmî davette; Berat kameraya bakmıyor, babası kalabalığa gülümsüyor | `berat_babasi.jpg` |
| `freeMason.jpg` | Gerçek bir kişi (mason locası) | Sinstagram (@gizli.tarih) | Komplo sayfası için anonim bir sembol: eski bir taş kapı üstünde üçgen kabartma, insan yok | `komplo.jpg` |
| `aaa.jpg` | Müfettiş Gadget çizgi filmi | Sinstagram (@atakan.kutay: "Amirimiz işbaşında 😂") | Komiserin boş ofis koltuğu; masada soğumuş çay, sandalyeye asılı ceket | `bos_koltuk.jpg` |
| `kadr.jpeg` | Dizi karesi (bereli adam) | **Kamera Görüntüsü delili**, Sinstagram (@orhun.k: "Akşam iki bira kimde?"), Fotoğraflar | İki ayrı görsel: kamera karesi (aşağıda, Kerem) ve Orhun için masada iki bira bardağı | `kamera_karesi.jpg`, `iki_bira.jpg` |
| `kadr2.jpeg` | Dizi karesi (sakallı genç) | **Yırtık Fotoğraf yapbozu**, Fotoğraflar | Kerem'in habersiz çekilmiş fotoğrafı (aşağıda) | `kerem_gizli.jpg` |
| `my_foto4.jpg` | Stok dedektif (büyüteç) | Sinstagram (@komiser: "Tatildeyim, aramayın 🌴"), Fotoğraflar | Komiserin "tatil" fotoğrafı: kurallardaki ülke uyarısına dikkat | `tatil.jpg` |
| `my_foto5.jpg` | Stok dedektif (büyüteç) | Sinstagram (@dedektif.memes) | Komik bir polis/dedektif meme'i: tatilde güneş kremiyle masaya parmak izi tozu döken biri gibi | `dedektif_meme.jpg` |
| `1500x500.jpeg` | Tanınmış bir ressamın tablosu olabilir | Sinstagram (@sanat.galerisi) | Bir yerel sergi salonu: duvarlarda soyut tablolar, birkaç ziyaretçi sırtı dönük | `sergi.jpg` |

**Senin fotoğrafların olabilecekler** (kullanılabilir, emin ol):

| Dosya | İçeriği | Nerede görünüyor | Not |
| --- | --- | --- | --- |
| `benKedi.jpeg`, `myCat.jpeg` | Turuncu bir kedi | Özge'nin kedisi Pamuk, @kedi.dunyasi | Senin kedinse kalsın |
| `gungun.jpeg` | Vitrinde tabancalar | @behram_narkotik: "Bu haftaki operasyondan" | Senin çektiğinse kalabilir; daha iyisi masaya dizilmiş ele geçirilmiş paketler ve terazi |

## 2. Delil ve olay yeri görselleri

| Dosya adı | Ne gösteriyor | Oran | Öncelik |
| --- | --- | --- | --- |
| `kerem_gizli.jpg` | **Yırtık fotoğraf.** Kerem, ondan habersiz uzaktan çekilmiş: sokakta, deri ceketli, sakallı, yan profil. Arkada bir binanın girişi (vakıf). Telefonla, biraz gizlice çekilmiş gibi. | Kare | Şimdi |
| `kamera_karesi.jpg` | **Kafe dış kamerası, 23.41.** Siyah beyaz ya da yeşilimsi, karlı güvenlik kamerası görüntüsü. Önde aceleyle çıkan bir genç (Berat), arkasında deri ceketli, boynunda kartlık olan biri (Kerem). Yüzler net değil. Köşede saat yazısını ben eklerim. | Kare | Şimdi |
| `olay_yeri.jpg` | Berat'ın salonu: devrilmiş sehpa, kırık bardaklar, dağınıklık. Ceset yok. | Kare | Sonra |
| `mezbaha_ic.jpg` | Mezbahanın içi: karo duvarlar, ortada yere vidalanmış bir sandalye, kesik ipler, el feneri ışığı. | Kare / 16:9 | Sonra |
| `mezbaha_duvar.jpg` | Duvara iğnelenmiş üç fotoğraf, altlarında el yazısıyla tarihler. Fotoğraflardaki yüzler bulanık. | Kare | Sonra |
| `mezbaha_dis.jpg` | Gece, terk edilmiş tek katlı bir sanayi binası, kırık camlar, polis şeridi. | 16:9 | Sonra |
| `cay_ocagi.jpg` | Sanayide bir çay ocağı: tezgâh, soba, plastik tabureler. | Kare | Sonra |
| `makam_araci.jpg` | Gece, uzaktan çekilmiş siyah bir sedan; plaka okunmuyor. | Kare | Sonra |
| `burs_sozlesmesi.jpg` | Kâğıt bir sözleşme sayfası, "geri ödeme" maddesinin altı çizilmiş. (İstersen ben de üretebilirim.) | 3:4 | Sonra |
| `kayip_ilani_1.jpg`, `kayip_ilani_2.jpg` | Duvara yapıştırılmış, eskimiş kayıp ilanları; birer öğrenci fotoğrafı. | 3:4 | Sonra |

Not: `city_map.png`, `notebook_page.png` ve `torn_map.png` görsellerini ben
ürettim ve telif sorunları yok. İstersen gerçek fotoğraflarla
değiştirebiliriz: defter sayfası (3:4, boş satırlı, kalemle karalanmış),
yarısı yanmış basılı bir şehir haritası (kare).

## 3. Kişiler

Profil fotoğrafı (kare, yüz ortada) ve bazılarının Sinstagram gönderileri
için. Aynı kişiyi her yerde aynı modelle kullan. "Öncelik: Sonra" olanlar
profil fotoğrafı desteği gelince lazım olacak.

| Karakter | Görünüş | Nerede | Öncelik |
| --- | --- | --- | --- |
| **Komiser** (oyuncu) | Yüzü hiç görünmemeli. Sadece eller, sırt, gölge. | Profil, tatil kareleri | Sonra |
| **Özge** | 28-30, kadın komiser yardımcısı. Toplu saç, sade, yorgun ama dikkatli. | Profil, kedili gönderi | Sonra |
| **Atakan Kutay** | 30, uzun boylu, düzgün tıraşlı, şık, biraz kaçamak bakışlı. | Profil | Sonra |
| **Orhun** | 35, iri yapılı, sakallı, samimi; mahalle abisi tavrı. | Profil | Sonra |
| **Doğa Aksu** | 27, kadın polis, kısa saç, sıcak bakış. | Profil | Sonra |
| **İnanç** | 40, asker tıraşı, düz duruş, ciddi. | Profil | Sonra |
| **Behram** | 50, kır saçlı, bıyıklı, sert yüzlü narkotik başkomiseri. | Profil, operasyon gönderisi | Sonra |
| **Erdi** | 55, şube müdürü, takım elbise, kızgın bir yüz. | Profil | Sonra |
| **Kaymakam Cevdet Arslan** | 50, düzgün takım, protokol gülümsemesi. | Profil | Sonra |
| **Milletvekili Haluk Yılmaz** | 60, gri saç, pahalı takım; kamerada gülümseyen, gözleri yorgun. | Berat'ın gönderisi, News | Şimdi (Berat'ın gönderisi) |
| **Berat Yılmaz** | 22, markalı kıyafet, kendinden emin ama gözleri boş. Kafede, arabada, gece. | Sinstagram profili (3 gönderi) | Şimdi |
| **Deniz Yılmaz** | 23, kuzen, siyah kıyafet; mumlu bir yas gönderisi. | Sinstagram | Sonra |
| **Yusuf Kasap** | 21, gözlüklü, kitaplarla, kantinde. | Sinstagram | Sonra |
| **Furkan Şahin** | 20, dağınık saçlı, hafif kambur, kapüşonlu. | Sinstagram | Sonra |
| **Adil Karaca** | 40, kalın boyunlu, altın zincir, çay ocağında. Gizli hesabında yüz görünmesin. | Sinstagram (gizli hesap) | Sonra |
| **Kerem Aydın** | 24, sakallı, deri ceketli, sıska, gözleri çökük. **Yırtık fotoğraftaki ve kamera karesindeki kişi.** | Delil görselleri | Şimdi |
| **Ece Aydın** | 20, üç yıl önceki fotoğraflar; gülümseyen bir öğrenci, mezuniyet törenine benzemeyen sıradan kareler. | Haber, eski Sinstagram hesabı | Sonra |
| **Selin Aras** | 32, gazeteci, kısa saç, gözlük, not defteri. | Profil, haber imzası | Sonra |
| **Danışman** | 45, Y. Eğitim Vakfı; yüzü hiç tam görünmüyor, hep arka planda. | Haber, makam aracı | Sonra |

## 4. Haberler (News)

Şu an hiçbir haberde görsel yok; olsa çok daha gerçekçi durur. 16:9.

| Dosya adı | Haber |
| --- | --- |
| `haber_berat_bulundu.jpg` | Polis şeridi çekilmiş bir apartman girişi, gece |
| `haber_cenaze.jpg` | Kalabalık bir cenaze töreni, siyah giyimli insanlar, şemsiyeler |
| `haber_milletvekili.jpg` | Mikrofonlar önünde konuşan milletvekili (yüzü bulanık ya da uzaktan) |
| `haber_yuruyus.jpg` | Kampüste sessiz yürüyüş, pankartlar |
| `haber_mezbaha.jpg` | Gece mezbahanın önünde polis araçları |
| `haber_plaka.jpg` | Uzaktan siyah bir makam aracı |
| `haber_vakif.jpg` | Vakıf binasının cephesi, tabelası okunmayan |
| Gündelik haberler (isteğe bağlı) | Kebapçı açılışı, kıraathane, AVM yürüyen merdiveni, kampüs kedisi, fırın |

## 5. Fotoğraflar uygulaması (komiserin galerisi)

Komiserin telefonunda ne olmalı ve ne olmamalı:

- **Olmalı:** Birkaç iş fotoğrafı (dosyalar, ofis, bir olay yerinin uzaktan
  karesi), kedi ya da kahve gibi sıradan kareler, bir iki ekran görüntüsü.
- **Olmamalı:** Tatil fotoğrafı. Gizli son için bu bilerek bırakılmış bir
  boşluk; Sinstagram'daki tek "tatil" gönderisi dışında hiçbir tatil izi
  olmasın.
- [?] Bir tane tuhaf kare: perdesi kapalı, karanlık bir oda; nerede olduğu
  belli değil. (Gizli son için ipucu, sonra karar verelim.)
