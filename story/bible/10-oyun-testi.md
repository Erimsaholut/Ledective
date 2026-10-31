# 10. İlk oyun testinden çıkanlar (31.10.2026)

iPhone'da demo oynanınca çıkan hikâye ve denge konuları. Kararları kullanıcı
31.10.2026'da verdi; hepsi **[KARAR]** ve JSON'a geçti. Yazılan metinler
**[Taslak]**.

## 1. Para miktarları [KARAR]

| Kalem | Eski | Yeni |
| --- | --- | --- |
| Başlangıç bakiyesi | 12.450 TL | 31.200 TL |
| Rüşvet ("Geçmiş olsun") | 50.000 TL | 250.000 TL |
| Orhun'un borcu | 80.000 TL (not), 20.000 TL (kural) | 80.000 TL; kısmi ödeme sayılır |
| Avukat, tedavi payı | 15.000'er TL | Aynı |

**Yeni ikilem:** Orhun'un 80.000 TL'lik borcu ancak rüşvet parasıyla tamamen
kapanabilir. Kirli parayla ödenirse `orhun:paid-dirty` açılır (dürüstlük
-15) ve Orhun "Bu kadar para nereden abi?" diye yazar.

## 2. Eksik ya da fazla gönderim [KARAR]

Gönderilen para alıcı başına **toplanır** (`paid:<alıcı>`). Her basamak
(`tiers`, `story/STORY_FORMAT.md`) toplam ona ulaşınca bir kez çalışır.

- **Rüşvet iadesi**
  - **Eksik (1–249.999 TL):** `bribe:partial`, dürüstlük -5. Parayı tutmuş
    sayılır: `bribe-kept` süresi dolunca iç denetim yine başlar. Mail
    "yalnızca bir kısmının iade edilmesi" diye yazar. Bilinmeyen numaradan:
    "Kalanı sizde kalsın. Anlaştık demek."
  - **Tamamı (250.000 TL):** `bribe:returned` (şimdiki etkiler).
  - **Fazlası:** ayrıca `bribe:donated`; vakıf SMS ile "bağış" için teşekkür
    eder.
- **Orhun'un borcu**
  - **20.000 TL'den az:** Orhun parayı geri gönderir (`orhun:sent-back`,
    güven +3).
  - **20.000–79.999 TL:** `orhun:helped-partly`, güven +10, "Faizine yetti."
  - **80.000 TL:** `orhun:helped` (şimdiki etkiler). Rüşvet iade
    edilmemişken ödenirse `orhun:paid-dirty`.
- **Avukat:** 15.000 TL'den azı `lawyer:underpaid`; avukat kalanını ister.
- Her basamak alıcıdan ya da gönderenden bir SMS açar, böylece oyuncu bir şeyin
  değiştiğini görür. Aynı kişinin SMS'leri tek konuşmada birleşir.

**Düzeltilen hata:** İç denetim (`case:internal-investigation`) iki yoldan
açılıyordu: rüşvet ve sızıntı. Ama bütün metinler "parayı iade etmedin"
diyordu. Artık rüşvet yolu `audit:bribe` da açıyor ve parayla ilgili metinler
(Özge, Erdi, iç denetim maili) yalnızca ona bağlı. Sızıntı yolunun kendi
maili ve Erdi'de kendi sorusu var.

## 3. Sohbetlerden gelen fotoğraflar [KARAR]

Bir mesaj `[foto: dosya.jpg]` ile başlarsa fotoğraf olarak görünür ve
Photos'a da düşer (`story/STORY_FORMAT.md`).

- **Özge:** ilk konuşmada olay yerinden ayakkabı izi
  (`sohbet_olay_yeri_iz.jpg`, TEST GÖRSELİ).
- **Doğa:** Furkan sorgusunda Adil'in son mesajının ekran görüntüsü
  (`sohbet_furkan_ekran.jpg`, TEST GÖRSELİ).
- **Atakan:** kamera karesi (`kamera_karesi.jpg`).
- **Annesi (SMS):** `part1Done` sonrası tatil fotoğrafı: "Neresiydi burası?
  Hiç anlatmadın." Gizli son için işaretsiz bir ipucu.

## 4. Seçim hissi

