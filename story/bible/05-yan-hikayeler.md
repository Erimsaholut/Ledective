# 5. Yan hikâyeler ve ahlaki ikilemler

Hepsi [ÖNERİ]. Bazıları ana hikâyeye bağlanır, bazıları tamamen bağımsızdır.
Yan hikâyeler üç şekilde bitebilir: bağımsız sonuçlanır, ana hikâyeye dolaylı
katkı sunar ya da oyuncunun ekip üyeleriyle ilişkisini değiştirir.

Hiçbiri zorunlu değil: yan görevden gelen bir bilgiye ana hikâyede daha zor
bir yoldan da ulaşılabilmeli.

## Şablonlar

### Hikâye şablonu

```markdown
### Ad
**Bağlantı:** bağımsız / ana hikâyeye dolaylı / karakter ilişkisi
**Açılış:** nasıl başlıyor, hangi uygulamada (bayrak)
**Gelişme:** ...
**Seçim noktaları:** ...
**Sonuçlar:** her seçimin bayrak ve sayı etkileri
**Ana hikâyeye katkısı:** ...
**Alternatif yol:** bu hikâye yapılmazsa katkıya nereden ulaşılır
```

### İkilem şablonu

```markdown
### İkilem N — Ad
**Durum:** ...
**Neden zor:** iki doğru (ya da iki yanlış) çatışıyor

| Seçenek | Gerekçe | Kazanç | Bedel | Etkiler (unlocks) |
| --- | --- | --- | --- | --- |

**Üçüncü yol:** varsa, hangi ön koşulla açılır (genelde bir yan görev)
**Sonradan:** bu karar hangi olaylarda tekrar karşısına çıkar
```

## Ekibin kişisel hikâyeleri

| Karakter | Konu | Çatışma |
| --- | --- | --- |
| Özge | Vicdan ve sadakat | Bir tanığın eski arkadaşı olduğunu saklıyor; Atakan'ın sevgilisini tanıyor |
| Atakan | Aşk ve şantaj | Milletvekiliyle bağlantılı bir aileden biriyle gizli ilişki, sızdırılan bilgi |
| Orhun | Aile ve görev | Borçlar, hesabındaki şüpheli ödeme |
| Doğa | Yasak ilişki ve mesleki etik | Bir tanığa yakınlaşıyor, ayrıntıları görmezden geliyor |
| İnanç | Emir ve vicdan | Üstünden hukuka aykırı emir |

Ayrıntılar 02-karakterler.md'de. Bu hikâyelerin hepsi cinayetle bağlantılı
olmak zorunda değil.

## Bağımsız dosyalar

Komiserin telefonuna gelen sıradan mesajlarla başlayabilir (SMS, mail,
MatesApp).

| Dosya | Problem | Olası bağlantı |
| --- | --- | --- |
| Kayıp Kız | 17 yaşında bir kız evden kaçmış; ailesi arıyor ama kız eve dönmekten korkuyor | Bir tanıkla tanıştırabilir; tanık sonra mezbahayla ilgili bilgi verir |
| Son Mesaj | İntihar eden bir polisin ses kaydı cinayet ihtimalini düşündürüyor | [?] |
| Yanlış İhbar | Komşusunu şikâyet eden vatandaşın kişisel hesabı var | Bağımsız |
| Kayıp Delil | Emniyet deposundan delil kayboluyor; suçlanan memur başka bir usulsüzlüğü ortaya çıkarmaya çalışıyor | Erdi'ye bağlanabilir |
| Bir Babanın Yalanı | Oğlunu koruyan babanın yanlış ifadesi masum birini suçlu durumuna düşürüyor | Milletvekiliyle ayna |
| Gizli Aşk | İki ekip üyesi yakınlaşıyor; kritik bir atamada biri diğerine öncelik veriyor | Ekip güveni |
| Eski Dosya | Komiserin yıllar önce kapattığı soruşturmada hata olabileceğini gösteren yeni delil | İkilem 10 |

## Ahlaki ikilemler

### İkilem 1 — Rüşvet mi, delil mi?
Milletvekilinin danışmanı özel olarak ulaşır: cinayet çözülsün ama Berat'ın
geçmişi araştırılmasın. Hesaba para yatar.

| Seçenek | Kazanç | Bedel |
| --- | --- | --- |
| Reddet, savcılığa bildir | Dürüstlük | Savcılık dosyaya el koyabilir; hassas bir tanığın kimliği açığa çıkabilir |
| Kabul et, gizlice devam et | Zaman, baskının azalması | Kirli eller, sonradan iç denetim |
| Parayı kullanmadan göndericiyi araştır | Bilgi | Zaman; para hesapta durdukça risk |

**Oyundaki karşılığı [KANON, taslak]:** Para birden gelmez; baskı basamak
basamak tırmanır:

1. **Erdi** (şube müdürü): cinayet netleşince il müdürünün ve Ankara'nın
   aradığını, çocuğun geçmişinin kurcalanmamasını söyler (`pressure:erdi`).
2. **Kaymakam**: komiser araştırmaya devam edince doğrudan yazar ve
   gelişmeleri önce kendisiyle paylaşmasını ister. Kabul (`kaymakam:informed`,
   integrity −10) ya da ret (`pressure:refused`, pressure +10).
