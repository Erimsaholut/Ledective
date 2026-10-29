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
- [x] Fotoğraflar uygulamasındaki eski test görselleri kalktı; galeride artık
  sadece `galeri_*` kareleri var, hepsi baştan görünür ("Load More" kalktı).
- [x] Şüphelilerin gönderileri: `berat_kafe.jpg`, `berat_kapi.jpg`,
  `furkan_borc.jpg`, `yusuf_sinav.jpg`, `deniz_yas.jpg`
- [x] `my_foto1.jpg`, `my_foto2.jpg` (Behzat Ç.) ve @dizi.replikleri gönderisi
  kaldırıldı; kullanılmayan diğer test kareleri de (film/dizi, tablo) silindi.
  `benKedi.jpeg` ve `gungun.jpeg` duruyor ama oyunda kullanılmıyor.

### Delil ve olay yeri (sonraki bölümler)

- [x] `olay_yeri.jpg`: Berat'ın dağınık salonu
- [x] `mezbaha_ic.jpg`: vidalı sandalye, karo duvarlar
- [x] `mezbaha_duvar.jpg`: duvarda tarihli üç fotoğraf
- [x] `mezbaha_dis.jpg`: gece, polis şeridi
- [x] `cay_ocagi.jpg`
- [x] `makam_araci.jpg`: plakası okunmayan siyah sedan
- [x] `burs_sozlesmesi.jpg` (ben de üretebilirim)
- [x] `kayip_ilani_1.jpg`, `kayip_ilani_2.jpg`

### Yeni görseller (`GORSELLER.md` › 6)

- [ ] Şimdi: Ece'nin 3 gönderisi, Berat'ın telefonu, gözaltı, depo ve çiftlik haberleri
- [ ] Sonra: kalan 8 haber, 7 harita mekânı

### Kişiler (profil fotoğrafı desteği gelince)

- [ ] Kodu hazırla: şu an sohbetlerde ve Sinstagram'da baş harfli renkli
  daireler var (`widgets/avatar.dart`).
- [ ] Berat (3 Sinstagram gönderisi de lazım), Milletvekili, Kerem
- [ ] Özge, Atakan, Orhun, Doğa, İnanç, Behram, Erdi
- [ ] Kaymakam, Selin Aras, Deniz, Yusuf, Furkan, Adil (gizli hesap, yüzsüz)
- [ ] Ece (üç yıl önceki sıradan kareler), Danışman (yüzü hep yarım)
- [ ] Komiser: yüz yok; eller, sırt, gölge

### Haberler (isteğe bağlı, 16:9)

- [x] `haber_berat_bulundu.jpg`, `haber_cenaze.jpg`, `haber_milletvekili.jpg`
- [x] `haber_yuruyus.jpg`, `haber_mezbaha.jpg`, `haber_plaka.jpg`, `haber_vakif.jpg`
  (vakıf görseli hem burs haberinde hem savcılık operasyonunda, arşiv fotoğrafı
  gibi). `mezbaha_dis.jpg` artık "Sanayi sakinleri tedirgin" haberinde.
- [x] Gündelik haberler: kebapçı, kıraathane, AVM, kampüs kedisi, fırın
- [ ] [?] `haber_cenaze.jpg` arka planında İstanbul Boğazı görünüyor; Yeşilkent
  bir taşra şehri. Değiştirmek istersen: deniz ya da siluet görünmeyen bir
  mezarlık.

### Komiserin galerisi

- [x] `galeri_dosyalar.jpg`, `galeri_kahve.jpg`, `galeri_ekran.jpg`,
  `galeri_olay_yeri.jpg`. Tatil fotoğrafı yok (gizli son için bilerek
  bırakılan boşluk).
- [x] `galeri_karanlik_oda.jpg`: galerinin en yeni karesi; gizli son ipucu
  (`bible/01-ana-gizem.md`).

## Ana gizem: oyuna geçirilecekler

Gerçek kesinleşti (`bible/01-ana-gizem.md`); oyunda henüz yok:

- [x] **Kerem'e ulaşma yolları** (Bölüm III, `bible/04-bolumler.md`):
  - [x] Vakfın gönüllü listesi (Harita görevi: vakıf binası)
  - [x] Kafe kamerasındaki kart (netleştirilmiş görüntü: Atakan'ın teknik birimi)
  - [x] Yırtık fotoğraf ile kamera karesindeki adamın aynı kişi olduğu
  - [x] Ece'nin eski hattı (Özge'nin sorgusu: "üç yıl önce ölmüş bir kadın")
  - [x] Sinstagram'da Ece'nin eski hesabı ve Kerem'in yorumları
- [x] **Berat'ın kanıtları.** Buluşmada telefon ele geçiyor (`ev:berat-phone`).
- [x] Berat'ın telefonundaki kayıtlar: savcılık, basın ya da kasa (Bölüm V).
- [x] **Kerem'le buluşma ve İkilem 2** (Bölüm IV).
- [ ] Sızıntı için yanlış kişiyi suçlamanın bedeli (Atakan, Orhun, kaymakam, Erdi).
- [x] **Kerem'le yüzleşme ve İkilem 2.** Gözaltı, savcıyla iş birliği ya da kaçmasına
  göz yumup kayıpların yerini öğrenmek.
