# Yapılacaklar

Bitenleri işaretle (`[x]`), yeni işleri ekle. Hikâye kararları
[`bible/`](bible/README.md) klasöründe, oyundaki hali
[`HIKAYE_SEMASI.md`](HIKAYE_SEMASI.md) tablosunda.

## Görseller

Getirdiğin görseller `assets/pics/` klasörüne koyulabilir; ben kare kırpıp
küçültüp `assets/story/images/` altına taşırım (`assets/pics/` git'e girmez).
Test görselleri yenileri gelene kadar oyunda kalıyor. Telif sorunlu olanlar
(dizi ve film kareleri, gerçek kişiler) yayından önce mutlaka gitmeli. Her
görselin tarifi ve boyutu [`GORSELLER.md`](GORSELLER.md), üretim prompt'u
[`GORSEL_PROMPTLARI.md`](GORSEL_PROMPTLARI.md) dosyasında; getirdikçe
işaretle, bağlantısını ben yaparım.

### Şimdi lazım olanlar (oyunda yerleri hazır)

- [x] `kerem_gizli.jpg`: yırtık fotoğraf yapbozu (Kerem, habersiz çekilmiş)
- [x] `kamera_karesi.jpg`: kafe güvenlik kamerası, 23.41 (Berat ve Kerem)
- [x] `berat_babasi.jpg`: Berat ile milletvekili babası bir davette
- [x] `tatil.jpg`: komiserin "Tatildeyim, aramayın" gönderisi (ülke belli olmasın)
- [x] `bos_koltuk.jpg`: Atakan'ın "Amirimiz işbaşında 😂" gönderisi
- [x] `iki_bira.jpg`: Orhun'un "Akşam iki bira kimde?" gönderisi
- [x] `komplo.jpg`: @gizli.tarih komplo sayfası (insan yok)
- [x] `dedektif_meme.jpg`: @dedektif.memes
- [x] `sergi.jpg`: @sanat.galerisi yerel sergi
- [x] `ozge_kedi.jpg` ve `behram_operasyon.jpg` (eski kedi ve vitrin görsellerinin yerine)
- [ ] @kedi.dunyasi hâlâ `myCat.jpeg` kullanıyor: senin kedinse kalsın.
- [ ] Fotoğraflar uygulamasındaki (komiserin galerisi) eski test görselleri:
  aşağıdaki "Komiserin galerisi" maddeleri gelince değişecek.
- [ ] Şüphelilerin gönderileri: `berat_kafe.jpg`, `berat_kapi.jpg`,
  `furkan_borc.jpg`, `yusuf_sinav.jpg`, `deniz_yas.jpg`
- [ ] `my_foto1.jpg`, `my_foto2.jpg` (Behzat Ç.) ve @dizi.replikleri gönderisini
  kaldır; yerine bir şey gerekmez.

### Delil ve olay yeri (sonraki bölümler)

- [ ] `olay_yeri.jpg`: Berat'ın dağınık salonu
- [ ] `mezbaha_ic.jpg`: vidalı sandalye, karo duvarlar
- [ ] `mezbaha_duvar.jpg`: duvarda tarihli üç fotoğraf
- [ ] `mezbaha_dis.jpg`: gece, polis şeridi
- [ ] `cay_ocagi.jpg`
- [ ] `makam_araci.jpg`: plakası okunmayan siyah sedan
- [ ] `burs_sozlesmesi.jpg` (ben de üretebilirim)
- [ ] `kayip_ilani_1.jpg`, `kayip_ilani_2.jpg`

### Kişiler (profil fotoğrafı desteği gelince)

- [ ] Kodu hazırla: şu an sohbetlerde ve Sinstagram'da baş harfli renkli
  daireler var (`widgets/avatar.dart`).
- [ ] Berat (3 Sinstagram gönderisi de lazım), Milletvekili, Kerem
- [ ] Özge, Atakan, Orhun, Doğa, İnanç, Behram, Erdi
- [ ] Kaymakam, Selin Aras, Deniz, Yusuf, Furkan, Adil (gizli hesap, yüzsüz)
- [ ] Ece (üç yıl önceki sıradan kareler), Danışman (yüzü hep yarım)
- [ ] Komiser: yüz yok; eller, sırt, gölge

### Haberler (isteğe bağlı, 16:9)

- [ ] `haber_berat_bulundu.jpg`, `haber_cenaze.jpg`, `haber_milletvekili.jpg`
- [ ] `haber_yuruyus.jpg`, `haber_mezbaha.jpg`, `haber_plaka.jpg`, `haber_vakif.jpg`
- [ ] Gündelik haberler: kebapçı, kıraathane, AVM, kampüs kedisi, fırın

### Komiserin galerisi

- [ ] `galeri_dosyalar.jpg`, `galeri_kahve.jpg`, `galeri_ekran.jpg`,
  `galeri_olay_yeri.jpg`. Tatil fotoğrafı **olmasın** (gizli son için
  bilerek bırakılan boşluk).
- [ ] [?] `galeri_karanlik_oda.jpg`: gizli son ipucu, kullanıp kullanmamaya
  sonra karar ver.

## Ana gizem: oyuna geçirilecekler

Gerçek kesinleşti (`bible/01-ana-gizem.md`); oyunda henüz yok:

- [x] **Kerem'e ulaşma yolları** (Bölüm III, `bible/04-bolumler.md`):
  - [x] Vakfın gönüllü listesi (Harita görevi: vakıf binası)
  - [x] Kafe kamerasındaki kart (netleştirilmiş görüntü: Atakan'ın teknik birimi)
  - [x] Yırtık fotoğraf ile kamera karesindeki adamın aynı kişi olduğu
  - [x] Ece'nin eski hattı (Özge'nin sorgusu: "üç yıl önce ölmüş bir kadın")
  - [x] Sinstagram'da Ece'nin eski hesabı ve Kerem'in yorumları
- [ ] **Berat'ın kanıtları.** Telefonu Kerem'de; oyuncu bunu nasıl öğrenir,
  kanıtlara nasıl ulaşır?
- [ ] **Kerem'le buluşma (`kerem:meeting`) ve İkilem 2.** Bölüm IV'ün başı.
- [ ] Sızıntı için yanlış kişiyi suçlamanın bedeli (Atakan, Orhun, kaymakam, Erdi).
- [ ] **Kerem'le yüzleşme ve İkilem 2.** Gözaltı, savcıyla iş birliği ya da kaçmasına
  göz yumup kayıpların yerini öğrenmek.
- [ ] **Kayıp öğrenci (hayatta olan) ve İkilem 5.**
- [ ] **Furkan "sıradaki" mi?** Mezbahadaki ileri tarihin Furkan'a bağlanması.
- [ ] **Vakıf ve danışman.** Burs sözleşmesi, burs listesi; danışmanın adı ve
  rolü.

## Açık sorular (önce karar)

- [x] Erdi neyi biliyor? Korkak bürokrat, vakfı bilmiyor.
- [x] Kaymakamın vakıfla bağı ne? Bağı yok, milletvekilinin rakibi.
- [x] Behram'ın sırrı: narkotik, Adil muhbir olduğu için cuma gecelerine göz yumdu.
- [x] Basına kim sızdırıyor? Komiserin kendisi (hatırlamadığı gece aramaları).
- [ ] Adil'in deposundaki listede geçen "H.Y." kim?
- [ ] Hakan Demir'in hedefi kim? (Berat'ın katili artık o değil.)
- [ ] Gizli son ("hiç yurt dışında değildi") diğer finallerle nasıl birleşir?