**Kırmızı kararlar:** Yol ayıran düğümler `"decision": true` ile işaretli.
Yanıt paneli kırmızı oluyor, sohbet listesinde "Karar bekliyor" çıkıyor.
Bölüm I'le birlikte 41 düğüm işaretli.

**Bölüm I'in üç kararı [KARAR]:**

1. **Tatili kesmek** (Özge, `comeBack`): "Dönebilir misiniz amirim?"
   - "Hemen dönüyorum": güven +10, `vacation:cut`. Komiser dönmez; `part1Done`
     sonrası Özge "Uçağınız ne zaman iniyor?" diye sorar, iki cevap da
     `doubt += 1`.
   - "Buradan yöneteceğim": güven -5, `vacation:remote`.
     **[?] Henüz bağlanmadı:** Orhun ve Behram'ın daha serbest davranması
     (ör. Orhun'un teklifinin erken gelmesi) için hangi sahne değişsin?
2. **İntihar tutanağı** (Özge, `suicideReport`): Müdürlük otopsi sızmadan
   tutanağı "intihar" diye kapatmak istiyor.
   - "İmzala": dürüstlük -5, Behram güveni -10, `report:signed`.
     **[?] Henüz bağlanmadı:** basının bir gün sessiz kalması.
   - "Hayır": dürüstlük +5, `report:refused`. Kaymakam Erdi'nin baskısından
     2 dakika sonra yazar (`kaymakam-early`).
3. **Aileye ne söylenecek** (yeni kişi: Berat'ın annesi **Nevin Yılmaz**,
   adı [Taslak]): tutanak kararından sonra yazar.
   - "Öldürüldü": dürüstlük +5, `family:told-truth`.
   - "Soruşturma sürüyor": `family:told-nothing`, `doubt += 1`. Anne "Geçen
     hafta sizi bizim sokakta gördüm sandım" der: gizli son ipucu.

## 5. Laboratuvar mini oyunları [KARAR]

Mevcut dört oyuna (yapboz, parmak izi, UV lamba, şifre çözücü) yedisi
eklendi. Hepsi isteğe bağlı: sonuç metni ve `lab:<delil>` bayrağı veriyor,
hikâyenin ilerlemesini kesmiyor. Poltel'de incelenmemiş delil parlıyor.

| Delil | Oyun | Sonuç [Taslak] |
| --- | --- | --- |
| Kamera Görüntüsü | Netlik ve ışık ayarıyla netleştirme | Kartta turuncu şerit ve logo |
| Olay Yeri | Luminol, 14 püskürtmeyle 6 iz | Ceset salondan sürüklenmiş |
| Berat'ın Telefonu | Lekelerden desen kilidi | Gizli "Kayıtlar" klasörü |
| Halit Yener'in Sesi | Ses izini hizalama | Kayıt %94 Yener |
| Duvardaki Fotoğraflar | Fark bulma (5 fark) | Fotoğraflara sonradan işaret eklenmiş |
| Ece'nin Burs Sözleşmesi | Mürekkep yaşına göre sıralama | Üç kat geri ödeme maddesi sonradan eklenmiş |
| Makam Aracı | Lastik izini döndürüp hizalama | Araç çay ocağının önünde durmuş |

[?] Bu sonuçlardan hangileri hikâyeye bağlansın (ör. sözleşme sonucu Ece
dosyasında yeni bir soru açsın)?

## 6. Arayüz (kod)

- Her uygulamada çıkış tuşu; klavye açıkken de ana ekran çubuğu görünür.
- iPhone'un alt çubuğu soluyor; alttan ya da üstten ilk kaydırma oyuna gidiyor.
- Kale Muhafızı'nda düşmanlar can/para satırına taşmıyor.
- MatesApp yanıt paneli kendiliğinden güncelleniyor.
- Gündelik mail ve haberler banner çıkarmıyor; aynı anda gelenler birleşiyor.
- Harita: görevi kalmayan mekânda yeşil tik; yeni mekân ya da yeni görev
  sarı parlıyor (aynı parıltı Poltel laboratuvarında da kullanılıyor).
- News: Manşet (dosyanın haberleri), Gündem ve Arşiv ayrı sekmeler;
  okunmamışlar sekmede sayıyla.