- [x] **Kayıp öğrenci (hayatta olan):** Melis, cuma süresi (Bölüm IV).
- [x] **Emre:** Halit Yener'in çiftliği; arama kararı ya da kararsız baskın (Bölüm V).
- [ ] **İkilem 5** (tanığı koruma/zorlama) Emre için kullanılabilir.
- [ ] **Furkan "sıradaki" mi?** Mezbahadaki ileri tarihin Furkan'a bağlanması.
- [ ] **Vakıf ve danışman.** Burs sözleşmesi, burs listesi; danışmanın adı ve
  rolü.

## Bölüm VI için

- [x] Kerem Adil'in peşinde: pansiyona yetişilmezse Adil'i öldürür (Bölüm V).
- [x] Danışmanın kimliği: Halit Yener, "H.Y." (Bölüm V). Yüzleşme Bölüm VI.
- [ ] Hakan Demir'in hikâyesi (İkilem 4) ve ekibin kişisel hikâyeleri (İkilem 3, 9)
- [ ] Milletvekiliyle son yüzleşme
- [ ] Final soruşturması ve `final:ready`; gizli sonun son seçeneği

## Açık sorular (önce karar)

- [x] Erdi neyi biliyor? Korkak bürokrat, vakfı bilmiyor.
- [x] Kaymakamın vakıfla bağı ne? Bağı yok, milletvekilinin rakibi.
- [x] Behram'ın sırrı: narkotik, Adil muhbir olduğu için cuma gecelerine göz yumdu.
- [x] Basına kim sızdırıyor? Komiserin kendisi (hatırlamadığı gece aramaları).
- [x] Adil'in deposundaki listede geçen "H.Y." kim? Danışman Halit Yener.
- [ ] Hakan Demir'in hedefi kim? (Berat'ın katili artık o değil.)
- [ ] Gizli son ("hiç yurt dışında değildi") diğer finallerle nasıl birleşir?

## Sistemler

- [ ] **Gizli son için şüphe sayısı.** `doubt` var ve beş ipucu artırıyor;
  finalde yeterliyse çıkacak son seçenek henüz yazılmadı.
  - [x] Mail ve SMS artık açılınca bayrak açabiliyor (`unlocksOnView`).
    İpucu mailleri ve SMS'leri `clue:` bayrakları açıyor.
  - [x] Açılınca uygulanan etkiler artık bir kez sayılıyor (sesli mesajı
    tekrar dinlemek `doubt`'u şişiriyordu).
  - [ ] [?] Hangi `clue:` kaç puan sayacak ve final eşiği ne olacak (şu an
    `doubt >= 3`)? Karar bekliyor.
- [x] **Görevden uzaklaştırma kilidi.** Poltel kilitliyken bekleyen
  incelemeler Pano'dan sürüyor ("Laboratuvar talebini sürdür"); kilit
  ekranı da bunu söylüyor. Oyun takılmıyor.
  - [ ] [?] Hikâye açısından: incelemeyi o sırada komisere güvenen biri mi
    yapsın (ör. Doğa)? Karar sende.
- [ ] **Rüşvet ikileminin eksik seçenekleri.** Savcılığa bildirmek, göndericiyi
  araştırmak.
- [ ] **Senaryolu telefon aramaları.** Avukat, gazeteci, tanık (Phone uygulaması).
- [ ] **Silinen mesaj izleri.**
- [x] **Bildirimler.** Gerçek telefon gibi: arka arkaya gelenler üst üste
  yığılır, aynı kişinin mesajları tek kartta toplanır, yukarıdan aşağı
  çekince bildirim merkezi açılır.
- [x] **Mail ve haber zamanlaması.** Aşağı çekip yenileme kalktı; oyun
  süresinde rastgele aralıklarla gelir, bazıları olaylardan sonra
  (`afterMinutes`, `requires`). Havuzlar: 97 mail, 116 gündelik haber (magazin, tarih, ilginç bilgiler, dizi göndermeleri dahil).
- [x] Gizli son için üç ipucu maili kalıyor (otel, havayolu, poliklinik);
  `bible/01-ana-gizem.md` içinde kanon. Açılınca `doubt` artsın mı, sonra
  karar ver (mailler şu an `unlocksOnView` desteklemiyor).
- [x] **İpucu bildirimleri.** Sohbet dışındaki seçenekler (ZaferBank'tan
  rüşveti iade, Orhun'un borcu, avukat ücreti) bir süre sonra, oyuncu hâlâ
  bir şey yapmadıysa tek bir bildirimle hatırlatılır (`state.json › hints`).
  Settings › İpucu bildirimleri ile kapatılabilir.
- [ ] [?] Laboratuvar, Poltel sorguları ya da harita görevlerinde gözden
  kaçan seçenek var mı? Oyun testinde bakılacak, varsa ipucu eklenir.
- [x] **Bakılmayan akış durur.** Oyuncu Mail'i ya da News'u açmadan 4
  gündelik öğe gelince o havuz bekler, uygulama açılınca devam eder.
- [x] **Manşet.** Hikâye haberleri Gündem'in üstünde, gündelikler altta.
- [x] Gizli son için sağlık izleri: ilaç kutusu, eczane faturası ve SMS'i,
  seyahat sigortası, e-reçete (yeşil reçete), annenin ilaç maili,
  Dr. Arıkan'ın SMS'i (`bible/01-ana-gizem.md`).
- [x] Takvim'de dört haftada bir "Dr. Arıkan · kontrol" (7 ve 3 hafta önce).
- [x] Sohbetlerde mesajlar tek tek, birkaç saniye arayla geliyor; her biri
  kendi bildirimiyle; beklerken listede "yazıyor..." görünüyor.

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