## Sistemler

- [ ] **Gizli son için şüphe sayısı.** `doubt` var ve beş ipucu artırıyor;
  finalde yeterliyse çıkacak son seçenek henüz yazılmadı.
- [ ] **Görevden uzaklaştırma kilidi.** Poltel kilitlenince laboratuvar da
  kapanıyor. Ya laboratuvar ayrı bir uygulama olsun ya da kilitliyken
  bekleyen incelemeler başka yoldan çözülsün.
- [ ] **Rüşvet ikileminin eksik seçenekleri.** Savcılığa bildirmek, göndericiyi
  araştırmak.
- [ ] **Senaryolu telefon aramaları.** Avukat, gazeteci, tanık (Phone uygulaması).
- [ ] **Silinen mesaj izleri.**

## Hikâye planı (bible) adımları

- [x] 1. Evren ve ana gizem (temel kararlar)
- [ ] 2. Karakter dosyaları ve ilişki ağı: ekibin kişisel hikâyeleri
- [ ] 3. Kronoloji: oyun içi olayların tamamı
- [ ] 4. Bölüm III–VI ve final soruşturması
- [ ] 5. Yan hikâyeler (Kayıp Kız, Eski Dosya...) ve ikilemler 3–10
- [ ] 6. Durumlar ve seçim-sonuç matrisi
- [ ] 7. Uygulamalara dağıtım (her zorunlu bilgiye iki yol)
- [ ] 8. Sahneleri yaz (JSON)
- [ ] 9. Tutarlılık kontrolü (`bible/09-kontrol.md`)

## Yayın

- [ ] `chore/modernize-codebase` branch'ini GitHub'a gönder (onay bekliyor).
- [ ] GitHub'da eski bir commit'in SHA ile hâlâ açılabilmesi: destek talebi ya
  da depoyu yeniden oluşturmak.
