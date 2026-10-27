# 2. Karakterler ve ilişki ağı

Her karakter için üç soru zorunlu: **Ne istiyor? Ne saklıyor? Neyi
kaybetmekten korkuyor?** Bunlar netleşmeden karakterin diyaloğu yazılmaz.

Güven: her ekip üyesinin komisere güveni ayrı tutulur (`trust:<isim>`,
0–100, başlangıç 50). Oyuncuya gösterilmez, sonuçları sohbetlerde hissedilir.
Yüksek merhamet her zaman yüksek güven demek değildir: sürekli suçluları
affeden bir komisere ekipteki dürüst polisler güvenmemeye başlayabilir.

## Şablon

Yeni bir karakter eklerken bu bloğu kopyala.

```markdown
### Ad Soyad
**Rol:** ...
**Oyundaki yeri:** Hangi uygulamada, ne zaman ortaya çıkıyor. [KANON]/[ÖNERİ]

- **Ne istiyor:** [?]
- **Ne saklıyor:** [?]
- **Neyi kaybetmekten korkuyor:** [?]
- **İnandığı ama yanlış olabilecek şey:** [?]
- **Kişisel hikâyesi:** [?] (05-yan-hikayeler.md'de ayrıntı)
- **Sicil dosyasındaki ipucu:** [?] (documents.json, category: personnel)
- **Güveni artıranlar:** [?]
- **Güveni azaltanlar:** [?]
- **Konuşma tarzı:** [?]
```

## Komiser (oyuncu)

**Rol:** Cinayet Büro amiri. Dosya başladığında yurt dışında izinde. [KANON]

- **Geçmiş:** [ÖNERİ] Yıllar önce yürüttüğü bir soruşturmada verdiği bir
  karar, masum olabilecek birinin mahkûmiyetine katkıda bulunmuş olabilir
  (İkilem 10).
- **Kişilik:** Oyuncunun seçimleriyle şekillenir (traits). Kahraman olmak
  zorunda değil: başlangıçta bir hayat kurtarmak için yapılan usulsüzlük,
  onu gizlemek için daha büyüklerine dönüşebilir.
- **Hukuki/mesleki durum:** görevde → idari inceleme → görevden uzaklaştırma
  → meslekten çıkarılma → yakalama kararı (bkz. 06-durumlar.md). Komiser
  tutuklama kararı veremez; işlem başlatır, delil sunar, karar talep eder.
- **Ne saklıyor / neyden korkuyor:** [?]

## Büro

### Özge
**Rol:** Cinayet Büro, komiserin en güvendiği kişilerden. Dosyayı komisere
ilk o bildirir. [KANON]

- **Ne istiyor:** [?]
- **Ne saklıyor:** [ÖNERİ] Soruşturmadaki bir tanığın eski bir arkadaşı.
  Ayrıca Atakan'ın sevgilisini geçmişteki bir dosyadan tanıyor ama Atakan'ı
  zor durumda bırakmamak için söylemiyor.
- **Neyden korkuyor:** [?]
- **Sicil ipucu:** [KANON, taslak] Geçmişte bir tanıkla kişisel yakınlığı
  nedeniyle tarafsızlığı sorgulanmış; inceleme kapatılmış.
- **Güven etkisi:** [ÖNERİ] Güveni yüksekse gizli bir bilgiyi kendiliğinden
  söyler; düşükse oyuncu aynı bilgiye başka yoldan ulaşmak zorunda kalır.
- **Konuşma tarzı:** Samimi, amirine "amirim" diyen ama gerektiğinde
  çıkışabilen biri.

### Atakan (Atakan Kutay)
**Rol:** Büro polisi. Yusuf'un ifadesini o aldı. [KANON]

- **Ne istiyor:** [?]
- **Ne saklıyor:** [ÖNERİ] Büro dışından biriyle gizli ilişki. Bu kişinin
  ailesi milletvekiliyle bağlantılı. Soruşturmadan bilgi sızdırıyor; köstebek
  sanılıyor ama tehdit edilen bir yakınını korumaya çalışıyor (İkilem 3).
- **Neyden korkuyor:** Sevdiği kişinin ya da yakınının zarar görmesi.
- **Sicil ipucu:** [ÖNERİ] Gizli bilgi paylaşımı şüphesiyle incelenmiş,
  yeterli delil bulunamamış.
- **Not:** Sadece hain ya da mağdur değil: yanlış yaptığını bilen ama aynı
  koşullarda yine benzer bir seçim yapabilecek biri.

### Orhun
**Rol:** Büro polisi; bilgileri komisere o iletmeyi teklif eder. "Akşama iki
bira ok?" mesajı geçmişte duruyor. [KANON]

- **Ne saklıyor:** [ÖNERİ] Ciddi mali sorunlar. Hesabına şüpheli bir ödeme
  gelir: rüşvet de olabilir, meşru bir aile yardımı da. Milletvekilinin çevresi
  borçlarını öğrenir; Orhun rüşveti reddedebilir ama ailesinin durumuyla ilgili
  bazı şeyleri gizler.
