# Hikâye şeması

Bu dosya `assets/story/*.json` dosyalarından üretilir; elle düzenleme. Güncellemek için:

```bash
dart run tool/validate_story.dart --table
```

Nasıl okunur:

- **Kişiler:** Her sohbetin adımları. "Ne zaman" o adımın hangi koşulla geldiğini, "Sonuç" seçeneğin açtığı bayrakları ve değiştirdiği sayıları gösterir.
- **Bayraklar:** Bir bayrağa nasıl ulaşılır, ulaşılınca ne olur. Bir yolu açmak için ne gerektiğini buradan izle.
- **Sayılar:** Güven, baskı, dürüstlük... Hangi seçim artırır, hangisi azaltır, nerede işe yarar.
- Koşullarda "ve" hepsinin, "ya da" birinin gerektiğini; "yokken" o bayrağın açılmamış olması gerektiğini söyler.

## İçindekiler

- [Özge](#özge)
- [Orhun](#orhun)
- [Atakan](#atakan)
- [Behram](#behram)
- [İnanç](#inanç)
- [Doğa](#doğa)
- [Erdi](#erdi)
- [Kaymakam](#kaymakam)
- [0532 190 19 07](#0532-190-19-07)
- [Selin Aras](#selin-aras)
- [0543 112 07 21](#0543-112-07-21)
- [Harita görevleri](#harita-görevleri) · [Laboratuvar](#laboratuvar) · [Para](#para) · [Süreli olaylar](#süreli-olaylar) · [Kilitler](#kilitler) · [Final](#final) · [Bayraklar](#bayraklar) · [Sayılar](#sayılar)

## Ana yol

Hikâyenin kilometre taşları sırayla (`state.json › milestones`). Her aşamaya "Nasıl ulaşılır" sütunundaki yollardan biriyle varılır; aradaki her şey oyuncunun keşfine kalır.

| # | Aşama | Bayrak | Nasıl ulaşılır | Neyi açar |
| --- | --- | --- | --- | --- |
| 1 | Özge dosyayı anlatır, ilk belgeler gelir | `part1Done` | Özge › "Kapalı değildi Erdiyi engelledim ben"<br>Özge › "İfadeleri bana poltel üzerinden gönder" | Özge › soru "Basın ne diyor?"<br>Özge › soru "Sen nasılsın, uyuyabiliyor musun?"<br>Özge › soru "Berat’ın telefonu bulundu mu?"<br>Özge › soru "Deniz nasıl?"<br>Orhun › start<br>Orhun › soru "Otopsiyi kim yaptı?"<br>Orhun › soru "Akşama iki bira dedin, ne oldu o iş?"<br>Atakan › start<br>Atakan › soru "İzin günün nasıl geçti?"<br>Atakan › soru "Yusuf’u bir daha konuşturabilir misin?"<br>Erdi › start<br>Harita › Berat'ın Evi görünür<br>Harita › Kampüs Kafe görünür<br>Harita › Üniversite görünür<br>Harita › Adli Tıp Kurumu görünür<br>Pano › Olay Yeri bulunur<br>Poltel › Yusuf Kasap - İfade Tutanağı gelir<br>Poltel › Deniz Yılmaz - İfade Tutanağı gelir<br>Poltel › Berat Yılmaz - Otopsi Raporu gelir<br>Mail › emniyet.gov.tr<br>Kayıtlar › Not 1 (memo-phone) gelir<br>Sinstagram › @berat.ylmz aranabilir<br>Sinstagram › @furkan.shn aranabilir<br>Sinstagram › @yusuf.kasap aranabilir<br>Sinstagram › @deniz.yilmaz aranabilir<br>News › "Berat Yılmaz dosyasında cinayet şüphesi" çıkar |
| 2 | Orhun şüpheliyi bulduklarını söyler | `orhunDone` | Orhun › "İfadesini aldınız mı uygulamada gözükmü…" | İnanç › start |
| 3 | İnanç sorguyu ayarlar | `inancDone` | İnanç › "Şimdi bürodaki kızlardan birini yanına …"<br>İnanç › "Hayır gelmeme daha var. Buradan soracağ…" | Doğa › start |
| 4 | Furkan sorgulanır, Adil’in adı çıkar | `furkanStatement` | Doğa › "Adil'i nerede bulabiliriz?"<br>Doğa › "Bu kadar yeter. Doğa, ifadeyi tutanağa …" | Özge › soru "Furkan’ın ifadesini okudun mu?"<br>Orhun › soru "Furkan’ın ailesi aradı mı?"<br>Behram › start<br>Behram › soru "Adil kimin için çalışıyor?"<br>Doğa › soru "Sence Furkan doğruyu söyledi mi?"<br>Doğa › soru "Sen nasılsın? Sorgu ağır geçti."<br>Doğa › soru "Furkan’ın ailesiyle sen mi konuşuyorsun?"<br>Erdi › pressure<br>Harita › Sanayi Çay Ocağı görünür<br>Süreli olay › adil-warns başlar<br>Poltel › Furkan Şahin - İfade Tutanağı gelir<br>Mail › narkotik.emniyet.gov.tr<br>Sinstagram › @adil.abi aranabilir |
| 5 | Erdi baskıyı aktarır | `pressure:erdi` | Erdi › "Anlaşıldı müdürüm. Katile odaklanıyoruz."<br>Erdi › "Geçmişine bakmadan katili nasıl bulacağ…"<br>Erdi › "Kim aradı Ankara’dan?" | Özge › soru "Erdi seni de sıkıştırıyor mu?"<br>İnanç › order<br>İnanç › soru "Teşkilatta neler konuşuluyor?"<br>Erdi › desk (kendiliğinden yazar)<br>Erdi › soru "Müdürüm, savcılık dosyayı istedi mi?"<br>Erdi › soru "Ek ekip verebilir misiniz?"<br>Erdi › soru "Ne zaman döneceğimi soran oldu mu?"<br>Süreli olay › kaymakam-calls başlar |
| 6 | Kaymakam doğrudan yazar | `pressure:kaymakam` | Kaymakam › "Tabii Kaymakam Bey, gelişmeleri size bi…"<br>Kaymakam › "Soruşturma gizli Kaymakam Bey. Bilgiyi …"<br>Kaymakam › "(Cevap verme)" | Özge › soru "Kaymakam beni aradı."<br>Kaymakam › soru "Kaymakam Bey, aile ne zaman ifade vereb…"<br>Selin Aras › soru "Kaymakamı araştırıyor musun?"<br>Süreli olay › mp-writes başlar |
| 7 | Adil’le görüşen makam aracı bulunur | `plate:mv` | Harita › Sanayi Çay Ocağı › Uzaktan gözetle | Orhun › afterStatement<br>Orhun › soru "Plaka haberi gazeteye nasıl çıktı?"<br>Orhun › soru "Danışmanın adı ne?"<br>İnanç › soru "Çay ocağına baskın için hazır mısınız?"<br>Erdi › desk (kendiliğinden yazar)<br>Erdi › soru "Müdürüm, Yılmaz’ın danışmanını tanıyor …"<br>Kaymakam › informed (kendiliğinden yazar)<br>Kaymakam › soru "Yılmaz Bey’in danışmanıyla görüşmem ger…"<br>Harita › Sanayi Çay Ocağı › Çay ocağını ara görünür<br>Harita › Yılmaz Eğitim Vakfı görünür<br>Harita › Yılmaz Eğitim Vakfı › Binayı gözetle görünür<br>Pano › Makam Aracı bulunur<br>Süreli olay › kaymakam-calls başlar<br>Süreli olay › mp-writes başlar<br>News › "Cinayet soruşturmasında Meclis aracı iddiası" çıkar |
| 8 | Milletvekili baba yazar, para gelir | `mp:wrote` | Süreli olay › mp-writes: `pressure:kaymakam` ve (`plate:mv` ya da `notebook-read`) olduktan 3 dk sonra | Özge › soru "Hesabıma para yattı, kimseye söyleme."<br>Orhun › afterStatement (kendiliğinden yazar)<br>Orhun › afterPlate (kendiliğinden yazar)<br>0532 190 19 07 › start<br>ZaferBank › Gelen EFT gelir<br>ZaferBank › Gönderene iade hesabına para gönder (görünür)<br>Süreli olay › bribe-kept başlar |
| 9 | Yanık harita birleştirilir | `map-restored` | Laboratuvar › Yanık Harita | Harita › Eski Mezbaha görünür |
| 10 | Eski mezbaha bulunur | `mezbaha-found` | Harita › Eski Mezbaha › Ekip gönder | Özge › afterMezbaha<br>Özge › soru "Mezbahadaki tarihler ne anlama geliyor?"<br>Özge › soru "Kayıp öğrencilerin aileleriyle konuştun…"<br>Özge › soru "Ekip nasıl, dayanıyor mu?"<br>Orhun › afterPlate (kendiliğinden yazar)<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Atakan › soru "Yusuf’tan haber var mı?"<br>Behram › afterRaid (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar)<br>Doğa › afterFurkan (kendiliğinden yazar)<br>Erdi › desk (kendiliğinden yazar)<br>0532 190 19 07 › after (kendiliğinden yazar)<br>Selin Aras › desk (kendiliğinden yazar)<br>Pano › Mezbahadaki Sandalye bulunur<br>Pano › Duvardaki Fotoğraflar bulunur<br>Pano › Kayıp İlanı bulunur<br>Kayıtlar › Bilinmeyen Numara (unknown-2) gelir<br>News › "Sanayideki eski mezbahada gece boyu süren çalışma" çıkar<br>News › "Sanayi sakinleri tedirgin: "Geceleri o binada ışı…" çıkar |
| 11 | Ece Aydın’ın adı çıkar | `heard:ece` | Özge › soru "O ölmüş kadının hattı kimin adına?"<br>Özge › soru "Arşivdeki takipsizlik haberindeki kızın…" | Özge › soru "Ece Aydın’ın ailesinden kim kaldı?"<br>Harita › Aydın Ailesinin Evi görünür<br>Sinstagram › @ece.aydin aranabilir<br>Sinstagram › @k.aydin aranabilir |
| 12 | Kerem Aydın’ın adı çıkar | `heard:kerem` | Harita › Yılmaz Eğitim Vakfı › Gönüllü kartının fotoğrafını göster<br>Harita › Aydın Ailesinin Evi › Komşularla konuş<br>Sinstagram › @k.aydin açılınca | Orhun › soru "Kerem Aydın diye birini tanıyor musun?"<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Doğa › soru "Furkan’a Kerem Aydın’ı sor."<br>Harita › Yılmaz Eğitim Vakfı görünür<br>Harita › Yılmaz Eğitim Vakfı › Gönüllü listesini iste görünür<br>Harita › Aydın Ailesinin Evi › Ece’nin odasına bak (izinsiz) görünür |
| 13 | Kameradaki adamın Kerem olduğu anlaşılır | `kerem:identified` | Atakan › "Aramaya başlayın. Ama sessizce."<br>Atakan › "Bütün birimlere bildir. Yakalama kararı…" | Özge › soru "Kerem’in Berat’la bir bağı var mı?"<br>0543 112 07 21 › start |
| 14 | Kerem ilk kez yazar | `kerem:contact` | 0543 112 07 21 › "Berat’ı sen mi öldürdün?"<br>0543 112 07 21 › "Kız nerede Kerem?"<br>0543 112 07 21 › "Teslim ol. Sana zarar gelmez." | Süreli olay › friday başlar |
| 15 | Kerem’le buluşma ayarlanır | `kerem:meeting-set` | 0543 112 07 21 › "Özge gelecek."<br>0543 112 07 21 › "Doğa gelecek."<br>0543 112 07 21 › "Atakan gelecek."<br>0543 112 07 21 › "İnanç gelecek."<br>0543 112 07 21 › "Behram gelecek."<br>0543 112 07 21 › "Biri gelecek. (Ekibi topla, buluşma yer…" | Süreli olay › meeting başlar |
| 16 | Buluşma: Kerem’in itirafı ve şartı | `kerem:met` | Süreli olay › meeting: `kerem:meeting-set` olduktan 10 dk sonra | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar)<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Behram › raid (kendiliğinden yazar)<br>Behram › afterRaid (kendiliğinden yazar)<br>İnanç › order (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar)<br>Doğa › furkanFate (kendiliğinden yazar)<br>Doğa › afterFurkan (kendiliğinden yazar)<br>Erdi › desk (kendiliğinden yazar) |
| 17 | Kerem hakkında karar verilir (İkilem 2) | `case:solved` | Özge › "Gözaltına al."<br>Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gözaltına al."<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gözaltına al."<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Gözaltına al."<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Gitsin. Kızın yerini al."<br>Doğa › "Gözaltına al."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Gitsin. Kızın yerini al." | 0532 190 19 07 › after (kendiliğinden yazar)<br>Final › Berat Yılmaz Dosyası › Adaletin Bedeli<br>Final › Berat Yılmaz Dosyası › Kirli Eller<br>Final › Berat Yılmaz Dosyası › Sessiz Zafer |
| 18 | Soğuk hava deposuna girilir: Melis | `storage:entered` | Harita › Eski Soğuk Hava Deposu › Depoya gir | — |
| 19 | Final soruşturması (henüz yazılmadı) | `final:ready` | — | Final başlar |

## Kişiler

### Özge

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start |  | Amirim şu an yurtdışında olduğunuzu biliyorum ama yardımınızı gerektiren önemli bir durum var | Kızım ben size izindeyken bana yazmayın demedim mi ? | Amirim çok özür dilerim ama gerçekten ciddi bir olay | `trust:Özge` -5 | whatHappened |
|  |  |  | Neymiş bu kadar önemli olan durum | 3 gün önce akşam saatlerinde bir üniversite öğrencisinin kendini astığı ihbarı geldi. Olay yeri incelemesi ve otopsiden… | — | questions |
| whatHappened |  |  | Neymiş bu kadar önemli olan durum | 3 gün önce akşam saatlerinde bir üniversite öğrencisinin kendini astığı ihbarı geldi. Olay yeri incelemesi ve otopsiden… | — | questions |
| questions |  |  | Yakınlarının ifadesini aldınız mı ? | Atakan'la Doğa maktülün yakın arkadaşının ve cesedi bulan kişinin ifadesini aldılar ama görünüşe göre fazla arkadaşı yo… | — | sendStatements |
|  |  |  | Hangi davaları askıya aldınız ? | Borç meselesi yüzünden çıkan kavgada ölen adamın davasını askıya aldık ama sadece evrak işleri kalmıştı. Boş kaldığım b… | — | afterCases |
|  |  |  | Kapalı değildi Erdiyi engelledim ben | Anladım amirim. Atakan'la Doğa maktülün yakın arkadaşının ifadesini aldılar. Onları size "poltel" üzerinden gönderiyorum | `part1Done` | afterMezbaha |
| afterCases |  |  | Tamamdır hallet sen onu. Maktulün yakınlarının ifadesini aldınız mı ? | Atakan'la Doğa maktülün yakın arkadaşının ve cesedi bulan kişinin ifadesini aldılar ama görünüşe göre fazla arkadaşı yo… | — | sendStatements |
| sendStatements |  |  | İfadeleri bana poltel üzerinden gönder | Hemen gönderiyorum amirim. | `part1Done` | afterMezbaha |
| afterMezbaha | `mezbaha-found` | Amirim... mezbahadaki fotoğraflardaki iki öğrenciyi tanıdık. / İkisi de geçen ay kayıp ilanı verilmiş öğrenciler. Aileleri hâlâ arıyor. / Bu sadece Berat'la il… | Ailelere henüz bir şey söylemeyin. | Peki amirim. Ama bunu ne kadar saklayabiliriz bilmiyorum. | — | later |
|  |  |  | Bütün ekibi mezbahaya toplayın. Bu gece kimse uyumayacak. | Hemen haber veriyorum amirim. | — | later |
|  |  |  | Bundan Erdi'ye tek kelime etmeyeceksin. | ...Anladım amirim. | `erdi-kept-out`, `pressure` +10 | later |
| ozgeTox | kendiliğinden: `toxicology` ve `ozge:tox` yokken | Amirim toksikoloji geldi. Çocuğu önce bayıltmışlar. / Deniz hâlâ kuzeninin intihar ettiğini sanıyor. Ona söyleyelim mi? | Söyleyin. Bilmeye hakkı var. | Peki amirim. Ben söylerim, benden duysun. | `ozge:tox`, `deniz:told`, `trust:Özge` +5 | geldiği adıma döner |
|  |  |  | Henüz değil. Soruşturma bitene kadar kimseye söylemeyin. | Anladım amirim. Ama kolay olmayacak. | `ozge:tox` | geldiği adıma döner |
| ozgeAudit | kendiliğinden: `case:internal-investigation` ve `ozge:audit` yokken | Amirim iç denetimden aradılar. Sizi sordular. / Hesabınıza para yatmış, bilip bilmediğimi sordular. Yarın ifademi alacaklar. | Doğruyu söyle. Ne biliyorsan. | Söyleyeceğim amirim. Ama ne bildiğimi siz de biliyorsunuz. | `ozge:audit`, `integrity` +5 | geldiği adıma döner |
|  |  |  | Bildiğini söyleme.<br>_sadece: `ozge:knows-money`_ | ... / Bunu benden istemeyin amirim. / Peki. Bu sefer. | `ozge:audit`, `player:dirty-hands`, `trust:Özge` -15 | geldiği adıma döner |
|  |  |  | Sen karışma, ben hallederim. | Peki amirim. Ama dikkatli olun. | `ozge:audit` | geldiği adıma döner |
| meetOzge | kendiliğinden: `kerem:met` ve `envoy:ozge` ve `envoy:reported` yokken | Amirim buluştum. Elim hâlâ titriyor. / Yalnız geldi, sırtında bir çanta vardı. Berat’ı öldürdüğünü söyledi. Gözünü kırpmadan. / Kızın adı Melis. Nerede olduğun… | Gözaltına al. | Kelepçeyi taktım. Hiç direnmedi. / Kızın yerini sorduğumda sadece güldü: "Siz seçtiniz." | `envoy:reported`, `kerem:arrested`, `case:solved`, `ev:berat-phone`, `heard:berat-repentant`, `integrity` +5 | geldiği adıma döner |
|  |  |  | Savcıyla konuşacağım. Ona koruma ve indirim sözü ver. | Söyledim. Bana bir adres verdi: sanayideki eski soğuk hava deposu. / Savcı onay vermezse kızı kendisi çıkaracakmış. | `envoy:reported`, `kerem:deal`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `pressure` +10 | geldiği adıma döner |
|  |  |  | Gitsin. Kızın yerini al. | ...Peki amirim. Adresi verdi: sanayideki eski soğuk hava deposu. / Gitti. Arkasına bile bakmadı. | `envoy:reported`, `kerem:escaped`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `player:dirty-hands`, `integrity` -20, `trust:Özge` -10 | geldiği adıma döner |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Basın ne diyor? | `part1Done` | Kapıda iki muhabir bekliyor amirim. Şehir Postası’ndan Selin Aras bir şey biliyor gibi, "cinayet" kelimesini ilk o kullandı. | — |
| Sen nasılsın, uyuyabiliyor musun? | `part1Done` | Pek değil amirim. Annem her akşam arıyor, haberleri izledikçe korkuyor. / ...Sorduğunuz için sağ olun. | `trust:Özge` +5 |
| Erdi seni de sıkıştırıyor mu? | `pressure:erdi` | Her saat başı arıyor amirim. Raporları ona sizden önce göndermemi istedi. / Göndermedim. Önce size sormak istedim. | `trust:Özge` +5 |
| Toksikoloji sonucunu gördün mü? | `toxicology` | Gördüm amirim. Çocuğu önce bayıltmışlar. Asma süsü verecek kadar vakitleri olmuş demek. / Bu bir kavga değil, planlanmış bir şey. | — |
| Bardaktaki iz Adil’e çıktı, haberin var mı? | `print:adil` | Var amirim. Behram Başkomiserim duyunca hiç sevinmeyecek, onların aylardır süren bir operasyonu var. | — |
| Kaymakam beni aradı. | `pressure:kaymakam` | Kaymakam mı? Sizi doğrudan mı? / Amirim... bir kaymakamın bir cinayet dosyasıyla ne işi olur? | — |
| Basına kim sızdırıyor sence? | (`leak:hunt` ya da `leak:defended` ya da `leak:sources`) | Bilmiyorum amirim. Ama Selin Aras benim de numaramı biliyor, iki kere aradı. Açmadım. / Bir de... gazeteye çıkan her şeyi siz biliyordunuz.… | `doubt` +1 |
| Berat’ın telefonu bulundu mu? | `part1Done` | Bulunamadı amirim. Son sinyal olay gecesi 02.40’ta sanayi bölgesinden gelmiş. / Evden çıkmış yani. Ya da biri çıkarmış. | `heard:phone-signal` |
| Deniz nasıl? | `part1Done` | Dağılmış durumda amirim. / Bir şey daha söyledi: Berat son haftalarda yanında bir defter taşıyormuş, kimseye göstermiyormuş. | `heard:notebook` |
| Furkan’ın ifadesini okudun mu? | `furkanStatement` | Okudum. Çocuk çok korkmuş amirim. "Beni öldürür" demiş, bunu ciddiye alalım. | — |
| Mezbahadaki tarihler ne anlama geliyor? | `mezbaha-found` | Biri ileri bir tarih amirim. Önümüzdeki cuma. / Ya bir sonraki kurbanın tarihi ya da birilerinin bizi korkutmak istediği. | — |
| Bana gelen sesli mesajın numarasını sorgulatır mısın? | `heard:witness` | Sorgulattım amirim. Kontörlü bir hat, sanayideki bir büfeden alınmış. / Hat bir kadın adına kayıtlı. Kadın üç yıl önce ölmüş. | `heard:dead-line` |
| O ölmüş kadının hattı kimin adına? | `heard:dead-line` | Ece Aydın amirim. Üç yıl önce öldü, ölümü intihar sayılıp takipsizlikle kapanmış. / Biri onun hattını hâlâ kullanıyor. | `heard:ece` |
| Arşivdeki takipsizlik haberindeki kızın adını bulabilir misin? | `news:old-case-found` | Buldum amirim. Ece Aydın. Burslu bir öğrenciymiş. / Dosyada Berat’ın adı yok. Ama o gece birlikte olduğu kişilerin kimse ifadesini almamış. | `heard:ece` |
| Ece Aydın’ın ailesinden kim kaldı? | `heard:ece` | Annesi geçen yıl ölmüş amirim. Ailenin evi Eski Mahalle’de, haritana ekledim. | — |
| Kerem’in Berat’la bir bağı var mı? | `kerem:identified` | Berat’ın operatör kayıtlarını istettim amirim. / Son iki ayda onu en çok arayan numara... Ece Aydın adına kayıtlı o hat. / Berat ölmüş bir … | `heard:kerem-berat` |
| Kayıp öğrencilerin aileleriyle konuştun mu? | `mezbaha-found` | Birinin annesiyle konuştum amirim. Kızının ona attığı son mesaj "Cuma görüşürüz" imiş. | — |
| Ekip nasıl, dayanıyor mu? | `mezbaha-found` | Yorgunuz amirim. Ama mezbahayı gördükten sonra kimse eve gitmek istemiyor. | — |
| Hesabıma para yattı, kimseye söyleme. | `mp:wrote` | ... / Söylemem amirim. Ama bunu bana neden anlattınız? | `trust:Özge` +5, `ozge:knows-money` |
| Basına kim sızdırıyor sence? | (`leak:hunt` ya da `leak:defended` ya da `leak:sources`) | Bilmiyorum amirim. Ama Selin Aras benim de numaramı biliyor, iki kere aradı. Açmadım. | `doubt` +1 |

### Orhun

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `part1Done` | Amirim, Özgeyle konuşmuşsunuz sanırım. Dava ile ilgili bilgileri size ben iletebilirim. | İlet bakalım | Amirim okulu biraz soruşturduk ve Beratla görülen madde kullanan çocuğun adresini bulduk. | — | statement |
|  |  |  | Madde kullanan çocuğu buldunuz mu ? | Bulduk amirim gerçekten yusufun anlattığı yerde takılıyormuş | — | statement |
|  |  |  | Otopsi raporu ne zaman çıktı | Amirim bu dava yüzünden bütün yöneticilerin eli ayağı karıştı bu yüzden çok hızlı bir şekilde geldi otopsi raporu | `trust:Orhun` +5 | status |
| status |  |  | Anladım, ne durumdasınız şu an | Amirim okulu biraz soruşturduk ve Beratla görülen madde kullanan çocuğun adresini bulduk. | — | statement |
| statement |  |  | İfadesini aldınız mı uygulamada gözükmüyor. | İnanç alacak amirim ifadesini isterseniz ona bir yazın. | `orhunDone` | afterStatement |
| afterStatement | `plate:mv` | Amirim çay ocağındaki makam aracının plakasını ben sorgulattım. / Araç Meclis’e kayıtlı, milletvekili Yılmaz’ın danışmanına zimmetli. / Sorgulama kaydı sisteme… | İyi yaptın. Tutanağa geçir. | Geçiriyorum amirim. | `integrity` +5, `pressure` +5, `trust:Orhun` +5 | afterPlate |
|  |  |  | Bunu şimdilik kimseye söyleme. | Anladım amirim. Benden çıkmaz. | `player:dirty-hands`, `trust:Orhun` +5 | afterPlate |
|  |  |  | Neden bana sormadan sorgulattın? | Hızlı davranmak istedim amirim. Yanlış mı yaptım? | `trust:Orhun` -10 | afterPlate |
| orhunVisit | kendiliğinden: `mp:wrote` ve `orhun:approached` yokken | Amirim size bir şey söylemem lazım. Telefonda olmaz demiştim ama artık bekleyemem. / Dün akşam biri evime geldi. Borçlarımı biliyordu, icrayı bile. / "Dosyada … | Doğru yapmışsın. Adamı tarif et. | Takım elbiseli, kibar biri. Arabası siyahtı. Plakasına bakamadım. | `orhun:approached`, `trust:Orhun` +10, `heard:orhun-visitor` | geldiği adıma döner |
|  |  |  | Bunu iç denetime bildirmem gerekiyor. | ...Anlıyorum amirim. / Ama ailem bunu kaldırmaz. | `orhun:approached`, `orhun:reported`, `integrity` +5, `trust:Orhun` -10 | geldiği adıma döner |
|  |  |  | Borcun ne kadar? | Seksen bin amirim. Annemin ameliyatı için çektim. / Size söylemek istemezdim. | `orhun:approached`, `heard:orhun-debt` | geldiği adıma döner |
| orhunBlood | kendiliğinden: `mezbaha-found` ve `orhun:blood` yokken | Amirim olay yeri ekibiyle mezbahadaydım. / Kanın bir kısmı aylar öncesine ait. Burası yıllardır kullanılıyor. | Son üç yılın bütün kayıp ilanlarını tara. | Başlıyorum amirim. Sabaha bir liste çıkarırım. | `orhun:blood`, `orhun:missing-list` | afterPlate |
|  |  |  | Bu bilgiyi şimdilik raporlara yazma. | Emin misiniz amirim? Erdi Müdürüm görürse... | `orhun:blood`, `player:dirty-hands` | afterPlate |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Otopsiyi kim yaptı? | `part1Done` | Dr. Kemal Ateş. İl müdürü otopsi için bizzat aramış, rapor bir günde çıktı. Normalde bir hafta sürer. | — |
| Furkan’ın ailesi aradı mı? | `furkanStatement` | Babası geldi amirim, ağladı. Oğlunu bırakmamızı istedi. / Bir de bana "ne lazımsa yaparım" dedi. Kovdum. | — |
| Akşama iki bira dedin, ne oldu o iş? | `part1Done` | Siz dönünce amirim. / Size anlatmam gereken bir şey var aslında... neyse, telefonda olmaz. | `heard:orhun-secret` |
| Plaka haberi gazeteye nasıl çıktı? | `plate:mv` | Ben sorgulattım ama gazeteye ben vermedim amirim, yemin ederim. / Sorgu ekranını kimler görüyor bilmiyorum. Ankara da görüyor olabilir. | — |
| Annen nasıl? | `heard:orhun-debt` | Daha iyi amirim. Sorduğunuz için sağ olun. | `trust:Orhun` +5 |
| Kayıp ilanlarından ne çıktı? | `orhun:missing-list` | Son üç yılda bu şehirde altı öğrenci için kayıp ilanı verilmiş amirim. / İkisi mezbahadaki fotoğraflarda. Dördü hiç bulunmamış. | — |
| Kerem Aydın diye birini tanıyor musun? | `heard:kerem` | Adını duymadım amirim. Ama Ece Aydın dosyasını hatırlıyorum. / O zaman ben yeni gelmiştim. Dosya bir haftada kapandı, herkes şaşırmıştı. | — |
| Kerem’in üstünden ne çıktı? | `kerem:arrested` | Bir cüzdan, bir de üstünde "SH-4" yazan paslı bir anahtar amirim. / SH... soğuk hava olabilir mi? Sanayide eski bir soğuk hava deposu var. | `heard:cold-storage` |
| Danışmanın adı ne? | `plate:mv` | Sistemde "Y. Eğitim Vakfı Danışmanlık" diye geçiyor amirim, şahıs adı yok. Vakfın genel müdürü olabilir. | — |

### Atakan

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `part1Done` | Amirim Yusuf'un ifadesini ben aldım, poltelde var. Çocuk bir şey saklıyor gibiydi. | Neden öyle düşündün? | Furkan'ın adını verirken etrafına bakınıp durdu. Kendisi de o kafeye takılıyormuş, Berat'la sandığından daha yakınlar b… | `trust:Atakan` +5 | idle |
|  |  |  | Tamam, gözünüzü üzerinden ayırmayın. | Emredersiniz amirim. | — | idle |
| idle | `ev:cctv` | Amirim kafe kamerasındaki deri ceketli adamı yüz tanımadan geçirdim. Sistemde eşleşme yok. / Ama boynunda bir yaka kartı asılı. Bulanık, okunmuyor. Bir kurumda… | Görüntüyü netleştirmeye çalış. | Teknik birime yolladım amirim, iki gün sürer dediler. | `trust:Atakan` +5 | afterCctv |
|  |  |  | Kafenin diğer kameralarını da iste. | İstedim amirim. Kafeci, olaydan bir gün sonra birilerinin gelip iç kamera kayıtlarını aldığını söyledi. / Polis oldukla… | `heard:fake-police` | afterCctv |
| atakanPhoto | kendiliğinden: `mezbaha-found` ve `atakan:mezbaha` yokken | Amirim mezbahadaki fotoğraflardan biri... / Onu daha önce bir yerde gördüm sanki. / Boş verin. Yanlış hatırlıyorumdur. | Nerede gördün? | Bilmiyorum amirim. Belki bir haberde. / Gerçekten hatırlamıyorum. | `atakan:mezbaha`, `heard:atakan-photo` | geldiği adıma döner |
|  |  |  | Hatırlayınca söyle. | Söylerim amirim. | `atakan:mezbaha` | geldiği adıma döner |
| atakanCard | kendiliğinden: `card:enhanced` ve `atakan:card` yokken | Amirim teknik birim kartı netleştirdi. / Y. Eğitim Vakfı’nın gönüllü kartı. İsim okunmuyor ama vakfın logosu net. / Vakfı haritana ekledim. | Vakfa git, gönüllüleri sor. | Ekip ayarlıyorum amirim. | `atakan:card`, `heard:volunteer-card` | geldiği adıma döner |
|  |  |  | Kimseye söyleme. Vakfın kulağına gitmesin. | Anlaşıldı amirim. | `atakan:card`, `heard:volunteer-card` | geldiği adıma döner |
| atakanMatch | kendiliğinden: `heard:kerem` ve `ev:cctv` ve `atakan:match` yokken ve (`kerem:same-man` ya da `kerem:volunteer`) | Amirim, Kerem Aydın’ın ehliyet fotoğrafını kamera karesiyle karşılaştırdım. / Aynı adam. Berat’ın peşinden çıkan oydu. | Aramaya başlayın. Ama sessizce. | Emredersiniz amirim. | `atakan:match`, `kerem:identified` | geldiği adıma döner |
|  |  |  | Bütün birimlere bildir. Yakalama kararı isteyeceğim. | Hemen amirim. | `atakan:match`, `kerem:identified`, `kerem:wanted`, `pressure` +5 | geldiği adıma döner |
| meetAtakan | kendiliğinden: `kerem:met` ve `envoy:atakan` ve `envoy:reported` yokken | Amirim buluştum. Beni tanıyormuş gibi baktı, garip. / Yalnız geldi, sırtında bir çanta vardı. Berat’ı öldürdüğünü söyledi. Gözünü kırpmadan. / Kızın adı Melis.… | Gözaltına al. | Kelepçeyi taktım. Hiç direnmedi. / Kızın yerini sorduğumda sadece güldü: "Siz seçtiniz." | `envoy:reported`, `kerem:arrested`, `case:solved`, `ev:berat-phone`, `heard:berat-repentant`, `integrity` +5 | geldiği adıma döner |
|  |  |  | Savcıyla konuşacağım. Ona koruma ve indirim sözü ver. | Söyledim. Bana bir adres verdi: sanayideki eski soğuk hava deposu. / Savcı onay vermezse kızı kendisi çıkaracakmış. | `envoy:reported`, `kerem:deal`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `pressure` +10 | geldiği adıma döner |
|  |  |  | Gitsin. Kızın yerini al. | ...Peki amirim. Adresi verdi: sanayideki eski soğuk hava deposu. / Gitti. Arkasına bile bakmadı. | `envoy:reported`, `kerem:escaped`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `player:dirty-hands`, `integrity` -20, `trust:Atakan` -10 | geldiği adıma döner |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| İzin günün nasıl geçti? | `part1Done` | İyiydi amirim. Ailevi bir işti. / ...Boş verin, anlatmaya değmez. | `heard:atakan-secret` |
| Yusuf’u bir daha konuşturabilir misin? | `part1Done` | Denedim amirim, telefonu kapalı. Okula da iki gündür gelmiyormuş. | — |
| Gazeteyle konuştun mu? | `leak:hunt` | Ben mi amirim? / ...Hayır. Kimseyle konuşmadım. Neden bana soruyorsunuz? | `trust:Atakan` -5 |
| Yusuf’tan haber var mı? | `mezbaha-found` | Ailesi memleketine gittiğini söylüyor amirim. Telefonu hâlâ kapalı. | — |
| Sen iyi misin? Sesin farklı geliyor. | `heard:atakan-secret` | İyiyim amirim. / ...Sadece yorgunum. | — |
| Yırtık fotoğraftaki adamla kameradaki adam aynı kişi mi? | `photo-restored` ve `ev:cctv` | Bakıyorum amirim... / Bence aynı. Ceket aynı, duruş aynı. Kameradakinin boynunda bir kart var. / Kareyi teknik birime yollayayım, karttaki … | `kerem:same-man` |

### Behram

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `furkanStatement` | Komiserim, Furkan'ın ifadesini okudum. Adil bizim narkotik dosyasında da var, aylardır peşindeyiz. / Bu işe birlikte bakmamız lazım. Döndüğünde ilk iş konuşalı… | Tamam. Ben dönene kadar Adil'e kimse dokunmasın. | Merak etme, uzaktan izliyoruz. | `trust:Behram` +5 | raid |
|  |  |  | Bekleyemem, adamlarını hazır tut. Gerekirse bu gece alın. | Sen bilirsin komiserim. Ekip hazır. | `witnessDanger` +5 | raid |
| raid | `ev:torn-map` | Komiserim, çay ocağına baskın yapmışsınız. Adil kaçtı. / Altı aylık operasyonumuz yandı. Bana bir haber verebilirdin. | Bekleyemezdim. Bir çocuk öldü. | Biliyorum. Ama Adil artık daha dikkatli olacak. | `trust:Behram` -10 | afterRaid |
|  |  |  | Haklısın, sana haber vermeliydim. | Neyse. Olan oldu. Bundan sonra birlikte hareket edelim. | `trust:Behram` +5 | afterRaid |
|  |  |  | Adil’in saklanacağı yeri sen bilirsin. Yardım et. | Birkaç yeri var. Adamlarıma baktırırım, ama bu sefer benim dediğim gibi. | `behram:helps` | afterRaid |
| behramList | kendiliğinden: `behram:helps` ve `mezbaha-found` ve `behram:depot` yokken | Komiserim, Adil’in sakladığı bir depo bulduk. Adil yok. / Ama duvarda bir liste var. İsimler ve yanlarında tarihler. / İsimlerden biri Berat. | Listeyi bana gönder. | Gönderiyorum. Kimseye gösterme. | `behram:depot`, `behram:list` | afterRaid |
|  |  |  | Listedeki diğer isimler kim? | Üç öğrenci, bir de baş harfleri: "H.Y." / Kim olduğunu bilmiyorum. | `behram:depot`, `behram:list`, `heard:initials` | afterRaid |
| meetBehram | kendiliğinden: `kerem:met` ve `envoy:behram` ve `envoy:reported` yokken | Komiserim buluştum. Adil’in adını duyunca gözleri değişti. / Yalnız geldi, sırtında bir çanta vardı. Berat’ı öldürdüğünü söyledi. Gözünü kırpmadan. / Kızın adı… | Gözaltına al. | Kelepçeyi taktım. Hiç direnmedi. / Kızın yerini sorduğumda sadece güldü: "Siz seçtiniz." | `envoy:reported`, `kerem:arrested`, `case:solved`, `ev:berat-phone`, `heard:berat-repentant`, `integrity` +5 | geldiği adıma döner |
|  |  |  | Savcıyla konuşacağım. Ona koruma ve indirim sözü ver. | Söyledim. Bana bir adres verdi: sanayideki eski soğuk hava deposu. / Savcı onay vermezse kızı kendisi çıkaracakmış. | `envoy:reported`, `kerem:deal`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `pressure` +10 | geldiği adıma döner |
|  |  |  | Gitsin. Kızın yerini al. | ...Peki amirim. Adresi verdi: sanayideki eski soğuk hava deposu. / Gitti. Arkasına bile bakmadı. | `envoy:reported`, `kerem:escaped`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `player:dirty-hands`, `integrity` -20, `trust:Behram` -10 | geldiği adıma döner |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Adil kimin için çalışıyor? | `furkanStatement` | Kendi hesabına derler ama o kadar parayı tek başına döndüremez. / Arkasında biri var. Adını kimse söylemiyor. | — |
| Adil’in sabıka kaydını yollar mısın? | `print:adil` | Yolladım. Gasp, uyuşturucu, bir de kapanmış bir "kayıp şahıs" dosyası var, ilginç. | `heard:adil-missing-case` |
| Narkotiğin Adil’le bir anlaşması var mıydı? | `behram:helps` | ... / Muhbirdi. Bir zamanlar. / Bunu kimseye söyleme komiserim. | `heard:adil-informant` |
| Adil şimdi nerede olabilir? | `ev:torn-map` | Şehirden çıkmadı, bundan eminim. Birileri onu saklıyor. | — |
| Cuma gecelerini biliyor muydunuz? | `heard:adil-informant` | ... / Biliyorduk. Borç tahsilatı sandık. Adil bize yukarıyı veriyordu, biz de aşağıya bakmıyorduk. / O çocukların fotoğraflarını gördüğümde… | `behram:guilt`, `trust:Behram` +5 |
| Adil’in listesiyle Furkan’ın "cuma geceleri" uyuşuyor mu? | `behram:list` ve `furkan:friday` | Uyuşuyor. Listedeki tarihler hep cuma. / Ve araçlar o gecelerde hep aynı yere gidiyormuş: sanayideki eski soğuk hava deposu. | `heard:cold-storage` |

### İnanç

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `orhunDone` |  | Naptınız oğlum sorgu işini | Amirim, elemanı evinden aldık biraz sonra sorguya girecektik | — | plan |
| plan |  |  | Benim söyleyeceğim sorularla alın ifadesini. | Yurtdışından döndünüz mü amirim. Siz gelene kadar bekletelim elemanı | — | notBack |
|  |  |  | Şimdi bürodaki kızlardan birini yanına al. Eleman ne söylüyorsa bana yazsın. Sen de benim… | Tamamdır doğaya haber verdim ben. Ona söylediğiniz zaman sorguya başlayabiliriz. | `inancDone` | order |
| notBack |  |  | Hayır gelmeme daha var. Buradan soracağım ben soruları | Anladım amirim. Doğa'yı yanıma alıyorum, sorularınızı ona yazın. | `inancDone`, `trust:İnanç` -5 | order |
| order | `pressure:erdi` | Amirim, Erdi Müdürüm beni odasına çağırdı. / Sorgu kayıtlarını size değil, doğrudan ona göndermemi istedi. / Emir emirdir ama... size sormadan yapmak istemedim. | Ne istiyorsa ver, sorun çıkmasın. | Emredersiniz amirim. | `integrity` -5, `trust:İnanç` -5 | afterOrder |
|  |  |  | Bana gönder. Erdi’yle ben konuşurum. | Sağ olun amirim. Açıkçası rahatladım. | `trust:İnanç` +10, `pressure` +5 | afterOrder |
|  |  |  | İkimize de gönder, kayıt dışı bir şey yapmayalım. | Anlaşıldı amirim. Kayda da geçiriyorum. | `integrity` +5, `trust:İnanç` +5 | afterOrder |
| inancRecords | kendiliğinden: `leak:hunt` ve `inanc:records` yokken | Amirim, Erdi Müdürüm sızıntı yüzünden herkesin telefon kayıtlarını istedi. / Sizinkini de. / Savcı onayı yok. Ne yapayım? | Ver. Saklayacak bir şeyimiz yok. | Peki amirim. Sizinkini de veriyorum. | `inanc:records`, `inanc:records-given` | afterOrder |
|  |  |  | Verme. Savcı onayı olmadan kimse kimsenin kaydına bakamaz. | Ben de öyle düşünüyorum amirim. Ama Erdi Müdürüm bunu unutmaz. | `inanc:records`, `trust:İnanç` +5, `pressure` +5 | afterOrder |
|  |  |  | Benimkini verme. Diğerlerini ver. | ... / Emredersiniz amirim. | `inanc:records`, `player:dirty-hands`, `trust:İnanç` -10 | afterOrder |
| inancCamera | kendiliğinden: `mezbaha-found` ve `inanc:camera` yokken | Amirim mezbahaya giden yolda belediyenin bir güvenlik kamerası var. / Kayıtları istedim, "arızalı" dediler. Üç aydır arızalıymış. | Arızayı kimin bildirdiğini öğren. | Öğreniyorum amirim. | `inanc:camera`, `heard:camera-broken` | afterOrder |
|  |  |  | Tamam. Başka kamera var mı, ona bak. | Bakıyorum amirim. | `inanc:camera` | afterOrder |
| meetInanc | kendiliğinden: `kerem:met` ve `envoy:inanc` ve `envoy:reported` yokken | Amirim buluşma tamam. Kurala uydum, silahsız gittim. / Yalnız geldi, sırtında bir çanta vardı. Berat’ı öldürdüğünü söyledi. Gözünü kırpmadan. / Kızın adı Melis… | Gözaltına al. | Kelepçeyi taktım. Hiç direnmedi. / Kızın yerini sorduğumda sadece güldü: "Siz seçtiniz." | `envoy:reported`, `kerem:arrested`, `case:solved`, `ev:berat-phone`, `heard:berat-repentant`, `integrity` +5 | geldiği adıma döner |
|  |  |  | Savcıyla konuşacağım. Ona koruma ve indirim sözü ver. | Söyledim. Bana bir adres verdi: sanayideki eski soğuk hava deposu. / Savcı onay vermezse kızı kendisi çıkaracakmış. | `envoy:reported`, `kerem:deal`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `pressure` +10 | geldiği adıma döner |
|  |  |  | Gitsin. Kızın yerini al. | ...Peki amirim. Adresi verdi: sanayideki eski soğuk hava deposu. / Gitti. Arkasına bile bakmadı. | `envoy:reported`, `kerem:escaped`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `player:dirty-hands`, `integrity` -20, `trust:İnanç` -10 | geldiği adıma döner |
| ambush | kendiliğinden: `kerem:met` ve `envoy:ambush` ve `envoy:reported` yokken | Amirim buluşma yerini sardık. Fark etti. / Arka sokaktan kaçtı. Çantasını düşürdü. / İçinden Berat’ın telefonu çıktı. Ama kızın nerede olduğunu artık bilen yok. | Bütün çıkışları kapatın. | Kapattık amirim. Yok. Yer yarıldı içine girdi. | `envoy:reported`, `kerem:escaped-ambush`, `ev:berat-phone`, `heard:berat-repentant`, `witnessDanger` +10 | geldiği adıma döner |
|  |  |  | Peşini bırakın. Telefon yeter. | Anlaşıldı amirim. | `envoy:reported`, `kerem:escaped-ambush`, `ev:berat-phone`, `heard:berat-repentant` | geldiği adıma döner |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Teşkilatta neler konuşuluyor? | `pressure:erdi` | Herkes bu dosyanın birilerinin kariyerini bitireceğini söylüyor amirim. / Kiminkini bilen yok. | — |
| Çay ocağına baskın için hazır mısınız? | `plate:mv` | Hazırız amirim. Siz deyin, yarım saatte oradayız. | — |
| Telefon kayıtlarına baktılar mı? | `inanc:records-given` | Baktılar amirim. Sizin kaydınızla ilgili bir şey sordular, "yurt dışından aranmış gibi görünmüyor" dediler. / Ben de bilmem dedim. | `heard:records-odd`, `doubt` +1 |

### Doğa

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `inancDone` | Amirim sorgu odasındayız. Furkan karşımda, sorularınızı bekliyorum. | Berat'ı nereden tanıyorsun? | Furkan: "Okuldan abi. Bir iki kere okulun karşısındaki kafede oturduk, o kadar." | — | package |
|  |  |  | Seni Berat'tan paket alırken görmüşler. O pakette ne vardı? | Furkan: "Ne paketi abi? Sigara verdi bana, sigara." | — | package |
|  |  |  | Önce bir su ver çocuğa, korkmuş gibi. | Verdim amirim, biraz rahatladı. Sorularınızı alayım. | `trust:Doğa` +5 | calm |
| calm |  |  | Berat'ı nereden tanıyorsun? | Furkan: "Okuldan abi. Bir iki kere okulun karşısındaki kafede oturduk, o kadar." | — | package |
|  |  |  | Seni Berat'tan paket alırken görmüşler. O pakette ne vardı? | Furkan: "Ne paketi abi? Sigara verdi bana, sigara." | — | package |
| package |  |  | Yalan söyleme! Kameralarda her şey var, pakette ne vardı? | Furkan: "Tamam tamam bağırmayın! Ot vardı abi. Berat satıyordu, ben de ondan alıyordum." | — | supplier |
|  |  |  | Doğruyu söylersen sana yardım ederiz. Pakette ne vardı? | Furkan: "Ot vardı abi... Berat satıyordu, ben sadece kendime alıyordum. Ailem duymasın ne olur." | `trust:Doğa` +5 | supplier |
|  |  |  | Olay gecesi neredeydin? | Furkan: "Kafedeydim abi, kapanana kadar. Kafeci de gördü, kameralara bakın." | — | packageAfterAlibi |
| packageAfterAlibi |  |  | Yalan söyleme! Kameralarda her şey var, pakette ne vardı? | Furkan: "Tamam tamam bağırmayın! Ot vardı abi. Berat satıyordu, ben de ondan alıyordum." | — | supplier |
|  |  |  | Doğruyu söylersen sana yardım ederiz. Pakette ne vardı? | Furkan: "Ot vardı abi... Berat satıyordu, ben sadece kendime alıyordum. Ailem duymasın ne olur." | `trust:Doğa` +5 | supplier |
| supplier |  |  | Berat malı kimden alıyordu? | Furkan: "Adil diye biri var, herkes Adil abi der. Berat ona borçlandığını söylemişti geçen hafta." | — | adil |
|  |  |  | Berat'ın başı birileriyle dertte miydi? | Furkan: "Adil abiye borcu vardı. Ödemezse başım yanar diyordu. Gülüyordu ama korkuyordu bence." | — | adil |
| adil |  |  | Adil'i nerede bulabiliriz? | Furkan: "Sanayinin girişindeki çay ocağında takılır. Ama benden duymadınız abi, beni öldürür." / İfadeyi tutanağa geçir… | `furkanStatement` | furkanFate |
|  |  |  | Bu kadar yeter. Doğa, ifadeyi tutanağa geçir. | Tamamdır amirim, poltele yüklüyorum. | `furkanStatement` | furkanFate |
| furkanFate | `adil:warns` | Amirim Furkan’ı ne yapalım? Gözaltı süresi doluyor, ailesi kapıda. / Bir de... bürodaki sabit hatta biri aradı. "Çocuk bir şey bilmez, bıraksınlar" deyip kapat… | Serbest bırakın ama gözünüzü ayırmayın. | Peki amirim. Bir ekip arkasından gidecek. | `furkan:released`, `witnessDanger` +15 | afterFurkan |
|  |  |  | Savcıdan süre uzatması isteyin. İçeride daha güvende. | Ben de öyle düşünüyorum amirim. Korkusundan titriyor. | `furkan:held`, `trust:Doğa` +5, `witnessDanger` -5 | afterFurkan |
|  |  |  | Tanık koruma için başvurun. | Erdi Müdürüm onaylamaz amirim ama başvuruyu yaparım. | `furkan:protected`, `pressure` +5, `witnessDanger` -10 | afterFurkan |
| furkanGone | kendiliğinden: `furkan:released` ve `mezbaha-found` ve `doga:furkan-news` yokken | Amirim... Furkan dün geceden beri eve gelmemiş. / Ekip kapının önündeydi, arka bahçeden çıkmış. Telefonu kapalı. / Annesi bizi suçluyor. Haklı da. | Bütün ekipleri seferber et. Bulun onu. | Hemen amirim. | `doga:furkan-news`, `furkan:missing`, `witnessDanger` +10, `pressure` +5 | afterFurkan |
|  |  |  | Adil’in adamlarının elinde olabilir. Behram’a haber ver. | Arıyorum amirim. | `doga:furkan-news`, `furkan:missing`, `witnessDanger` +10 | afterFurkan |
| furkanTalks | kendiliğinden: `mezbaha-found` ve `doga:furkan-news` yokken ve (`furkan:held` ya da `furkan:protected`) | Amirim Furkan’a mezbahayı sordum. Rengi attı. / "Cuma geceleri Adil abi bazı çocukları arabasına bindirirdi. Bir daha görmezdik" dedi. | İfadesine ekle. | Ekliyorum amirim. | `doga:furkan-news`, `furkan:friday`, `integrity` +5 | afterFurkan |
|  |  |  | Bunu kimse bilmesin. Önce onu korumamız lazım. | Anladım amirim. | `doga:furkan-news`, `furkan:friday`, `witnessDanger` -5 | afterFurkan |
| meetDoga | kendiliğinden: `kerem:met` ve `envoy:doga` ve `envoy:reported` yokken | Amirim buluştum. Çok yorgun görünüyordu, bir çocuk gibi. / Yalnız geldi, sırtında bir çanta vardı. Berat’ı öldürdüğünü söyledi. Gözünü kırpmadan. / Kızın adı M… | Gözaltına al. | Kelepçeyi taktım. Hiç direnmedi. / Kızın yerini sorduğumda sadece güldü: "Siz seçtiniz." | `envoy:reported`, `kerem:arrested`, `case:solved`, `ev:berat-phone`, `heard:berat-repentant`, `integrity` +5 | geldiği adıma döner |
|  |  |  | Savcıyla konuşacağım. Ona koruma ve indirim sözü ver. | Söyledim. Bana bir adres verdi: sanayideki eski soğuk hava deposu. / Savcı onay vermezse kızı kendisi çıkaracakmış. | `envoy:reported`, `kerem:deal`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `pressure` +10 | geldiği adıma döner |
|  |  |  | Gitsin. Kızın yerini al. | ...Peki amirim. Adresi verdi: sanayideki eski soğuk hava deposu. / Gitti. Arkasına bile bakmadı. | `envoy:reported`, `kerem:escaped`, `case:solved`, `kerem:told-location`, `ev:berat-phone`, `heard:berat-repentant`, `player:dirty-hands`, `integrity` -20, `trust:Doğa` -10 | geldiği adıma döner |
| melis | kendiliğinden: `girl:rescued` ve `doga:melis` yokken | Amirim Melis’le konuştum. Hastanede, serum takılı. / Onu takım elbiseli bir adam sorgulamış. Yüzünü hiç göstermemiş. "Vakıf seni bu kadar okuttu, borcunu öde" … | Ona koruma ver. Kimse yanına yaklaşmasın. | Kapısında iki kişi bekleyecek amirim. | `doga:melis`, `witness:protected`, `melis:statement`, `witnessDanger` -10 | afterFurkan |
|  |  |  | İfadesini tutanağa geçir, hemen. | Geçiriyorum amirim. Ama çok yorgun. | `doga:melis`, `melis:statement`, `integrity` +5 | afterFurkan |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Sence Furkan doğruyu söyledi mi? | `furkanStatement` | Çoğunu söyledi amirim. / Ama Adil’den bahsederken korkusu... sadece borç korkusu değildi. | — |
| Furkan nasıl? | `furkan:released` | Ailesine teslim ettik amirim. Ekip kapının önünde bekliyor ama çocuk perdeleri bile açmıyor. | — |
| Furkan nasıl? | `furkan:held` | Nezarette amirim. Yemek yemiyor. Annesi her gün kapıda bekliyor. | — |
| Furkan nasıl? | `furkan:protected` | Başvuru Ankara’ya gitti amirim. O gelene kadar onu evimin yakınındaki bir otelde tutuyoruz. | — |
| Sen nasılsın? Sorgu ağır geçti. | `furkanStatement` | İyiyim amirim. / Ama çocuğun yüzü aklımdan çıkmıyor. | `trust:Doğa` +5 |
| Furkan’ın ailesiyle sen mi konuşuyorsun? | `furkanStatement` | Evet amirim. Annesi her gün arıyor. Ona yalan söylemekten yoruldum. | — |
| Furkan’a Kerem Aydın’ı sor. | `heard:kerem` ve (`furkan:held` ya da `furkan:protected`) | Sordum amirim. "Berat’la gezen sakallı abi" dedi. "Berat ona güveniyordu, ona her şeyi anlatırdı." | — |
| Kerem sorguda konuşuyor mu? | `kerem:arrested` | Konuşmuyor amirim. Sadece duvara bakıp "Cuma" diyor. | — |

### Erdi

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `part1Done` | Neredesin sen telefonları da açmıyosun. Senin kadar sorumsuz herif görmedim ben. Bütün asayiş birbirine girdi sen tatil yapıyorsun | Biliyorsun nerede olduğumu | Kimse bilmiyor nerede olduğunu. İzin alacağın zamana bak | — | calm |
|  |  |  | Olaylardan haberim var buradan müdahale ediyorum. Türkiye'ye dönmem en az 3 gün sürer | Bu dava özel bir dava elinizden geleni yapın gerekirse bütün imkanları devreye sokarız. | — | calm |
|  |  |  | (Cevap verme) |  | — | pressure |
| calm |  |  | Sen içini ferah tut |  | — | pressure |
| pressure | (`toxicology` ya da `furkanStatement` ya da `heard:adil`) | Bana bak. Bugün il müdürü iki kere aradı, Ankara’dan da arayan olmuş. / Aile çok hassas. Çocuğun uyuşturucu işi, okul meselesi, ne varsa basına sızarsa hepimiz… | Anlaşıldı müdürüm. Katile odaklanıyoruz. | Aferin. Raporları bana doğrudan yolla, başka kimseye değil. | `pressure:erdi`, `integrity` -5 | desk |
|  |  |  | Geçmişine bakmadan katili nasıl bulacağız müdürüm? | Sen bana akıl verme. Ne gerekiyorsa yap ama sessiz yap. / Bu iş benden de büyük, anladın mı? | `pressure:erdi`, `pressure` +10 | desk |
|  |  |  | Kim aradı Ankara’dan? | Sana ne kim aradıysa! / ...Bak, ben de emir alıyorum. Kaymakam bile işin içinde. Dikkatli ol. | `pressure:erdi` | desk |
| warning | kendiliğinden: (`pressure:refused` ya da `bribe:returned`) | Ne yaptın sen? Kaymakam beni aradı, adam çok kızgındı. / Ben de emir alıyorum, bunu anla. Bir daha benim üstümden iş çevirirsen dosyayı senden alırım. | Kimsenin üstünden iş çevirmiyorum müdürüm, işimi yapıyorum. | İşini yap ama bana yapma. Seni bir kere daha korurum, iki olmaz. | `pressure` +5 | desk |
|  |  |  | Haklısınız müdürüm, dikkat ederim. | Dikkat et. Bu dosya birilerinin kariyerini bitirecek, seninki olmasın. | `pressure` -5 | desk |
|  |  |  | Size kim emir veriyor müdürüm? | ... / Bu soruyu bir daha telefonda sorma. | `heard:erdi-ordered` | desk |
| leakTox | kendiliğinden: `pressure:erdi` ve `toxicology` | Şehir Postası’nı gördün mü? "Berat Yılmaz’a ölmeden önce ilaç verilmiş." / Toksikoloji raporu dün akşam çıktı. Raporu bizden başka gören yok! / Kim sızdırıyor … | Benim ekibimden kimse gazeteciyle konuşmaz müdürüm. | Konuşmaz mı? O zaman gazeteci raporu rüyasında mı gördü? / Bul o köstebeği. Bulamazsan ben bulurum, o zaman hiç hoşuna … | `leak:defended`, `pressure` +5 | desk |
|  |  |  | Ekibi tek tek konuşturacağım. | Konuştur. Ama sessiz yap, bir de bu haber çıkmasın. | `leak:hunt`, `pressure` -5 | desk |
|  |  |  | Rapor sadece bizde değil müdürüm. Adli Tıp’ta, savcılıkta, il müdürlüğünde de var. | Bana ders mi veriyorsun? / ...Haklı olabilirsin. Ama gazete senin adını yazıyor, benimkini değil. | `leak:sources`, `pressure` +5 | desk |
| leakPlate | kendiliğinden: `plate:mv` | Meclis aracının plakası gazetede! Milletvekili beni aradı, sesini bir duysan... / Plakayı kim sorguladıysa adı sistemde. Orhun mu? Söyle bana. / Bir haber daha… | Sorguyu ben istedim. Sorumlusu benim. | Bak sen... Kahramanlık yapma. Kahramanlar bu teşkilatta ilk gidenlerdir. | `trust:Orhun` +10, `pressure` +10 | desk |
|  |  |  | Orhun sorguladı ama sızdıran o değil. | Değilse kim? Bana bir isim getir. | `trust:Orhun` -5, `pressure` +5, `leak:hunt` | desk |
|  |  |  | Plakanın gazetede olması kimin işine yarar müdürüm, hiç düşündünüz mü? | ... / Telefonda olmaz bu konuşma. | `leak:who-benefits` | desk |
| leakMezbaha | kendiliğinden: `mezbaha-found` | Mezbahayı gazeteden öğrendim! Sabah il müdürü aradı, ben "hangi mezbaha" diye sordum. Rezil oldum. / Bana rapor vermeden basına veriyorsunuz demek. / Bu son uy… | Mezbahayı gece bulduk müdürüm, raporu sabah yollayacaktım. | Gazete senden hızlıymış o zaman. | `pressure` +5 | desk |
|  |  |  | Sızıntıyı ben de araştırıyorum. Bizden değil. | Bunu üçüncü kez söylüyorsun. İnanmamı bekleme artık. | `leak:hunt`, `pressure` +5 | desk |
|  |  |  | (Cevap verme) |  | `pressure` +10 | desk |
| erdiAudit | kendiliğinden: `case:internal-investigation` ve `erdi:audit` yokken | İç denetim dosyanı istedi. / Hesabına yatan o para neydi? | Hediye gibi gönderilmiş. İade edecektim. | "Edecektim." Güzel kelime. Denetimde de böyle söyle, belki inanırlar. | `erdi:audit` | desk |
|  |  |  | Size söyleyecek bir şeyim yok. | Bana yok, denetime var. Avukat bul kendine. | `erdi:audit`, `pressure` +5 | desk |
|  |  |  | Parayı kimin gönderdiğini siz de biliyorsunuz. | ... / Ben hiçbir şey bilmiyorum. Bu konuşma hiç olmadı. | `erdi:audit`, `heard:erdi-knows-money` | desk |
| erdiRescue | kendiliğinden: `girl:rescued` ve `erdi:rescue` yokken | Duydum. Kızı çıkarmışsınız. / Basına açıklamayı ben yapacağım. Sen sesini çıkarma, yurt dışındasın zaten. | Siz bilirsiniz müdürüm. | Aferin. Böyle devam. | `erdi:rescue` | desk |
|  |  |  | Bu ekibin başarısı, sizin değil. | Ekibin başarısı benim başarım. Unutma bunu. | `erdi:rescue`, `pressure` +5 | desk |
| erdiArrest | kendiliğinden: `kerem:arrested` ve `erdi:arrest` yokken | Katili almışsınız. Aferin. / Şimdi dosyayı hemen kapatıyoruz. Gerisi beni ilgilendirmez. | Kapatamayız. Kızlar hâlâ kayıp. | Kızlar başka dosya. Bu dosya bitti. | `erdi:arrest`, `pressure` +5 | desk |
|  |  |  | Anlaşıldı. | Güzel. | `erdi:arrest`, `pressure` -5 | desk |
| erdiEscape | kendiliğinden: `kerem:met` ve `erdi:escape` yokken ve (`kerem:escaped` ya da `kerem:escaped-ambush`) | Katili elinizden kaçırmışsınız! / Biliyor musun Ankara bunu kime soracak? Bana! | Bir hayat kurtarmak için gerekiyordu. | Hayat kurtarmak benim işim değil. Benim işim dosya kapatmak. | `erdi:escape` | desk |
|  |  |  | (Cevap verme) |  | `erdi:escape` | desk |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Müdürüm, savcılık dosyayı istedi mi? | `pressure:erdi` | Savcı Bey bana bırakın dedi. Ben de sana bırakıyorum. Bırakılan işi yarım bırakma. | — |
| Ek ekip verebilir misiniz? | `pressure:erdi` | Verirsem herkes bu dosyanın büyüdüğünü anlar. Elindekilerle idare et. | — |
| Müdürüm, iç denetim neden benim hesabıma bakıyor? | `case:internal-investigation` | Hesabına para yatmış, iade etmemişsin diyorlar. / Ben bir şey bilmiyorum, bilmek de istemiyorum. Kendi pisliğini kendin temizle. | — |
| Sızıntıyı araştıran var mı? | (`leak:hunt` ya da `leak:defended` ya da `leak:sources`) | Var. Ben. Ve listenin başında sen varsın. | — |
| Müdürüm, Yılmaz’ın danışmanını tanıyor musunuz? | `plate:mv` | Herkes tanır. Ankara’da kapı açan adamdır. / Uzak dur ondan. | — |
| Ne zaman döneceğimi soran oldu mu? | `pressure:erdi` | Herkes soruyor. Ben de soruyorum. Nerede olduğunu bile bilmiyoruz. | `doubt` +1 |

### Kaymakam

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `kaymakam:calls` | Komiser Bey merhaba, ben Kaymakam Cevdet Arslan. Numaranızı müdürünüzden aldım, kusura bakmayın. / Milletvekilimiz Yılmaz Bey’in acısı tarifsiz. Kendisi ilçemi… | Tabii Kaymakam Bey, gelişmeleri size bildiririm. | Çok makbule geçer. Yılmaz Bey de duyunca memnun olacak. | `pressure:kaymakam`, `kaymakam:informed`, `integrity` -10 | informed |
|  |  |  | Soruşturma gizli Kaymakam Bey. Bilgiyi ancak savcılık verebilir. | Elbette, elbette. Usulü bilirim. / Ama usul her zaman insanı korumaz Komiser Bey. Hayırlı günler. | `pressure:kaymakam`, `pressure:refused`, `pressure` +10, `integrity` +5 | refused |
|  |  |  | (Cevap verme) |  | `pressure:kaymakam`, `pressure:refused`, `pressure` +5 | refused |
| kaymakamPlate | kendiliğinden: `plate:mv` ve `kaymakam:plate` yokken | Komiser Bey, plakadan haberim oldu. / Bunu aileye nasıl açıklayacağız? Bir çözüm bulmamız lazım. | Kimden duydunuz? | Ben her şeyi duyarım Komiser Bey. İşim bu. | `kaymakam:plate`, `heard:kaymakam-knew` | informed |
|  |  |  | Açıklanacak bir şey yok. Soruşturma sürüyor. | Peki. Ama sürünce kimlere dokunacağını iyi düşünün. | `kaymakam:plate`, `pressure` +5 | informed |
| kaymakamReturned | kendiliğinden: `bribe:returned` ve `kaymakam:returned` yokken | Komiser Bey, bir yanlış anlaşılma olmuş sanırım. Yılmaz Bey çok kırılmış. / Size dostluk eli uzatılmıştı. | Dostluğun banka hesabından gelmesine alışık değilim. | Anlaşıldı. Hayırlı günler Komiser Bey. | `kaymakam:returned`, `pressure` +10 | refused |
|  |  |  | (Cevap verme) |  | `kaymakam:returned` | refused |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Kaymakam Bey, aile ne zaman ifade verebilir? | `pressure:kaymakam` | Yılmaz Bey şu an kimseyle görüşecek durumda değil. Ne gerekiyorsa bana sorun, ben iletirim. | — |
| Yılmaz Bey’in danışmanıyla görüşmem gerekiyor. | `plate:mv` | Danışmanı mı? Neden? / ...Ben ayarlarım. Siz doğrudan aramayın, yanlış anlaşılır. | — |

### 0532 190 19 07

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `mp:wrote` | Komiser Bey, ben Berat’ın babasıyım. Bu numarayı kimse bilmiyor, böyle kalsın. / Oğlumu kim öldürdüyse bulun. Bunun için ne gerekiyorsa yaparım. / Ama Berat’ın… | Bu parayı kabul edemem Yılmaz Bey. | Geri göndermeyin. Bu bir hediye değil, bir rica. / Düşünün. Acele etmeyin. | `integrity` +5 | after |
|  |  |  | Oğlunuzun hangi hataları? | Bunu sormayın. / Sormayın ki ben de cevap vermek zorunda kalmayayım. | `heard:berat-past` | after |
|  |  |  | Anlıyorum. Elimden geleni yapacağım. | Biliyordum. Siz akıllı bir adamsınız. | `integrity` -5 | after |
|  |  |  | (Cevap verme) |  | — | after |
| returned | kendiliğinden: `bribe:returned` ve `mp:returned-seen` yokken | Paramı geri göndermişsiniz. / Peki. Ben bir baba olarak elimden geleni yaptım. Bundan sonrası benim elimde değil. | Evet. Gönderdim. | ... | `mp:returned-seen` | after |
| mpMezbaha | kendiliğinden: `mezbaha-found` ve `mp:mezbaha` yokken | Mezbahayı duydum. / Berat oraya... Hayır. Oğlum oraya hiç gitmedi. / Duyuyor musunuz? Hiç gitmedi. | Oğlunuzun fotoğrafı duvardaydı Yılmaz Bey. | ... / Bir daha bu numaraya yazmayın. | `mp:mezbaha`, `mp:silent` | after |
|  |  |  | Neden bu kadar eminsiniz? | Çünkü... / Çünkü ben biliyorum. | `mp:mezbaha`, `heard:mp-knows-mezbaha` | after |
| mpKiller | kendiliğinden: `case:solved` ve `mp:killer` yokken | Oğlumu öldüreni bulmuşsunuz. Adı ne? | Kerem Aydın. Ece Aydın’ın ağabeyi. | ... / O kız. / Bir daha bu numaraya yazmayacağım. | `mp:killer`, `heard:mp-ece` | after |
|  |  |  | Söyleyemem. | Ben öğrenirim Komiser Bey. Her zaman öğrenirim. | `mp:killer` | after |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Berat’la en son ne zaman konuştunuz? | her zaman | Ölmeden iki gün önce. / Benden para istedi. Vermedim. / Ona son söylediğim şey "kendi pisliğini kendin temizle" oldu. | `heard:mp-refused-money` |

### Selin Aras

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | (`leak:hunt` ya da `leak:defended` ya da `leak:sources`) | Komiser Bey merhaba, Selin Aras, Şehir Postası. / Numaranızı nereden bulduğumu sormayın. Haberlerim yüzünden başınızın ağrıdığını biliyorum. / Size bir şey sor… | Kaynağın kim? | Kaynağımı söylemem, siz de söylemezdiniz. / Ama şunu söyleyeyim: bana ilk ulaşan sizin binanızdan değildi. | `selin:talked`, `heard:source-outside` | desk |
|  |  |  | Hangi dosya? | Takipsizlikle kapanan bir ölüm. Üniversiteli bir kız. / Arşivimize bakın. Adını ben vermeyeyim. | `selin:talked`, `heard:old-case` | desk |
|  |  |  | Benimle bir daha iletişime geçmeyin. | Peki. Ama ben yazmaya devam edeceğim, sizinle ya da sizsiz. | `selin:refused` | desk |
| selinFamilies | kendiliğinden: `selin:talked` ve `mezbaha-found` ve `selin:families` yokken | Komiser Bey, mezbahadaki fotoğraflardan birinin kayıp ilanını ben yazmıştım. / Ailesi benimle konuşuyor. Yarın haberi yayımlayacağım. / Kızın adını çıkarmamı i… | Adını çıkar. Ailesi korunmalı. | Peki. Adsız yayımlayacağım. | `selin:families`, `press:anonymous`, `witnessDanger` -5 | desk |
|  |  |  | Yayımla. Herkes duysun. | Yayımlıyorum. Bundan sonra kimse saklayamaz. | `selin:families`, `press:named`, `witnessDanger` +10, `pressure` +10 | desk |
|  |  |  | Hiç yayımlama. Soruşturmayı tehlikeye atarsın. | Bunu bir polisten ilk kez duymuyorum. / Düşüneceğim. | `selin:families`, `press:held` | desk |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Berat hakkında başka ne biliyorsun? | `selin:talked` | Yılmaz Vakfı’nın burs listesinde adı var. Burs alan bir milletvekili oğlu. / Garip değil mi? | — |
| Kaymakamı araştırıyor musun? | `selin:talked` ve `pressure:kaymakam` | Herkes gibi onu da araştırıyorum Komiser Bey. / Bir sonraki seçimde Yılmaz’ın koltuğuna aday olacağı konuşuluyor. / Size bilgi sorduysa, ai… | `heard:kaymakam-rival` |
| Sana bilgi verirsem ne yaparsın? | `selin:talked` | Doğrulamadan hiçbir şey yayımlamam. Kaynağımı da ölene kadar korurum. | — |
| Numaramı kimden aldın? | `selin:talked` | Bir gece biri aradı ve numaranızı verdi. Kendini tanıtmadı. / Saat üçtü. Konuşması bir polis gibiydi. Toksikoloji raporunu bana o okudu. | `heard:3am-caller`, `doubt` +1 |

### 0543 112 07 21

| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |
| --- | --- | --- | --- | --- | --- | --- |
| start | `kerem:identified` | Adımı öğrenmişsiniz. / Beni aramayın. Bu hat da birkaç gün sonra olmayacak. / Size yazıyorum çünkü dinleyecek başka kimse kalmadı: kızlardan biri hâlâ hayatta.… | Berat’ı sen mi öldürdün? | Ece’yi o gece oraya o götürdü. / Sizce bu sorunun cevabı bu mu? | `kerem:contact` | terms |
|  |  |  | Kız nerede Kerem? | Yüz yüze söylerim. Sadece size. Yanınızda kimse olmayacak. | `kerem:contact`, `kerem:wants-meeting` | terms |
|  |  |  | Teslim ol. Sana zarar gelmez. | Ece’ye de böyle söylemişlerdi. | `kerem:contact` | terms |
| terms |  | Perşembe gece yarısı. Eski otogarın arkasındaki çay bahçesi. / Siz gelin. Tek başınıza. | Yurt dışındayım. Gelemem. | Öyle mi? / ... / Peki. Güvendiğiniz birini gönderin. Tek kişi, silahsız. | `doubt` +1 | choose |
|  |  |  | Ekibimden birini göndereceğim. | Tek kişi. Silahsız. Başka birini görürsem kızı kimse bulamaz. | — | choose |
| choose |  | Kimi gönderiyorsunuz? | Özge gelecek.<br>_sadece: `trust:Özge >= 40`_ | Perşembe gece yarısı. | `envoy:ozge`, `kerem:meeting-set` | waiting |
|  |  |  | Doğa gelecek.<br>_sadece: `trust:Doğa >= 40`_ | Perşembe gece yarısı. | `envoy:doga`, `kerem:meeting-set` | waiting |
|  |  |  | Atakan gelecek.<br>_sadece: `trust:Atakan >= 40`_ | Perşembe gece yarısı. | `envoy:atakan`, `kerem:meeting-set` | waiting |
|  |  |  | İnanç gelecek.<br>_sadece: `trust:İnanç >= 40`_ | Perşembe gece yarısı. | `envoy:inanc`, `kerem:meeting-set` | waiting |
|  |  |  | Behram gelecek.<br>_sadece: `behram:helps`_ | Narkotikçi mi? ...Peki. Perşembe gece yarısı. | `envoy:behram`, `kerem:meeting-set` | waiting |
|  |  |  | Biri gelecek. (Ekibi topla, buluşma yerini sarın.) | Perşembe gece yarısı. | `envoy:ambush`, `kerem:meeting-set`, `integrity` -5 | waiting |
| afterDeal | kendiliğinden: `kerem:deal` | Savcı onay verirse cuma gecesi oradayım. / Vermezse de oradayım. | Önce kızı çıkaralım, sonra konuşacağız. | Siz bilirsiniz. | — | end |
| afterEscape | kendiliğinden: `kerem:escaped` | Teşekkür ederim. / Adil’i ben bulacağım. Arkamdan gelmeyin. | Kerem, yapma. | Ece için. | `kerem:hunting` | end |
|  |  |  | (Cevap verme) |  | `kerem:hunting` | end |
| afterAmbush | kendiliğinden: `kerem:escaped-ambush` | Size güvenmiştim. / Kızı siz seçtiniz. | Kerem, kız için. Yerini söyle. | ... | `kerem:pleaded` | end |
|  |  |  | Teslim ol. Kaçamazsın. | Ece de kaçamamıştı. | — | end |
| relent | kendiliğinden: `kerem:relents` | Kız için. Sizin için değil. / Sanayideki eski soğuk hava deposu. Arka kapı açık. | Teşekkür ederim. |  | `kerem:told-location` | end |
| thanks | kendiliğinden: `girl:rescued` | Melis’i çıkarmışsınız. / Ece için teşekkür ederim. | — | | | |
| blame | kendiliğinden: `girl:lost` | Geç kaldınız. / Ben de. | — | | | |

**Sorulabilecekler**

| Soru | Ne zaman sorulabilir | Cevap | Sonuç |
| --- | --- | --- | --- |
| Neden şimdi? | her zaman | Çünkü Berat’ın telefonunu açtım. / Keşke açmasaydım. | `heard:kerem-has-phone` |
| Berat’ın telefonu sende mi? | `heard:phone-signal` | Evet. Her şey içinde. Onun da, benim de. | `heard:kerem-has-phone` |
| Ece’yi anlat. | her zaman | Kimyaya bayılırdı. Bursu alınca bütün mahalleye lokum dağıttı. / Altı ay sonra borçlu çıktı. Bir ay sonra öldü. | — |

## Harita görevleri

Subaylar: Atakan ((`status:suspended` yokken ya da `trust:Atakan >= 60`)), Doğa ((`status:suspended` yokken ya da `trust:Doğa >= 60`)), Orhun ((`status:suspended` yokken ya da `trust:Orhun >= 60`)), İnanç ((`status:suspended` yokken ya da `trust:İnanç >= 60`))

| Mekân | Mekân ne zaman görünür | Görev | Görev ne zaman görünür | Süre | Rapor | Sonuç |
| --- | --- | --- | --- | --- | --- | --- |
| Berat'ın Evi | `part1Done` | Olay yerini yeniden ara | her zaman | 2 dk | Amirim ilk ekip bazı yerlere hiç bakmamış. Yatak odasında halının altında dokuz parçaya yırtılmış bir fotoğraf bulduk. Mutfakta da yıkanmam… | `ev:torn-photo`, `ev:glass` |
|  |  | Komşularla konuş | her zaman | 1 dk | Karşı daireden yaşlı bir kadın olay gecesi saat ikiye doğru bağırışlar duymuş. Biri durmadan 'Adil abi, yemin ederim ödeyeceğim' diye yalva… | `heard:adil` |
| Kampüs Kafe | `part1Done` | Kafeciyle konuş | her zaman | 1 dk | Kafeci Furkan'ın o gece kapanışa kadar burada olduğunu doğruladı. Berat 23.40 gibi telefonla konuşup aceleyle çıkmış. Hemen arkasından deri… | `cafe:witness` |
|  |  | Kamera kayıtlarını iste | `cafe:witness` | 3 dk | Kafenin dış kamerasından deri ceketli adamın yüzünün göründüğü tek bir kare çıkardık. Görüntü bulanık ama Poltel'e yükledim. | `ev:cctv` |
| Üniversite | `part1Done` | Berat'ın dolabını aç | her zaman | 2 dk | Dolapta birkaç kitap ve bir defter vardı. Defter sıradan görünüyor ama bazı sayfalar sanki üstüne bir şey yazılıp silinmiş gibi kabarık. La… | `ev:notebook` |
|  |  | Öğrenci işlerinden kayıt iste | her zaman | 1 dk | Berat son iki ayda derslerin hiçbirine girmemiş ama yoklamalarda hep 'var' görünüyor. Danışmanı 'Babası her şeyi hallediyordu, karışmayın d… | — |
| Adli Tıp Kurumu | `part1Done` | Ek toksikoloji tahlili iste | her zaman | 4 dk | Toksikoloji sonuçları geldi amirim, raporu Poltel'e koydum. Çocuğu öldürmeden önce bayıltmışlar. | `toxicology` |
| Sanayi Çay Ocağı | (`heard:adil` ya da `furkanStatement`) | Uzaktan gözetle | her zaman | 3 dk | Adil'i gördük amirim. Akşama doğru siyah bir makam aracı geldi, arka koltuktaki adamla on dakika konuştu. Plakayı aldık: 06 MV 1907. Araç M… | `plate:mv` |
|  |  | Çay ocağını ara | `plate:mv` | 2 dk | Adil kaçmış, tezgahın altındaki sobada bir şeyler yakmış. Ateşten kurtarabildiğimiz tek şey yarısı yanmış bir harita. Parçaları laboratuvar… | `ev:torn-map` |
| Eski Mezbaha | `map-restored` | Ekip gönder | her zaman | 3 dk | Amirim... burası boş değil. Ortada vidalanmış bir sandalye, kesik ip parçaları ve kurumuş kan var. Duvara Berat'ın ve iki öğrencinin daha f… | `mezbaha-found` |
| Yılmaz Eğitim Vakfı | (`heard:volunteer-card` ya da `heard:kerem` ya da `plate:mv`) | Gönüllü kartının fotoğrafını göster | `heard:volunteer-card` | 3 dk | Resepsiyondaki kız kamera karesine bakınca rengi attı. "Kerem. Kerem Aydın. İki aydır gelmiyor." Sonra müdür geldi, bizi kapıya kadar geçir… | `heard:kerem`, `kerem:volunteer`, `pressure` +5 |
|  |  | Gönüllü listesini iste | `heard:kerem` | 3 dk | Liste vermediler, avukat getirdiler. Çıkışta bir sekreter elime kâğıt sıkıştırdı: "Kerem Aydın. Burs arşivine giren tek gönüllü oydu. Sonra… | `kerem:volunteer`, `heard:archive-sealed`, `pressure` +5 |
|  |  | Binayı gözetle | `plate:mv` | 4 dk | Akşam altıda çay ocağındaki makam aracı geldi. Danışman arka kapıdan girdi, bir saat sonra iki karton koliyle çıktı. | `heard:boxes` |
| Aydın Ailesinin Evi | `heard:ece` | Komşularla konuş | her zaman | 2 dk | Annesi geçen yıl ölmüş. Oğlu Kerem aylardır eve uğramıyormuş. "Sakallı, deri ceketli, kızın ölümünden sonra bir daha gülmedi" diyorlar. Pos… | `heard:kerem`, `kerem:volunteer` |
|  |  | Ece’nin odasına bak (izinsiz) | `heard:kerem` | 3 dk | Kapı açıktı amirim. Ece’nin odası olduğu gibi duruyor. Duvarda burslu öğrencilerin fotoğrafları ve aralarına çekilmiş kırmızı ipler var. Bi… | `heard:kerem-board`, `player:dirty-hands`, `integrity` -5 |
| Eski Soğuk Hava Deposu | (`kerem:told-location` ya da `heard:cold-storage`) | Depoya gir | `girl:lost` yokken | 3 dk | Amirim... buldum onu. Melis. Arka odada, bir şiltenin üstünde. Susuz, korkmuş ama yaşıyor. Yanında bir yatak daha vardı. Boş. | `girl:rescued`, `storage:entered` |
|  |  | Depoya gir | `girl:lost` | 3 dk | Geç kaldık amirim. Arka odada, bir şiltenin üstünde. Yanında bir yatak daha vardı. Boş. | `girl:found-dead`, `storage:entered` |

## Laboratuvar

| Delil | Ne zaman bulunur | İnceleme | Sonuç |
| --- | --- | --- | --- |
| Yırtık Fotoğraf | `ev:torn-photo` | Yapboz | `photo-restored` |
| Bardaktaki Parmak İzi | `ev:glass` | Parmak izi (cevap: Adil Karaca) | `print:adil` |
| Kamera Görüntüsü | `ev:cctv` | — | — |
| Berat'ın Defteri | `ev:notebook` | UV lamba | `notebook-read` |
| Yanık Harita | `ev:torn-map` | Yapboz | `map-restored` |
| Olay Yeri | `part1Done` | — | — |
| Makam Aracı | `plate:mv` | — | — |
| Mezbahadaki Sandalye | `mezbaha-found` | — | — |
| Duvardaki Fotoğraflar | `mezbaha-found` | — | — |
| Kayıp İlanı | `mezbaha-found` | — | — |
| Kayıp İlanı | `mezbaha-found` | — | — |
| Ece’nin Burs Sözleşmesi | `heard:kerem-board` | — | — |
| Berat’ın Telefonu | `ev:berat-phone` | — | — |

## Para

| Hareket | Ne zaman gelir | Tutar |
| --- | --- | --- |
| Gelen EFT: Gönderen: Y. Eğitim Vakfı Danışmanlık · Açıklama: 'Geçmiş olsun' | `mp:wrote` | 50000.00 TL |

**Para gönderilebilecekler**

| Alıcı | Ne zaman | En az | Sonuç |
| --- | --- | --- | --- |
| Gönderene iade ('Geçmiş olsun' açıklamalı EFT'nin geldiği hesap) | `mp:wrote` | 50000 TL | `integrity` +10, `pressure` +15, `bribe:returned`; her gönderim `sent:bribe-return` ve `paid:bribe-return` |
| Orhun K. (Orhun’un icra borcu (80.000 TL)) | `heard:orhun-debt` | 20000 TL | `orhun:helped`, `trust:Orhun` +20, `integrity` -5; her gönderim `sent:orhun-debt` ve `paid:orhun-debt` |

## Süreli olaylar

Süre sadece oyun açıkken işler; Settings › Hızlı görevler 30 kat hızlandırır.

| Olay | Başlar | Süre | İptal olur | Sonuç |
| --- | --- | --- | --- | --- |
| kaymakam-calls | `pressure:erdi` ve (`cafe:witness` ya da `notebook-read` ya da `print:adil` ya da `plate:mv` ya da `ev:cctv`) | 4 dk | — | `kaymakam:calls` |
| mp-writes | `pressure:kaymakam` ve (`plate:mv` ya da `notebook-read`) | 3 dk | — | `mp:wrote` |
| bribe-kept | `mp:wrote` | 45 dk | `sent:bribe-return` | `integrity` -15, `pressure` +10, `case:internal-investigation` |
| adil-warns | `furkanStatement` | 6 dk | — | `adil:warns` |
| card-enhance | `kerem:same-man` | 8 dk | — | `card:enhanced` |
| meeting | `kerem:meeting-set` | 10 dk | — | `kerem:met` |
| friday | `kerem:contact` | 60 dk | `girl:rescued` | `girl:lost` |
| kerem-relents | `kerem:escaped-ambush` | 15 dk | `girl:rescued` | `kerem:relents` |

## Kilitler

| Uygulama | Kilitlenir | Mesaj |
| --- | --- | --- |
| Poltel | (`status:suspended` ya da `status:dismissed`) | Hakkınızda yürütülen idari soruşturma nedeniyle erişim yetkiniz geçici olarak askıya alınmıştır. |

## Final

Oyun `final:ready` olunca biter. Her bölümde koşulu tutan **ilk** satır anlatılır.

| Bölüm | Sonuç | Koşul |
| --- | --- | --- |
| Berat Yılmaz Dosyası | **Yanlış İnsan** [Taslak] Deliller yanlış yorumlandı; suçlanan kişi gerçek fail değildi. | `case:wrong-person` |
|  | **Adaletin Bedeli** [Taslak] Cinayet çözüldü, siyasi bağlantılar ortaya çıktı. Bedelini ekip ödedi. | `case:solved` ve `coverup:exposed` |
|  | **Kirli Eller** [Taslak] Masumlar hayatta, ama komiser artık kendisi de soruşturulabilir. | `case:solved` ve `player:dirty-hands` |
|  | **Sessiz Zafer** [Taslak] Katil yakalandı, dosya kapandı. Emri verenler dokunulmaz kaldı. | `case:solved` |
|  | **Çözülemeyen Dosya** [Taslak] Dosya faili meçhul olarak kapandı. | her zaman |
| Kerem Aydın | [Taslak] Kerem Aydın tutuklandı. Duruşmada tek kelime etmedi; sadece kız kardeşinin adını söyledi. | `kerem:arrested` |
|  | [Taslak] Kerem Aydın savcılıkla iş birliği yaptı. Verdiği ifade vakfın kapısını açtı. | `kerem:deal` |
|  | [Taslak] Kerem Aydın bir daha görülmedi. Bazıları onu cuma geceleri sanayide gördüklerini söylüyor. | (`kerem:escaped` ya da `kerem:escaped-ambush`) |
|  | [Taslak] Kerem Aydın hâlâ aranıyor. | her zaman |
| Komiser | [Taslak] Hakkında yakalama kararı çıkarıldı. | `legal:warrant-issued` |
|  | [Taslak] Meslekten çıkarıldı. | `status:dismissed` |
|  | [Taslak] Görevden uzaklaştırıldı. | `status:suspended` |
|  | [Taslak] Görevde kaldı ama artık kimse ona eskisi gibi bakmıyor. | `integrity < 40` |
|  | [Taslak] Dosya kapandığında bile bir şey yerine oturmadı: kimse tatilde olduğunuzu doğrulayamadı. | `doubt >= 3` |
|  | [Taslak] Görevine devam ediyor. | her zaman |
| Tanıklar | [Taslak] Melis kurtarıldı ve ifade verdi. Emre’den hâlâ haber yok. | `girl:rescued` |
|  | [Taslak] Melis’e yetişemediniz. Ailesi her cuma deponun önüne çiçek bırakıyor. | `girl:found-dead` |
|  | [Taslak] Kritik tanık korunarak ifade verdi. | `witness:protected` |
|  | [Taslak] Tanıklardan biri ortadan kayboldu. | `witnessDanger >= 60` |
|  | [Taslak] Tanıklar ifadelerini değiştirmedi. | her zaman |
| Özge | [Taslak] Özge komisere hâlâ güveniyor. | `trust:Özge >= 70` |
|  | [Taslak] Özge ekipten ayrılmayı düşünüyor. | `trust:Özge <= 30` |
|  | [Taslak] Özge için hikâye henüz yazılmadı. | her zaman |
| Atakan | [Taslak] Atakan komisere hâlâ güveniyor. | `trust:Atakan >= 70` |
|  | [Taslak] Atakan ekipten ayrılmayı düşünüyor. | `trust:Atakan <= 30` |
|  | [Taslak] Atakan için hikâye henüz yazılmadı. | her zaman |
| Orhun | [Taslak] Orhun komisere hâlâ güveniyor. | `trust:Orhun >= 70` |
|  | [Taslak] Orhun ekipten ayrılmayı düşünüyor. | `trust:Orhun <= 30` |
|  | [Taslak] Orhun için hikâye henüz yazılmadı. | her zaman |
| Doğa | [Taslak] Doğa komisere hâlâ güveniyor. | `trust:Doğa >= 70` |
|  | [Taslak] Doğa ekipten ayrılmayı düşünüyor. | `trust:Doğa <= 30` |
|  | [Taslak] Doğa için hikâye henüz yazılmadı. | her zaman |
| İnanç | [Taslak] İnanç komisere hâlâ güveniyor. | `trust:İnanç >= 70` |
|  | [Taslak] İnanç ekipten ayrılmayı düşünüyor. | `trust:İnanç <= 30` |
|  | [Taslak] İnanç için hikâye henüz yazılmadı. | her zaman |
| Behram | [Taslak] Behram komisere hâlâ güveniyor. | `trust:Behram >= 70` |
|  | [Taslak] Behram ekipten ayrılmayı düşünüyor. | `trust:Behram <= 30` |
|  | [Taslak] Behram için hikâye henüz yazılmadı. | her zaman |
| Ankara | [Taslak] Üstlerden gelen baskı dosyanın her aşamasında hissedildi. | `pressure >= 70` |
|  | [Taslak] Ankara bu dosyayı unutmayı tercih etti. | her zaman |

## Bayraklar

Bir yolu açmak için: o bayrağın "Nasıl açılır" sütunundaki yollardan **biri** yeterli.

| Bayrak | Anlamı | Nasıl açılır | Neyi açar |
| --- | --- | --- | --- |
| `adil:warns` | Büroya "Çocuk bir şey bilmez" telefonu geldi | Süreli olay › adil-warns: `furkanStatement` olduktan 6 dk sonra | Doğa › furkanFate |
| `atakan:card` |  | Atakan › "Vakfa git, gönüllüleri sor."<br>Atakan › "Kimseye söyleme. Vakfın kulağına gitmes…" | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar) |
| `atakan:match` |  | Atakan › "Aramaya başlayın. Ama sessizce."<br>Atakan › "Bütün birimlere bildir. Yakalama kararı…" | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar) |
| `atakan:mezbaha` |  | Atakan › "Nerede gördün?"<br>Atakan › "Hatırlayınca söyle." | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar) |
| `behram:depot` |  | Behram › "Listeyi bana gönder."<br>Behram › "Listedeki diğer isimler kim?" | Behram › afterRaid (kendiliğinden yazar) |
| `behram:guilt` | Behram narkotiğin cuma gecelerine göz yumduğunu itiraf etti | Behram › soru "Cuma gecelerini biliyor muydunuz?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `behram:helps` | Behram Adil’i aramaya yardım ediyor | Behram › "Adil’in saklanacağı yeri sen bilirsin. …" | Behram › afterRaid (kendiliğinden yazar)<br>Behram › soru "Narkotiğin Adil’le bir anlaşması var mı…"<br>0543 112 07 21 › "Behram gelecek." |
| `behram:list` |  | Behram › "Listeyi bana gönder."<br>Behram › "Listedeki diğer isimler kim?" | Behram › soru "Adil’in listesiyle Furkan’ın "cuma gece…" |
| `bribe:returned` | Para gönderene iade edildi | ZaferBank › Gönderene iade hesabına para gönder | Erdi › desk (kendiliğinden yazar)<br>Kaymakam › refused (kendiliğinden yazar)<br>0532 190 19 07 › after (kendiliğinden yazar)<br>Messages › Gizli Numara<br>Kayıtlar › Bilinmeyen Numara (unknown-1) gelir |
| `cafe:witness` | Kafeci olay gecesini anlattı | Harita › Kampüs Kafe › Kafeciyle konuş | Harita › Kampüs Kafe › Kamera kayıtlarını iste görünür<br>Süreli olay › kaymakam-calls başlar |
| `card:enhanced` | Karttaki vakıf logosu netleşti (süreli olay) | Süreli olay › card-enhance: `kerem:same-man` olduktan 8 dk sonra | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar) |
| `case:internal-investigation` | Komiser hakkında idari inceleme başladı | Süreli olay › bribe-kept: `mp:wrote` olduktan 45 dk sonra, `sent:bribe-return` olmadıysa | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar)<br>Erdi › desk (kendiliğinden yazar)<br>Erdi › soru "Müdürüm, iç denetim neden benim hesabım…"<br>Mail › icdenetim.emniyet.gov.tr |
| `case:solved` | Berat cinayetinin faili doğru tespit edildi | Özge › "Gözaltına al."<br>Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gözaltına al."<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gözaltına al."<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Gözaltına al."<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Gitsin. Kızın yerini al."<br>Doğa › "Gözaltına al."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Gitsin. Kızın yerini al." | 0532 190 19 07 › after (kendiliğinden yazar)<br>Final › Berat Yılmaz Dosyası › Adaletin Bedeli<br>Final › Berat Yılmaz Dosyası › Kirli Eller<br>Final › Berat Yılmaz Dosyası › Sessiz Zafer |
| `case:wrong-person` | Yanlış kişi suçlandı | _henüz hiçbir şey_ | Final › Berat Yılmaz Dosyası › Yanlış İnsan |
| `coverup:exposed` | Örtbas edilen suçlar ortaya çıktı | _henüz hiçbir şey_ | Final › Berat Yılmaz Dosyası › Adaletin Bedeli |
| `deniz:told` |  | Özge › "Söyleyin. Bilmeye hakkı var." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `doga:furkan-news` |  | Doğa › "Bütün ekipleri seferber et. Bulun onu."<br>Doğa › "Adil’in adamlarının elinde olabilir. Be…"<br>Doğa › "İfadesine ekle."<br>Doğa › "Bunu kimse bilmesin. Önce onu korumamız…" | Doğa › afterFurkan (kendiliğinden yazar) |
| `doga:melis` |  | Doğa › "Ona koruma ver. Kimse yanına yaklaşması…"<br>Doğa › "İfadesini tutanağa geçir, hemen." | Doğa › afterFurkan (kendiliğinden yazar) |
| `envoy:ambush` | Buluşmaya gönderilen: ambush | 0543 112 07 21 › "Biri gelecek. (Ekibi topla, buluşma yer…" | İnanç › order (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar) |
| `envoy:atakan` | Buluşmaya gönderilen: atakan | 0543 112 07 21 › "Atakan gelecek." | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar) |
| `envoy:behram` | Buluşmaya gönderilen: behram | 0543 112 07 21 › "Behram gelecek." | Behram › raid (kendiliğinden yazar)<br>Behram › afterRaid (kendiliğinden yazar) |
| `envoy:doga` | Buluşmaya gönderilen: doga | 0543 112 07 21 › "Doğa gelecek." | Doğa › furkanFate (kendiliğinden yazar)<br>Doğa › afterFurkan (kendiliğinden yazar) |
| `envoy:inanc` | Buluşmaya gönderilen: inanc | 0543 112 07 21 › "İnanç gelecek." | İnanç › order (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar) |
| `envoy:ozge` | Buluşmaya gönderilen: ozge | 0543 112 07 21 › "Özge gelecek." | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar) |
| `envoy:reported` |  | Özge › "Gözaltına al."<br>Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gözaltına al."<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gözaltına al."<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Gözaltına al."<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Gitsin. Kızın yerini al."<br>İnanç › "Bütün çıkışları kapatın."<br>İnanç › "Peşini bırakın. Telefon yeter."<br>Doğa › "Gözaltına al."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Gitsin. Kızın yerini al." | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar)<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Behram › raid (kendiliğinden yazar)<br>Behram › afterRaid (kendiliğinden yazar)<br>İnanç › order (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar)<br>Doğa › furkanFate (kendiliğinden yazar)<br>Doğa › afterFurkan (kendiliğinden yazar) |
| `erdi-kept-out` |  | Özge › "Bundan Erdi'ye tek kelime etmeyeceksin." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `erdi:arrest` |  | Erdi › "Kapatamayız. Kızlar hâlâ kayıp."<br>Erdi › "Anlaşıldı." | Erdi › desk (kendiliğinden yazar) |
| `erdi:audit` |  | Erdi › "Hediye gibi gönderilmiş. İade edecektim."<br>Erdi › "Size söyleyecek bir şeyim yok."<br>Erdi › "Parayı kimin gönderdiğini siz de biliyo…" | Erdi › desk (kendiliğinden yazar) |
| `erdi:escape` |  | Erdi › "Bir hayat kurtarmak için gerekiyordu."<br>Erdi › "(Cevap verme)" | Erdi › desk (kendiliğinden yazar) |
| `erdi:rescue` |  | Erdi › "Siz bilirsiniz müdürüm."<br>Erdi › "Bu ekibin başarısı, sizin değil." | Erdi › desk (kendiliğinden yazar) |
| `ev:berat-phone` | Berat’ın telefonu ele geçti | Özge › "Gözaltına al."<br>Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gözaltına al."<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gözaltına al."<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Gözaltına al."<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Gitsin. Kızın yerini al."<br>İnanç › "Bütün çıkışları kapatın."<br>İnanç › "Peşini bırakın. Telefon yeter."<br>Doğa › "Gözaltına al."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Gitsin. Kızın yerini al." | Pano › Berat’ın Telefonu bulunur |
| `ev:cctv` | Kafe kamerasından kare alındı | Harita › Kampüs Kafe › Kamera kayıtlarını iste | Atakan › idle<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Atakan › soru "Yırtık fotoğraftaki adamla kameradaki a…"<br>Pano › Kamera Görüntüsü bulunur<br>Süreli olay › kaymakam-calls başlar |
| `ev:glass` | Evde parmak izli bardak bulundu | Harita › Berat'ın Evi › Olay yerini yeniden ara | Pano › Bardaktaki Parmak İzi bulunur |
| `ev:notebook` | Berat’ın defteri bulundu | Harita › Üniversite › Berat'ın dolabını aç | Pano › Berat'ın Defteri bulunur |
| `ev:torn-map` | Çay ocağında yanık harita bulundu | Harita › Sanayi Çay Ocağı › Çay ocağını ara | Behram › raid<br>Behram › soru "Adil şimdi nerede olabilir?"<br>Pano › Yanık Harita bulunur |
| `ev:torn-photo` | Evde yırtık fotoğraf bulundu | Harita › Berat'ın Evi › Olay yerini yeniden ara | Pano › Yırtık Fotoğraf bulunur |
| `final:ready` | Final soruşturması bitti, oyun sona erer | _henüz hiçbir şey_ | Final başlar |
| `furkan:friday` | Furkan "cuma geceleri" anlattı | Doğa › "İfadesine ekle."<br>Doğa › "Bunu kimse bilmesin. Önce onu korumamız…" | Behram › soru "Adil’in listesiyle Furkan’ın "cuma gece…" |
| `furkan:held` | Furkan gözaltında tutuldu | Doğa › "Savcıdan süre uzatması isteyin. İçeride…" | Doğa › afterFurkan (kendiliğinden yazar)<br>Doğa › soru "Furkan nasıl?"<br>Doğa › soru "Furkan’a Kerem Aydın’ı sor." |
| `furkan:missing` | Serbest bırakılan Furkan kayboldu | Doğa › "Bütün ekipleri seferber et. Bulun onu."<br>Doğa › "Adil’in adamlarının elinde olabilir. Be…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `furkan:protected` | Furkan için tanık koruma istendi | Doğa › "Tanık koruma için başvurun." | Doğa › afterFurkan (kendiliğinden yazar)<br>Doğa › soru "Furkan nasıl?"<br>Doğa › soru "Furkan’a Kerem Aydın’ı sor." |
| `furkan:released` | Furkan serbest bırakıldı | Doğa › "Serbest bırakın ama gözünüzü ayırmayın." | Doğa › afterFurkan (kendiliğinden yazar)<br>Doğa › soru "Furkan nasıl?" |
| `furkanStatement` | Furkan’ın ifadesi tutanağa geçti | Doğa › "Adil'i nerede bulabiliriz?"<br>Doğa › "Bu kadar yeter. Doğa, ifadeyi tutanağa …" | Özge › soru "Furkan’ın ifadesini okudun mu?"<br>Orhun › soru "Furkan’ın ailesi aradı mı?"<br>Behram › start<br>Behram › soru "Adil kimin için çalışıyor?"<br>Doğa › soru "Sence Furkan doğruyu söyledi mi?"<br>Doğa › soru "Sen nasılsın? Sorgu ağır geçti."<br>Doğa › soru "Furkan’ın ailesiyle sen mi konuşuyorsun?"<br>Erdi › pressure<br>Harita › Sanayi Çay Ocağı görünür<br>Süreli olay › adil-warns başlar<br>Poltel › Furkan Şahin - İfade Tutanağı gelir<br>Mail › narkotik.emniyet.gov.tr<br>Sinstagram › @adil.abi aranabilir |
| `girl:found-dead` | Melis ölü bulundu | Harita › Eski Soğuk Hava Deposu › Depoya gir | News › "Sanayideki depoda kayıp öğrencinin cansız bedeni …" çıkar<br>Final › Tanıklar |
| `girl:lost` | Cuma geçti, Melis’e yetişilemedi (süreli olay) | Süreli olay › friday: `kerem:contact` olduktan 60 dk sonra, `girl:rescued` olmadıysa | 0543 112 07 21 › end (kendiliğinden yazar)<br>Harita › Eski Soğuk Hava Deposu › Depoya gir görünür |
| `girl:rescued` | Melis kurtarıldı | Harita › Eski Soğuk Hava Deposu › Depoya gir | Doğa › afterFurkan (kendiliğinden yazar)<br>Erdi › desk (kendiliğinden yazar)<br>0543 112 07 21 › end (kendiliğinden yazar)<br>Süreli olay › friday iptal olur<br>Süreli olay › kerem-relents iptal olur<br>News › "Kayıp öğrenci sanayideki depoda sağ bulundu" çıkar<br>Final › Tanıklar |
| `heard:3am-caller` | Selin’e numarayı gece üçte arayan biri vermiş | Selin Aras › soru "Numaramı kimden aldın?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:adil` | Komşu "Adil abi" yalvarışını duymuş | Harita › Berat'ın Evi › Komşularla konuş | Erdi › pressure<br>Harita › Sanayi Çay Ocağı görünür<br>Sinstagram › @adil.abi aranabilir |
| `heard:adil-informant` |  | Behram › soru "Narkotiğin Adil’le bir anlaşması var mı…" | Behram › soru "Cuma gecelerini biliyor muydunuz?" |
| `heard:adil-missing-case` |  | Behram › soru "Adil’in sabıka kaydını yollar mısın?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:archive-sealed` |  | Harita › Yılmaz Eğitim Vakfı › Gönüllü listesini iste | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:atakan-photo` |  | Atakan › "Nerede gördün?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:atakan-secret` |  | Atakan › soru "İzin günün nasıl geçti?" | Atakan › soru "Sen iyi misin? Sesin farklı geliyor." |
| `heard:berat-past` |  | 0532 190 19 07 › "Oğlunuzun hangi hataları?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:berat-repentant` | Berat’ın pişman olduğu ve kanıtları Kerem’e vereceği öğrenildi | Özge › "Gözaltına al."<br>Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gözaltına al."<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gözaltına al."<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Gözaltına al."<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Gitsin. Kızın yerini al."<br>İnanç › "Bütün çıkışları kapatın."<br>İnanç › "Peşini bırakın. Telefon yeter."<br>Doğa › "Gözaltına al."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Gitsin. Kızın yerini al." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:boxes` |  | Harita › Yılmaz Eğitim Vakfı › Binayı gözetle | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:camera-broken` |  | İnanç › "Arızayı kimin bildirdiğini öğren." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:cold-storage` | Soğuk hava deposu başka yoldan bulundu | Orhun › soru "Kerem’in üstünden ne çıktı?"<br>Behram › soru "Adil’in listesiyle Furkan’ın "cuma gece…" | Harita › Eski Soğuk Hava Deposu görünür |
| `heard:dead-line` |  | Özge › soru "Bana gelen sesli mesajın numarasını sor…" | Özge › soru "O ölmüş kadının hattı kimin adına?" |
| `heard:ece` | Ece Aydın’ın adı öğrenildi | Özge › soru "O ölmüş kadının hattı kimin adına?"<br>Özge › soru "Arşivdeki takipsizlik haberindeki kızın…" | Özge › soru "Ece Aydın’ın ailesinden kim kaldı?"<br>Harita › Aydın Ailesinin Evi görünür<br>Sinstagram › @ece.aydin aranabilir<br>Sinstagram › @k.aydin aranabilir |
| `heard:erdi-knows-money` |  | Erdi › "Parayı kimin gönderdiğini siz de biliyo…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:erdi-ordered` |  | Erdi › "Size kim emir veriyor müdürüm?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:fake-police` |  | Atakan › "Kafenin diğer kameralarını da iste." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:initials` |  | Behram › "Listedeki diğer isimler kim?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:kaymakam-knew` |  | Kaymakam › "Kimden duydunuz?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:kaymakam-rival` | Kaymakamın Yılmaz’ın koltuğuna aday olacağı öğrenildi | Selin Aras › soru "Kaymakamı araştırıyor musun?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:kerem` | Kerem Aydın’ın adı öğrenildi | Harita › Yılmaz Eğitim Vakfı › Gönüllü kartının fotoğrafını göster<br>Harita › Aydın Ailesinin Evi › Komşularla konuş<br>Sinstagram › @k.aydin açılınca | Orhun › soru "Kerem Aydın diye birini tanıyor musun?"<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Doğa › soru "Furkan’a Kerem Aydın’ı sor."<br>Harita › Yılmaz Eğitim Vakfı görünür<br>Harita › Yılmaz Eğitim Vakfı › Gönüllü listesini iste görünür<br>Harita › Aydın Ailesinin Evi › Ece’nin odasına bak (izinsiz) görünür |
| `heard:kerem-berat` |  | Özge › soru "Kerem’in Berat’la bir bağı var mı?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:kerem-board` |  | Harita › Aydın Ailesinin Evi › Ece’nin odasına bak (izinsiz) | Pano › Ece’nin Burs Sözleşmesi bulunur |
| `heard:kerem-has-phone` |  | 0543 112 07 21 › soru "Neden şimdi?"<br>0543 112 07 21 › soru "Berat’ın telefonu sende mi?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:mp-ece` |  | 0532 190 19 07 › "Kerem Aydın. Ece Aydın’ın ağabeyi." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:mp-knows-mezbaha` |  | 0532 190 19 07 › "Neden bu kadar eminsiniz?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:mp-refused-money` |  | 0532 190 19 07 › soru "Berat’la en son ne zaman konuştunuz?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:notebook` |  | Özge › soru "Deniz nasıl?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:old-case` |  | Selin Aras › "Hangi dosya?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:orhun-debt` | Orhun’un 80.000 TL icra borcu öğrenildi | Orhun › "Borcun ne kadar?" | Orhun › soru "Annen nasıl?"<br>ZaferBank › Orhun K. hesabına para gönder (görünür) |
| `heard:orhun-secret` |  | Orhun › soru "Akşama iki bira dedin, ne oldu o iş?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:orhun-visitor` |  | Orhun › "Doğru yapmışsın. Adamı tarif et." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:phone-signal` |  | Özge › soru "Berat’ın telefonu bulundu mu?" | 0543 112 07 21 › soru "Berat’ın telefonu sende mi?" |
| `heard:records-odd` |  | İnanç › soru "Telefon kayıtlarına baktılar mı?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:source-outside` |  | Selin Aras › "Kaynağın kim?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `heard:volunteer-card` | Kameradaki kartın vakıf gönüllü kartı olduğu anlaşıldı | Atakan › "Vakfa git, gönüllüleri sor."<br>Atakan › "Kimseye söyleme. Vakfın kulağına gitmes…" | Harita › Yılmaz Eğitim Vakfı görünür<br>Harita › Yılmaz Eğitim Vakfı › Gönüllü kartının fotoğrafını göster görünür |
| `heard:witness` | Korkmuş tanığın sesli mesajı dinlendi | Kayıtlar › Bilinmeyen Numara (unknown-2) dinlenince | Özge › soru "Bana gelen sesli mesajın numarasını sor…" |
| `inanc:camera` |  | İnanç › "Arızayı kimin bildirdiğini öğren."<br>İnanç › "Tamam. Başka kamera var mı, ona bak." | İnanç › afterOrder (kendiliğinden yazar) |
| `inanc:records` |  | İnanç › "Ver. Saklayacak bir şeyimiz yok."<br>İnanç › "Verme. Savcı onayı olmadan kimse kimsen…"<br>İnanç › "Benimkini verme. Diğerlerini ver." | İnanç › afterOrder (kendiliğinden yazar) |
| `inanc:records-given` |  | İnanç › "Ver. Saklayacak bir şeyimiz yok." | İnanç › soru "Telefon kayıtlarına baktılar mı?" |
| `inancDone` | İnanç sorguyu ayarladı; Doğa sorgu odasında | İnanç › "Şimdi bürodaki kızlardan birini yanına …"<br>İnanç › "Hayır gelmeme daha var. Buradan soracağ…" | Doğa › start |
| `kaymakam:calls` | Kaymakam yazmaya karar verdi (süreli olay) | Süreli olay › kaymakam-calls: `pressure:erdi` ve (`cafe:witness` ya da `notebook-read` ya da `print:adil` ya da `plate:mv` ya da `ev:cctv`) olduktan 4 dk sonra | Kaymakam › start |
| `kaymakam:informed` | Komiser kaymakama bilgi vermeyi kabul etti | Kaymakam › "Tabii Kaymakam Bey, gelişmeleri size bi…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `kaymakam:plate` |  | Kaymakam › "Kimden duydunuz?"<br>Kaymakam › "Açıklanacak bir şey yok. Soruşturma sür…" | Kaymakam › informed (kendiliğinden yazar) |
| `kaymakam:returned` |  | Kaymakam › "Dostluğun banka hesabından gelmesine al…"<br>Kaymakam › "(Cevap verme)" | Kaymakam › refused (kendiliğinden yazar) |
| `kerem:arrested` | Kerem gözaltına alındı | Özge › "Gözaltına al."<br>Atakan › "Gözaltına al."<br>Behram › "Gözaltına al."<br>İnanç › "Gözaltına al."<br>Doğa › "Gözaltına al." | Orhun › soru "Kerem’in üstünden ne çıktı?"<br>Doğa › soru "Kerem sorguda konuşuyor mu?"<br>Erdi › desk (kendiliğinden yazar)<br>News › "Berat Yılmaz cinayetinde gözaltı" çıkar<br>Final › Kerem Aydın |
| `kerem:contact` | Kerem komisere yazdı | 0543 112 07 21 › "Berat’ı sen mi öldürdün?"<br>0543 112 07 21 › "Kız nerede Kerem?"<br>0543 112 07 21 › "Teslim ol. Sana zarar gelmez." | Süreli olay › friday başlar |
| `kerem:deal` | Kerem’e savcılık koruması ve indirim sözü verildi | Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…" | 0543 112 07 21 › waiting (kendiliğinden yazar)<br>Final › Kerem Aydın |
| `kerem:escaped` | Kerem’in gitmesine göz yumuldu | Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Gitsin. Kızın yerini al."<br>Doğa › "Gitsin. Kızın yerini al." | Erdi › desk (kendiliğinden yazar)<br>0543 112 07 21 › waiting (kendiliğinden yazar)<br>Final › Kerem Aydın |
| `kerem:escaped-ambush` | Pusu bozuldu, Kerem kaçtı | İnanç › "Bütün çıkışları kapatın."<br>İnanç › "Peşini bırakın. Telefon yeter." | Erdi › desk (kendiliğinden yazar)<br>0543 112 07 21 › waiting (kendiliğinden yazar)<br>Süreli olay › kerem-relents başlar<br>Final › Kerem Aydın |
| `kerem:hunting` | Kerem Adil’in peşine düştü (Bölüm V) | 0543 112 07 21 › "Kerem, yapma."<br>0543 112 07 21 › "(Cevap verme)" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `kerem:identified` | Berat’ın peşinden çıkan adamın Kerem olduğu anlaşıldı | Atakan › "Aramaya başlayın. Ama sessizce."<br>Atakan › "Bütün birimlere bildir. Yakalama kararı…" | Özge › soru "Kerem’in Berat’la bir bağı var mı?"<br>0543 112 07 21 › start |
| `kerem:meeting-set` | Kerem’le buluşma ayarlandı | 0543 112 07 21 › "Özge gelecek."<br>0543 112 07 21 › "Doğa gelecek."<br>0543 112 07 21 › "Atakan gelecek."<br>0543 112 07 21 › "İnanç gelecek."<br>0543 112 07 21 › "Behram gelecek."<br>0543 112 07 21 › "Biri gelecek. (Ekibi topla, buluşma yer…" | Süreli olay › meeting başlar |
| `kerem:met` | Buluşma gerçekleşti (süreli olay) | Süreli olay › meeting: `kerem:meeting-set` olduktan 10 dk sonra | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar)<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Behram › raid (kendiliğinden yazar)<br>Behram › afterRaid (kendiliğinden yazar)<br>İnanç › order (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar)<br>Doğa › furkanFate (kendiliğinden yazar)<br>Doğa › afterFurkan (kendiliğinden yazar)<br>Erdi › desk (kendiliğinden yazar) |
| `kerem:pleaded` |  | 0543 112 07 21 › "Kerem, kız için. Yerini söyle." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `kerem:relents` | Kerem pusudan sonra yine de yeri söylemeye karar verdi (süreli olay) | Süreli olay › kerem-relents: `kerem:escaped-ambush` olduktan 15 dk sonra, `girl:rescued` olmadıysa | 0543 112 07 21 › end (kendiliğinden yazar) |
| `kerem:same-man` | Yırtık fotoğraftaki ve kameradaki adam aynı kişi | Atakan › soru "Yırtık fotoğraftaki adamla kameradaki a…" | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Süreli olay › card-enhance başlar |
| `kerem:told-location` | Kerem Melis’in yerini söyledi | Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Gitsin. Kızın yerini al."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Gitsin. Kızın yerini al."<br>0543 112 07 21 › "Teşekkür ederim." | Harita › Eski Soğuk Hava Deposu görünür |
| `kerem:volunteer` | Kerem’in vakıfta gönüllü olduğu öğrenildi | Harita › Yılmaz Eğitim Vakfı › Gönüllü kartının fotoğrafını göster<br>Harita › Yılmaz Eğitim Vakfı › Gönüllü listesini iste<br>Harita › Aydın Ailesinin Evi › Komşularla konuş | Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar) |
| `kerem:wanted` |  | Atakan › "Bütün birimlere bildir. Yakalama kararı…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `kerem:wants-meeting` |  | 0543 112 07 21 › "Kız nerede Kerem?" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `leak:defended` | Komiser ekibini savundu | Erdi › "Benim ekibimden kimse gazeteciyle konuş…" | Özge › soru "Basına kim sızdırıyor sence?"<br>Erdi › soru "Sızıntıyı araştıran var mı?"<br>Selin Aras › start |
| `leak:hunt` | Komiser sızıntıyı ekip içinde arıyor | Erdi › "Ekibi tek tek konuşturacağım."<br>Erdi › "Orhun sorguladı ama sızdıran o değil."<br>Erdi › "Sızıntıyı ben de araştırıyorum. Bizden …" | Özge › soru "Basına kim sızdırıyor sence?"<br>Atakan › soru "Gazeteyle konuştun mu?"<br>İnanç › afterOrder (kendiliğinden yazar)<br>Erdi › soru "Sızıntıyı araştıran var mı?"<br>Selin Aras › start |
| `leak:sources` | Komiser raporun başka kurumlarda da olduğunu söyledi | Erdi › "Rapor sadece bizde değil müdürüm. Adli …" | Özge › soru "Basına kim sızdırıyor sence?"<br>Erdi › soru "Sızıntıyı araştıran var mı?"<br>Selin Aras › start |
| `leak:who-benefits` |  | Erdi › "Plakanın gazetede olması kimin işine ya…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `legal:warrant-issued` | Komiser hakkında yakalama kararı var | _henüz hiçbir şey_ | Final › Komiser |
| `map-restored` | Yanık harita birleştirildi; mezbaha haritada | Laboratuvar › Yanık Harita | Harita › Eski Mezbaha görünür |
| `melis:statement` | Melis’in ifadesi alındı | Doğa › "Ona koruma ver. Kimse yanına yaklaşması…"<br>Doğa › "İfadesini tutanağa geçir, hemen." | Poltel › Melis Doğan - İfade Tutanağı gelir |
| `mezbaha-found` | Eski mezbaha arandı | Harita › Eski Mezbaha › Ekip gönder | Özge › afterMezbaha<br>Özge › soru "Mezbahadaki tarihler ne anlama geliyor?"<br>Özge › soru "Kayıp öğrencilerin aileleriyle konuştun…"<br>Özge › soru "Ekip nasıl, dayanıyor mu?"<br>Orhun › afterPlate (kendiliğinden yazar)<br>Atakan › idle (kendiliğinden yazar)<br>Atakan › afterCctv (kendiliğinden yazar)<br>Atakan › soru "Yusuf’tan haber var mı?"<br>Behram › afterRaid (kendiliğinden yazar)<br>İnanç › afterOrder (kendiliğinden yazar)<br>Doğa › afterFurkan (kendiliğinden yazar)<br>Erdi › desk (kendiliğinden yazar)<br>0532 190 19 07 › after (kendiliğinden yazar)<br>Selin Aras › desk (kendiliğinden yazar)<br>Pano › Mezbahadaki Sandalye bulunur<br>Pano › Duvardaki Fotoğraflar bulunur<br>Pano › Kayıp İlanı bulunur<br>Kayıtlar › Bilinmeyen Numara (unknown-2) gelir<br>News › "Sanayideki eski mezbahada gece boyu süren çalışma" çıkar<br>News › "Sanayi sakinleri tedirgin: "Geceleri o binada ışı…" çıkar |
| `mp:killer` |  | 0532 190 19 07 › "Kerem Aydın. Ece Aydın’ın ağabeyi."<br>0532 190 19 07 › "Söyleyemem." | 0532 190 19 07 › after (kendiliğinden yazar) |
| `mp:mezbaha` |  | 0532 190 19 07 › "Oğlunuzun fotoğrafı duvardaydı Yılmaz B…"<br>0532 190 19 07 › "Neden bu kadar eminsiniz?" | 0532 190 19 07 › after (kendiliğinden yazar) |
| `mp:returned-seen` |  | 0532 190 19 07 › "Evet. Gönderdim." | 0532 190 19 07 › after (kendiliğinden yazar) |
| `mp:silent` |  | 0532 190 19 07 › "Oğlunuzun fotoğrafı duvardaydı Yılmaz B…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `mp:wrote` | Milletvekili baba gizli numaradan yazdı, para yattı | Süreli olay › mp-writes: `pressure:kaymakam` ve (`plate:mv` ya da `notebook-read`) olduktan 3 dk sonra | Özge › soru "Hesabıma para yattı, kimseye söyleme."<br>Orhun › afterStatement (kendiliğinden yazar)<br>Orhun › afterPlate (kendiliğinden yazar)<br>0532 190 19 07 › start<br>ZaferBank › Gelen EFT gelir<br>ZaferBank › Gönderene iade hesabına para gönder (görünür)<br>Süreli olay › bribe-kept başlar |
| `news:old-case-found` |  | News › "Üniversiteli genç kadının ölümüyle ilgili soruştu…" okununca | Özge › soru "Arşivdeki takipsizlik haberindeki kızın…" |
| `notebook-read` | Defterdeki gizli yazı okundu | Laboratuvar › Berat'ın Defteri | Süreli olay › kaymakam-calls başlar<br>Süreli olay › mp-writes başlar |
| `orhun:approached` | Orhun’a borcu üzerinden yaklaşıldığını anlattı | Orhun › "Doğru yapmışsın. Adamı tarif et."<br>Orhun › "Bunu iç denetime bildirmem gerekiyor."<br>Orhun › "Borcun ne kadar?" | Orhun › afterStatement (kendiliğinden yazar)<br>Orhun › afterPlate (kendiliğinden yazar) |
| `orhun:blood` |  | Orhun › "Son üç yılın bütün kayıp ilanlarını tar…"<br>Orhun › "Bu bilgiyi şimdilik raporlara yazma." | Orhun › afterPlate (kendiliğinden yazar) |
| `orhun:helped` | Komiser Orhun’un borcuna para gönderdi | ZaferBank › Orhun K. hesabına para gönder | _henüz hiçbir şey (ileride bağlanacak)_ |
| `orhun:missing-list` |  | Orhun › "Son üç yılın bütün kayıp ilanlarını tar…" | Orhun › soru "Kayıp ilanlarından ne çıktı?" |
| `orhun:reported` |  | Orhun › "Bunu iç denetime bildirmem gerekiyor." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `orhunDone` | Orhun şüpheliyi bulduklarını söyledi | Orhun › "İfadesini aldınız mı uygulamada gözükmü…" | İnanç › start |
| `ozge:audit` |  | Özge › "Doğruyu söyle. Ne biliyorsan."<br>Özge › "Bildiğini söyleme."<br>Özge › "Sen karışma, ben hallederim." | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar) |
| `ozge:knows-money` |  | Özge › soru "Hesabıma para yattı, kimseye söyleme." | Özge › "Bildiğini söyleme." |
| `ozge:tox` |  | Özge › "Söyleyin. Bilmeye hakkı var."<br>Özge › "Henüz değil. Soruşturma bitene kadar ki…" | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar) |
| `part1Done` | Özge ile ilk konuşma bitti; ifadeler ve otopsi Poltel’de | Özge › "Kapalı değildi Erdiyi engelledim ben"<br>Özge › "İfadeleri bana poltel üzerinden gönder" | Özge › soru "Basın ne diyor?"<br>Özge › soru "Sen nasılsın, uyuyabiliyor musun?"<br>Özge › soru "Berat’ın telefonu bulundu mu?"<br>Özge › soru "Deniz nasıl?"<br>Orhun › start<br>Orhun › soru "Otopsiyi kim yaptı?"<br>Orhun › soru "Akşama iki bira dedin, ne oldu o iş?"<br>Atakan › start<br>Atakan › soru "İzin günün nasıl geçti?"<br>Atakan › soru "Yusuf’u bir daha konuşturabilir misin?"<br>Erdi › start<br>Harita › Berat'ın Evi görünür<br>Harita › Kampüs Kafe görünür<br>Harita › Üniversite görünür<br>Harita › Adli Tıp Kurumu görünür<br>Pano › Olay Yeri bulunur<br>Poltel › Yusuf Kasap - İfade Tutanağı gelir<br>Poltel › Deniz Yılmaz - İfade Tutanağı gelir<br>Poltel › Berat Yılmaz - Otopsi Raporu gelir<br>Mail › emniyet.gov.tr<br>Kayıtlar › Not 1 (memo-phone) gelir<br>Sinstagram › @berat.ylmz aranabilir<br>Sinstagram › @furkan.shn aranabilir<br>Sinstagram › @yusuf.kasap aranabilir<br>Sinstagram › @deniz.yilmaz aranabilir<br>News › "Berat Yılmaz dosyasında cinayet şüphesi" çıkar |
| `photo-restored` | Yırtık fotoğraf birleştirildi | Laboratuvar › Yırtık Fotoğraf | Atakan › soru "Yırtık fotoğraftaki adamla kameradaki a…" |
| `plate:mv` | Adil’le görüşen makam aracının plakası alındı | Harita › Sanayi Çay Ocağı › Uzaktan gözetle | Orhun › afterStatement<br>Orhun › soru "Plaka haberi gazeteye nasıl çıktı?"<br>Orhun › soru "Danışmanın adı ne?"<br>İnanç › soru "Çay ocağına baskın için hazır mısınız?"<br>Erdi › desk (kendiliğinden yazar)<br>Erdi › soru "Müdürüm, Yılmaz’ın danışmanını tanıyor …"<br>Kaymakam › informed (kendiliğinden yazar)<br>Kaymakam › soru "Yılmaz Bey’in danışmanıyla görüşmem ger…"<br>Harita › Sanayi Çay Ocağı › Çay ocağını ara görünür<br>Harita › Yılmaz Eğitim Vakfı görünür<br>Harita › Yılmaz Eğitim Vakfı › Binayı gözetle görünür<br>Pano › Makam Aracı bulunur<br>Süreli olay › kaymakam-calls başlar<br>Süreli olay › mp-writes başlar<br>News › "Cinayet soruşturmasında Meclis aracı iddiası" çıkar |
| `player:dirty-hands` | Komiser usulsüzlüğe başvurdu | Özge › "Bildiğini söyleme."<br>Özge › "Gitsin. Kızın yerini al."<br>Orhun › "Bunu şimdilik kimseye söyleme."<br>Orhun › "Bu bilgiyi şimdilik raporlara yazma."<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Benimkini verme. Diğerlerini ver."<br>İnanç › "Gitsin. Kızın yerini al."<br>Doğa › "Gitsin. Kızın yerini al."<br>Harita › Aydın Ailesinin Evi › Ece’nin odasına bak (izinsiz) | Final › Berat Yılmaz Dosyası › Kirli Eller |
| `poltel:ozge-file-read` |  | Poltel › Özge - Personel Sicil Dosyası açılınca | _henüz hiçbir şey (ileride bağlanacak)_ |
| `press:anonymous` | Kayıp öğrenci haberi isimsiz yayımlandı | Selin Aras › "Adını çıkar. Ailesi korunmalı." | News › ""Kızım cuma görüşürüz dedi, bir daha aramadı"" çıkar |
| `press:held` | Selin Aras haberi bekletti | Selin Aras › "Hiç yayımlama. Soruşturmayı tehlikeye a…" | _henüz hiçbir şey (ileride bağlanacak)_ |
| `press:named` | Kayıp öğrencilerin adları yayımlandı | Selin Aras › "Yayımla. Herkes duysun." | News › "Mezbahadaki fotoğraflardaki öğrenciler kim?" çıkar |
| `pressure:erdi` | Erdi baskıyı aktardı | Erdi › "Anlaşıldı müdürüm. Katile odaklanıyoruz."<br>Erdi › "Geçmişine bakmadan katili nasıl bulacağ…"<br>Erdi › "Kim aradı Ankara’dan?" | Özge › soru "Erdi seni de sıkıştırıyor mu?"<br>İnanç › order<br>İnanç › soru "Teşkilatta neler konuşuluyor?"<br>Erdi › desk (kendiliğinden yazar)<br>Erdi › soru "Müdürüm, savcılık dosyayı istedi mi?"<br>Erdi › soru "Ek ekip verebilir misiniz?"<br>Erdi › soru "Ne zaman döneceğimi soran oldu mu?"<br>Süreli olay › kaymakam-calls başlar |
| `pressure:kaymakam` | Kaymakamla konuşuldu | Kaymakam › "Tabii Kaymakam Bey, gelişmeleri size bi…"<br>Kaymakam › "Soruşturma gizli Kaymakam Bey. Bilgiyi …"<br>Kaymakam › "(Cevap verme)" | Özge › soru "Kaymakam beni aradı."<br>Kaymakam › soru "Kaymakam Bey, aile ne zaman ifade vereb…"<br>Selin Aras › soru "Kaymakamı araştırıyor musun?"<br>Süreli olay › mp-writes başlar |
| `pressure:refused` | Komiser kaymakamı reddetti | Kaymakam › "Soruşturma gizli Kaymakam Bey. Bilgiyi …"<br>Kaymakam › "(Cevap verme)" | Erdi › desk (kendiliğinden yazar)<br>Kayıtlar › Bilinmeyen Numara (unknown-1) gelir |
| `print:adil` | Parmak izi Adil’e çıktı | Laboratuvar › Bardaktaki Parmak İzi | Özge › soru "Bardaktaki iz Adil’e çıktı, haberin var…"<br>Behram › soru "Adil’in sabıka kaydını yollar mısın?"<br>Süreli olay › kaymakam-calls başlar |
| `seen:adil` |  | Sinstagram › @adil.abi açılınca | _henüz hiçbir şey (ileride bağlanacak)_ |
| `seen:berat` |  | Sinstagram › @berat.ylmz açılınca | _henüz hiçbir şey (ileride bağlanacak)_ |
| `seen:ece` |  | Sinstagram › @ece.aydin açılınca | _henüz hiçbir şey (ileride bağlanacak)_ |
| `selin:families` |  | Selin Aras › "Adını çıkar. Ailesi korunmalı."<br>Selin Aras › "Yayımla. Herkes duysun."<br>Selin Aras › "Hiç yayımlama. Soruşturmayı tehlikeye a…" | Selin Aras › desk (kendiliğinden yazar) |
| `selin:refused` |  | Selin Aras › "Benimle bir daha iletişime geçmeyin." | _henüz hiçbir şey (ileride bağlanacak)_ |
| `selin:talked` | Gazeteci Selin Aras ile konuşuldu | Selin Aras › "Kaynağın kim?"<br>Selin Aras › "Hangi dosya?" | Selin Aras › desk (kendiliğinden yazar)<br>Selin Aras › soru "Berat hakkında başka ne biliyorsun?"<br>Selin Aras › soru "Kaymakamı araştırıyor musun?"<br>Selin Aras › soru "Sana bilgi verirsem ne yaparsın?"<br>Selin Aras › soru "Numaramı kimden aldın?" |
| `sent:bribe-return` |  | ZaferBank › Gönderene iade hesabına para gönder | Süreli olay › bribe-kept iptal olur |
| `sent:orhun-debt` |  | ZaferBank › Orhun K. hesabına para gönder | _henüz hiçbir şey (ileride bağlanacak)_ |
| `status:dismissed` | Komiser meslekten çıkarıldı | _henüz hiçbir şey_ | Poltel kilitlenir<br>Final › Komiser |
| `status:suspended` | Komiser görevden uzaklaştırıldı | _henüz hiçbir şey_ | Harita › Atakan görev alabilir<br>Harita › Doğa görev alabilir<br>Harita › Orhun görev alabilir<br>Harita › İnanç görev alabilir<br>Poltel kilitlenir<br>Final › Komiser |
| `storage:entered` | Soğuk hava deposuna girildi | Harita › Eski Soğuk Hava Deposu › Depoya gir | _henüz hiçbir şey (ileride bağlanacak)_ |
| `toxicology` | Toksikoloji raporu geldi: maktul önce bayıltılmış | Harita › Adli Tıp Kurumu › Ek toksikoloji tahlili iste | Özge › afterMezbaha (kendiliğinden yazar)<br>Özge › later (kendiliğinden yazar)<br>Özge › soru "Toksikoloji sonucunu gördün mü?"<br>Erdi › pressure<br>Erdi › desk (kendiliğinden yazar)<br>Poltel › Berat Yılmaz - Toksikoloji Raporu gelir<br>News › "Berat Yılmaz’a ölmeden önce ilaç verilmiş" çıkar |
| `witness:protected` | Kritik tanık koruma altına alındı | Doğa › "Ona koruma ver. Kimse yanına yaklaşması…" | Final › Tanıklar |

## Sayılar

Oyuncu bu sayıları görmez. Başlangıç değerleri `state.json` içinde.

| Sayı | Anlamı | Başlangıç | Artıranlar | Azaltanlar | İşe yaradığı yerler |
| --- | --- | --- | --- | --- | --- |
| `doubt` | Komiserin gerçekte nerede olduğuna dair şüphe (gizli son) | 0 | Özge › soru "Basına kim sızdırıyor sence?"<br>İnanç › soru "Telefon kayıtlarına baktılar mı?"<br>Erdi › soru "Ne zaman döneceğimi soran oldu mu?"<br>Selin Aras › soru "Numaramı kimden aldın?"<br>0543 112 07 21 › "Yurt dışındayım. Gelemem."<br>Kayıtlar › Annem (mom) dinlenince | — | Final › Komiser |
| `integrity` | Mesleki dürüstlük | 70 | Özge › "Doğruyu söyle. Ne biliyorsan."<br>Özge › "Gözaltına al."<br>Orhun › "İyi yaptın. Tutanağa geçir."<br>Orhun › "Bunu iç denetime bildirmem gerekiyor."<br>Atakan › "Gözaltına al."<br>Behram › "Gözaltına al."<br>İnanç › "İkimize de gönder, kayıt dışı bir şey y…"<br>İnanç › "Gözaltına al."<br>Doğa › "İfadesine ekle."<br>Doğa › "Gözaltına al."<br>Doğa › "İfadesini tutanağa geçir, hemen."<br>Kaymakam › "Soruşturma gizli Kaymakam Bey. Bilgiyi …"<br>0532 190 19 07 › "Bu parayı kabul edemem Yılmaz Bey."<br>ZaferBank › Gönderene iade hesabına para gönder | Özge › "Gitsin. Kızın yerini al."<br>Atakan › "Gitsin. Kızın yerini al."<br>Behram › "Gitsin. Kızın yerini al."<br>İnanç › "Ne istiyorsa ver, sorun çıkmasın."<br>İnanç › "Gitsin. Kızın yerini al."<br>Doğa › "Gitsin. Kızın yerini al."<br>Erdi › "Anlaşıldı müdürüm. Katile odaklanıyoruz."<br>Kaymakam › "Tabii Kaymakam Bey, gelişmeleri size bi…"<br>0532 190 19 07 › "Anlıyorum. Elimden geleni yapacağım."<br>0543 112 07 21 › "Biri gelecek. (Ekibi topla, buluşma yer…"<br>Harita › Aydın Ailesinin Evi › Ece’nin odasına bak (izinsiz)<br>ZaferBank › Orhun K. hesabına para gönder<br>Süreli olay › bribe-kept: `mp:wrote` olduktan 45 dk sonra, `sent:bribe-return` olmadıysa | Final › Komiser |
| `pressure` | Üstlerden gelen baskı | 20 | Özge › "Bundan Erdi'ye tek kelime etmeyeceksin."<br>Özge › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Orhun › "İyi yaptın. Tutanağa geçir."<br>Atakan › "Bütün birimlere bildir. Yakalama kararı…"<br>Atakan › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Behram › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>İnanç › "Bana gönder. Erdi’yle ben konuşurum."<br>İnanç › "Verme. Savcı onayı olmadan kimse kimsen…"<br>İnanç › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Doğa › "Tanık koruma için başvurun."<br>Doğa › "Bütün ekipleri seferber et. Bulun onu."<br>Doğa › "Savcıyla konuşacağım. Ona koruma ve ind…"<br>Erdi › "Geçmişine bakmadan katili nasıl bulacağ…"<br>Erdi › "Kimsenin üstünden iş çevirmiyorum müdür…"<br>Erdi › "Benim ekibimden kimse gazeteciyle konuş…"<br>Erdi › "Rapor sadece bizde değil müdürüm. Adli …"<br>Erdi › "Sorguyu ben istedim. Sorumlusu benim."<br>Erdi › "Orhun sorguladı ama sızdıran o değil."<br>Erdi › "Mezbahayı gece bulduk müdürüm, raporu s…"<br>Erdi › "Sızıntıyı ben de araştırıyorum. Bizden …"<br>Erdi › "(Cevap verme)"<br>Erdi › "Size söyleyecek bir şeyim yok."<br>Erdi › "Bu ekibin başarısı, sizin değil."<br>Erdi › "Kapatamayız. Kızlar hâlâ kayıp."<br>Kaymakam › "Soruşturma gizli Kaymakam Bey. Bilgiyi …"<br>Kaymakam › "(Cevap verme)"<br>Kaymakam › "Açıklanacak bir şey yok. Soruşturma sür…"<br>Kaymakam › "Dostluğun banka hesabından gelmesine al…"<br>Selin Aras › "Yayımla. Herkes duysun."<br>Harita › Yılmaz Eğitim Vakfı › Gönüllü kartının fotoğrafını göster<br>Harita › Yılmaz Eğitim Vakfı › Gönüllü listesini iste<br>ZaferBank › Gönderene iade hesabına para gönder<br>Süreli olay › bribe-kept: `mp:wrote` olduktan 45 dk sonra, `sent:bribe-return` olmadıysa | Erdi › "Haklısınız müdürüm, dikkat ederim."<br>Erdi › "Ekibi tek tek konuşturacağım."<br>Erdi › "Anlaşıldı." | Final › Ankara |
| `trust:Atakan` | Atakan'ın komisere güveni | 50 | Atakan › "Neden öyle düşündün?"<br>Atakan › "Görüntüyü netleştirmeye çalış." | Atakan › "Gitsin. Kızın yerini al."<br>Atakan › soru "Gazeteyle konuştun mu?" | 0543 112 07 21 › "Atakan gelecek."<br>Harita › Atakan görev alabilir<br>Final › Atakan |
| `trust:Behram` | Behram'ın komisere güveni | 50 | Behram › "Tamam. Ben dönene kadar Adil'e kimse do…"<br>Behram › "Haklısın, sana haber vermeliydim."<br>Behram › soru "Cuma gecelerini biliyor muydunuz?" | Behram › "Bekleyemezdim. Bir çocuk öldü."<br>Behram › "Gitsin. Kızın yerini al." | Final › Behram |
| `trust:Doğa` | Doğa'nın komisere güveni | 50 | Doğa › "Önce bir su ver çocuğa, korkmuş gibi."<br>Doğa › "Doğruyu söylersen sana yardım ederiz. P…"<br>Doğa › "Savcıdan süre uzatması isteyin. İçeride…"<br>Doğa › soru "Sen nasılsın? Sorgu ağır geçti." | Doğa › "Gitsin. Kızın yerini al." | 0543 112 07 21 › "Doğa gelecek."<br>Harita › Doğa görev alabilir<br>Final › Doğa |
| `trust:Orhun` | Orhun'un komisere güveni | 50 | Orhun › "Otopsi raporu ne zaman çıktı"<br>Orhun › "İyi yaptın. Tutanağa geçir."<br>Orhun › "Bunu şimdilik kimseye söyleme."<br>Orhun › "Doğru yapmışsın. Adamı tarif et."<br>Orhun › soru "Annen nasıl?"<br>Erdi › "Sorguyu ben istedim. Sorumlusu benim."<br>ZaferBank › Orhun K. hesabına para gönder | Orhun › "Neden bana sormadan sorgulattın?"<br>Orhun › "Bunu iç denetime bildirmem gerekiyor."<br>Erdi › "Orhun sorguladı ama sızdıran o değil." | Harita › Orhun görev alabilir<br>Final › Orhun |
| `trust:Özge` | Özge'nin komisere güveni | 50 | Özge › "Söyleyin. Bilmeye hakkı var."<br>Özge › soru "Sen nasılsın, uyuyabiliyor musun?"<br>Özge › soru "Erdi seni de sıkıştırıyor mu?"<br>Özge › soru "Hesabıma para yattı, kimseye söyleme." | Özge › "Kızım ben size izindeyken bana yazmayın…"<br>Özge › "Bildiğini söyleme."<br>Özge › "Gitsin. Kızın yerini al." | 0543 112 07 21 › "Özge gelecek."<br>Final › Özge |
| `trust:İnanç` | İnanç'ın komisere güveni | 50 | İnanç › "Bana gönder. Erdi’yle ben konuşurum."<br>İnanç › "İkimize de gönder, kayıt dışı bir şey y…"<br>İnanç › "Verme. Savcı onayı olmadan kimse kimsen…" | İnanç › "Hayır gelmeme daha var. Buradan soracağ…"<br>İnanç › "Ne istiyorsa ver, sorun çıkmasın."<br>İnanç › "Benimkini verme. Diğerlerini ver."<br>İnanç › "Gitsin. Kızın yerini al." | 0543 112 07 21 › "İnanç gelecek."<br>Harita › İnanç görev alabilir<br>Final › İnanç |
| `witnessDanger` | Tanıkların tehlike düzeyi | 10 | Behram › "Bekleyemem, adamlarını hazır tut. Gerek…"<br>İnanç › "Bütün çıkışları kapatın."<br>Doğa › "Serbest bırakın ama gözünüzü ayırmayın."<br>Doğa › "Bütün ekipleri seferber et. Bulun onu."<br>Doğa › "Adil’in adamlarının elinde olabilir. Be…"<br>Selin Aras › "Yayımla. Herkes duysun." | Doğa › "Savcıdan süre uzatması isteyin. İçeride…"<br>Doğa › "Tanık koruma için başvurun."<br>Doğa › "Bunu kimse bilmesin. Önce onu korumamız…"<br>Doğa › "Ona koruma ver. Kimse yanına yaklaşması…"<br>Selin Aras › "Adını çıkar. Ailesi korunmalı." | Final › Tanıklar |