3. **Milletvekili baba**: plaka ya da defter onu ilgilendirmeye başlayınca
   kimsenin bilmediği bir numaradan yazar; ardından "Y. Eğitim Vakfı
   Danışmanlık"tan 50.000 TL "Geçmiş olsun" açıklamasıyla gelir (`mp:wrote`).
4. **Tehdit**: ret ya da iade, gözdağı mesajlarını ve Erdi'nin uyarısını
   getirir. Para 45 dakikalık oyun süresi içinde iade edilmezse iç denetim
   başlar.

Savcılığa bildirme ve göndericiyi araştırma seçenekleri henüz yok.

### İkilem 2 — Katil mi, kurtarıcı mı? [KARAR: ana ikilem]
Katil Kerem Aydın, mezbahadaki diğer kurbanların yerini bilen tek kişi.
Güvenlik ve ceza garantisi istiyor. Oyuncu bu noktada Berat'ın pişman
olduğunu ve kanıtlarını Kerem'e vermeye hazırlandığını da biliyor olabilir.
Kerem bunu ondan duyarsa ne yapar? [?]
Seçenekler: derhâl gözaltı / savcıyla iş birliği ve koruma / kaçmasına göz yum.

### İkilem 3 — Bir meslektaşını ele vermek
Atakan bilgi sızdırdığını itiraf eder; tehdit edilen bir yakınını koruyordur.
Seçenekler: ihbar et (yakını tehlikeye girer) / örtbas et (başkaları ölebilir)
/ ikinci şans ver (ekip güveni sarsılır).

### İkilem 4 — Karısının tedavisi için cinayet işleyen adam
> Not: Berat'ın katili Kerem olduğu için Hakan başka bir cinayetin ya da
> girişimin faili olmalı (bkz. 02 › Hakan Demir).

Hakan itiraf eder, eşinin tedavisinin kesilmemesini ister.

| Seçenek | Bedel |
| --- | --- |
| Hukuki işlem, eşine karışma | Aile ağır ekonomik sonuçlarla karşılaşır |
| İfadeyi al, eşine yasal yardım bul | Zaman, kaynak ve güvenilir kurumlar gerekir |
| Kaçmasına yardım et | Cinayetten hesap vermez |
| İtirafı üst bağlantılar için kullan | Hakan'ın ailesi tehdit edilebilir |

ZaferBank: hastane hesabına ödeme yardım eder; soruşturmadaki birinin ailesine
para vermek çıkar çatışması iddiasına yol açabilir (`payees` + `paid:<id>`).
Ahlaki ağırlık, Hakan'ın mazur görülmesinden değil, onu bu noktaya getirenlerin
de suçun parçası olmasından gelir.

### İkilem 5 — İki kişiyi kurtarmak için birini tehlikeye atmak
Kayıp öğrencilerden biri hayatta. Yerini bilen tanık, konuşursa ailesinin
öldürüleceğinden korkuyor.
Seçenekler: resmî koruma (sızıntı riski) / tanığı açıklamadan aramak (zaman)
/ tanığı zorlamak (güvenilmez ifade).
**Üçüncü yol:** daha önce bir yan görevden bilgi toplanmışsa başarılı bir yol
açılır. Hiçbir seçenek otomatik ölümle bitmez.

### İkilem 6 — Kendi ekibinden birini feda etmek
İnanç, Erdi'nin yok edilmesini emrettiği delili komisere getirir; hakkında
disiplin soruşturması açılır. Delili savcılığa teslim etmek İnanç'ın usulsüz
bir işlemini de açığa çıkarır; saklamak milletvekili soruşturmasına zarar
verir. İnanç korunmak istemez, doğru olanın yapılmasını ister.

### İkilem 7 — Gazetecinin yayımlamaması gereken gerçek
Belgelerde gizli bir tanığın kimliği var.
Seçenekler: yayını destekle (`press:story-published`, `witnessDanger +=`)
/ durdur (komiser bir şey saklıyor gibi görünür) / kimliksiz, kanıtlı bir
haber için ikna et (gazeteci kabul etmeyebilir: `trust:<gazeteci>`).

### İkilem 8 — Suçsuz olduğunu bildiğin adam
Tutuklu adamın suçsuz olduğunu gösteren delili hemen paylaşmak onu serbest
bırakır ama örgütün izini kaybettirir.

### İkilem 9 — Sevdiğin insanın yalanı
Doğa'nın yakınlaştığı tanık bir gece nerede olduğu konusunda yalan söylemiş.
Doğa'yı korumak güveni artırır, ama başka bir şüpheli aleyhine yanlış bir
zaman çizelgesi oluşabilir.

### İkilem 10 — Komiserin geçmişteki hatası
Hatayı kabul edip dosyanın yeniden incelenmesini sağlamak itibara zarar verir;
susmak, milletvekilinin adamlarının şantaj malzemesine dönüşür.

## Sonradan fark edilen ipuçları

Pano'ya kendiliğinden düşmezler; sadece dikkatli oyuncular görür.

- Özge ilk konuşmada bir karakterden bahsederken duraksar.
- Atakan'ın Sinstagram fotoğrafındaki biri ileride gizli tanık çıkar.
- Bir banka hareketinin açıklamasında News'te geçen vakıf adı yazar.
- Orhun'un bira teklif ettiği akşam önem kazanır.
- Berat'ın mezbahadaki fotoğrafının tarihi başka bir olay için önemlidir.
- Bir tanığın ifade saatleri ile Sinstagram gönderi tarihleri tutmaz.