- **Sicil ipucu:** [ÖNERİ] Kendisine sunulan uygunsuz bir hediyeyi bildirdiği
  için olumlu sicil almış; bugünkü para hareketleriyle tezat oluşturur.
- **Gizli ipucu:** [ÖNERİ] Bira teklif ettiği akşam aslında birini görmeye
  çalışıyordu.

### Doğa
**Rol:** Furkan'ın sorgusunu yürüten polis. [KANON]

- **Ne saklıyor:** [ÖNERİ] Sorguladığı bir tanığa duygusal yakınlık duyar;
  tanığın masum olduğuna inanır ve bazı şüpheli ayrıntıları görmezden gelir.
  Tanık bir gece nerede olduğu konusunda yalan söylemiştir; Doğa bunu bilir ama
  yalanın utanılan özel bir olayı sakladığına inanır (İkilem 9).
- **Sicil ipucu:** [ÖNERİ] Bir sorgu sırasında tanığı aşırı koruduğu için
  uyarı almış.
- **Keşif:** Doğa'nın mesajlarıyla resmî raporlar arasındaki küçük saat
  farkları dikkatli oyuncunun yakalayacağı ipucu olabilir.

### İnanç
**Rol:** Şüpheliyi (Furkan) yakalayan, emirleri sorgulamadan uygulayan polis.
[KANON]

- **Kişisel hikâyesi:** [ÖNERİ] Hukuka aykırı bir emir alır; emri veren
  komiserin üstüdür (Erdi). Emri yerine getirmez, delili komiserle paylaşır;
  ardından hakkında disiplin soruşturması açılır (İkilem 6). Komiserden onu
  korumasını değil, doğru olanı yapmasını ister.
- **Sicil ipucu:** [ÖNERİ] Bir amirin emrine karşı gelmiş ama bir vatandaşın
  hayatını kurtarmış.
- **İlişki:** Doğa'nın tarafsızlığını kaybettiğini fark edip komiseri uyarır;
  komiser Doğa'yı korursa İnanç'ın güveni düşer.

### Behram
**Rol:** Narkotik Büro Başkomiseri. Adil aylardır onun dosyasında. [KANON]

- **Sicil ipucu:** [ÖNERİ] Başarısız bir operasyonda muhbir kaybedilmiş;
  sorumluluğu konusunda farklı değerlendirmeler var.
- **Ne istiyor / saklıyor:** [?]

### Erdi
**Rol:** Komiserin üstü. Komiser izindeyken onu aramaya çalışır; komiserin
onu engellediği ima edilir. [KANON]

- **Ne istiyor:** [?]
- **Ne saklıyor:** [ÖNERİ] İnanç'a delili ortadan kaldırma emrini veren kişi.
  Komiserin yetkilerini aştığını söyleyip hakkında inceleme başlatan da o
  olabilir.
- **Sicil ipucu:** [ÖNERİ] Bir soruşturmanın yönünü değiştirmek için baskı
  yaptığı iddiasıyla şikâyet edilmiş, işlem yapılmamış.
- **Sızıntılar:** [KANON, taslak] Her sızıntı haberinde komisere çıkışır ve
  bir sonrakinde onu dosyadan alacağını söyler. Haberleri gazeteden öğrenmek
  onu üstlerinin önünde küçük düşürüyor.

## Dosyadaki kişiler

### Berat Yılmaz
**Rol:** Maktul. Milletvekilinin oğlu. [KANON] Ayrıntı: 01-ana-gizem.md.

- **Ne istiyordu:** [KARAR] Ece'nin ölümündeki payını itiraf etmek, babasını
  ve vakfı ifşa etmek. [ÖNERİ] Sonra yurt dışına kaçmak (Deniz: "Gelecek ay
  yurtdışına gitmek için plan yapıyordu").
- **Ne saklıyordu:** Üç yıl önceki gece; burs programındaki rolü; topladığı
  kanıtlar (telefonunda).
- **Neyden korkuyordu:** Babasının öğrenmesi ("babama söylemek yok"), cuma
  gecesi.

### Milletvekili Yılmaz (öneri isim: Haluk Yılmaz)
**Rol:** Berat'ın babası, Yılmaz Vakfı'nın kurucusu. Gizli numarasından
komisere yazar ve 50.000 TL gönderir. [KANON, taslak]

- **Ne istiyor:** Oğlunun katilinin bulunması, ama vakfın ve Ece olayının
  gömülü kalması. [KARAR: Ece olayını örtbas ettirdi]
- **Ne saklıyor:** [ÖNERİ] Vakfın karanlık tarafını bildiğini; oğlunun
  ölmeden iki gün önce ondan para istediğini ve reddettiğini.
- **Neyden korkuyor:** Oğlunun hatırasının ve kendi kariyerinin aynı gün
  yıkılması.

### Deniz Yılmaz
**Rol:** Berat'ın kuzeni, cesedi bulan kişi. [KANON]

### Yusuf Kasap
**Rol:** Okuldan tanık, Furkan'ı işaret eder. [KANON]

### Furkan Şahin
**Rol:** Berat'tan paket alan öğrenci. Doğa'nın sorgusunda Adil'i anlatır.
[KANON]

### Adil Karaca ("Adil abi")
**Rol:** Uyuşturucu ve gasp sabıkalı. Berat'ın 40.000 TL borçlu olduğu kişi.
Bardakta parmak izi var, çay ocağından kaçar. [KANON]

### Kerem Aydın — katil [KARAR: mağdurun kardeşi; isim öneri]
**Rol:** Ece Aydın'ın ağabeyi. Berat'ı öldüren kişi. Oyunda henüz adıyla
görünmüyor; şu an üç izi var: kafe kamerasındaki deri ceketli adam, yırtık
fotoğraf ("Kardeşi") ve mezbahadan sonra arayan korkmuş "tanık".

- **Ne istiyor:** Ece için adalet; artık bunun yanında kayıp öğrencileri
  kurtarmak. [ÖNERİ]
- **Ne saklıyor:** Cinayeti; Berat'ın telefonunu; kayıpların nerede
  olduğunu.
- **Neyden korkuyor:** Kayıpları kurtaramadan yakalanmak. Berat'ın pişman
  olduğunu öğrendiği için kendi yaptığıyla yüzleşmek.
- **İnandığı ama yanlış olan:** Berat'ın onu tanımadığını sanıyor. [ÖNERİ]
- **Konuşma tarzı:** Kısa, fısıltılı, kendini hep "tanık" olarak tanıtıyor.
- **Ulaşma yolları [ÖNERİ, henüz oyunda yok]:** vakfın gönüllü listesi,
  kamera karesindeki kart, Ece'nin eski hattı, Sinstagram'da Ece'nin eski
  hesabındaki yorumlar.

### Ece Aydın [KARAR: Berat yüzünden ölen öğrenci; isim öneri]
Üç yıl önce, burs programının borçlusu olarak mezbahada öldü. Ölümü takipsizlikle
kapandı (News arşivi: "Üniversiteli genç kadının ölümüyle ilgili soruşturma
kapatıldı"). Hattı hâlâ kullanılıyor.

## Önerilen yeni karakterler [ÖNERİ]

### Hakan Demir
İşsiz, eşi kanser tedavisi görüyor, borç içinde. Milletvekilinin çevresi ona
tedavi parası karşılığında bir cinayet teklif eder ve Hakan kabul eder.
Oyuncu onu önce profesyonel tetikçi sanar. Ayrıntı: İkilem 4.

Berat'ın katili **değil** (katil Kerem). [?] Hakan'ın hedefi kim olabilir:
Kerem'e ulaşmaya çalışan bir tanık, Selin Aras, Furkan ya da kayıp
öğrencilerden hayatta olan. Bölüm IV'te ağın Kerem'i susturmak için onu
tutması da düşünülebilir.

### Hakan'ın eşi
Tedavi parasının nereden geldiğini bilmez. Gerçeği öğrenirse bu parayla
tedavi olmak istemeyebilir. Kendi kararlarını veren bir karakter; sadece
kurtarılacak biri değil.

### Gazeteci
Milletvekilinin eski bir cinayeti örtbas ettiğine dair belgelere ulaşır;
belgelerde gizli bir tanığın kimliği de vardır (İkilem 7). Oyuncu ona bilgi
verebilir, kaynak sorabilir, yayını erteletmeye çalışabilir.
News'te geçen "Selin Aras" adı şimdilik yer tutucu.

### Kaymakam Cevdet Arslan [KANON, taslak]
Milletvekilinin ilçesinin kaymakamı. Erdi'nin baskısından sonra komisere
doğrudan yazar; gelişmeleri "aileye iletmek için" önce kendisine anlatmasını
ister. Kibar ama tehditkâr: "Usul her zaman insanı korumaz."
- **Ne istiyor / saklıyor:** [?]

### Milletvekilinin danışmanı
Rüşvet teklifini getiren kişi (İkilem 1). [?] Makam aracındaki kişi o mu?

### Avukat
Komiserin kendi hukuki durumu için başvurabileceği kişi. [?]

## İlişki ağı

Satır, sütundaki kişi hakkında ne düşünüyor / ne saklıyor. Doldukça
güncelle.

| | Özge | Atakan | Orhun | Doğa | İnanç | Behram | Erdi |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Özge** | | Sevgilisini tanıyor, saklıyor [ÖNERİ] | | | | | |
| **Atakan** | | | | | | | |
| **Orhun** | | | | | | | |
| **Doğa** | | | | | | | |
| **İnanç** | | | | Tarafsızlığından şüpheli [ÖNERİ] | | | Hukuka aykırı emrini reddetti [ÖNERİ] |
| **Behram** | | | | | | | |
| **Erdi** | | | | | Hakkında disiplin işlemi [ÖNERİ] | | |

İlişkiler sabit değil: bazı oyunlarda karakterler barışır, bazılarında
düşman olur. Komiser her özel ilişkiye müdahale etmek zorunda değil; bazılarını
sadece izler.
