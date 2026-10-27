# 9. Tutarlılık ve oynanabilirlik kontrolü

Her büyük yazım turundan sonra bu listeyi baştan sona geç.

## Otomatik

```bash
dart run tool/validate_story.dart
```

- [ ] HATA yok: olmayan düğüm, tanımsız sayı, hiçbir şeyin açmadığı ve
  planlanmamış bayrak, eksik görsel.
- [ ] UYARI yok ya da her biri bilerek bırakıldı (aşağıya not al).
- [ ] NOT listesi (planlanmış ve tohum bayraklar) yapılacaklarla örtüşüyor.
- [ ] `story/HIKAYE_SEMASI.md` yeniden üretildi (`--table`).
- [ ] `flutter test` geçiyor.

## Elle

### Çözülebilirlik
- [ ] Ana hikâyedeki her zorunlu bilgi en az iki yoldan ulaşılabilir (07).
- [ ] Hiçbir karakterle ilişkiyi bozmak oyunu bitirilemez hâle getirmiyor.
- [ ] Görevden uzaklaştırılan oyuncu, Poltel olmadan da ilerleyebiliyor
  (laboratuvar incelemeleri Poltel'de: uzaklaştırma öncesi bitmesi gereken
  bir inceleme var mı?).
- [ ] Hiçbir süreli olay, oyuncuyu bilmesinin mümkün olmadığı bir şey için
  cezalandırmıyor; süresi başlarken oyuncuya bir işaret veriliyor.

### Tutarlılık
- [ ] Hiçbir karakter, kronolojide (03) henüz öğrenmediği bir bilgiden
  bahsetmiyor.
- [ ] Yalan söyleyen her karakterin nedeni 01'de yazılı.
- [ ] Belge, haber, banka ve sohbet tarihleri birbirini tutuyor.
- [ ] Sicil ve haberler "sihirli gerçek" gibi değil; yanılabilir kaynaklar
  gibi yazılmış.

### Gizli kalması gerekenler
- [ ] Hiçbir içerikte komiserin bulunduğu ülke, şehir, para birimi ya da saat
  farkı geçmiyor (banka, SMS, sohbet, haber, fotoğraf).

### Anlamlı seçimler
- [ ] Her büyük seçimin gerekçesi, kazancı ve bedeli var (05).
- [ ] Her büyük seçim sonradan en az bir yerde karşısına çıkıyor (06 matrisi).
- [ ] Bazı iyi kararlar gerçekten işe yarıyor.
- [ ] Bariz iyi/kötü seçenek yok.
- [ ] Yan görevler zorunlu değil.

## Tohum bayraklar (NOT olarak görünür)

| Uyarı | Neden |
| --- | --- |
| `erdi-kept-out`, `photo-restored`, `print:adil`, `notebook-read`, `seen:*` açılıyor ama beklenmiyor | Hikâyenin devamına bağlanacak kancalar |
| `poltel:ozge-file-read`, `bribe:returned`, `news:old-case-found` açılıyor ama beklenmiyor | İskelet örnekleri; Bölüm III-V'te kullanılacak |
| `leak:*` (hunt, defended, sources, who-benefits) | Sızıntı gizemi; kaynak belli olunca bağlanacak |
| `heard:*` (orhun-secret, atakan-secret, atakan-photo, fake-police, adil-missing-case, adil-informant, erdi-ordered, erdi-knows-money, berat-past, witness, dead-line, phone-signal, notebook, orhun-visitor, camera-broken, records-odd, initials, kaymakam-knew, mp-refused-money, mp-knows-mezbaha, source-outside, old-case), `kaymakam:informed`, `behram:helps`, `behram:list`, `ozge:knows-money`, `orhun:*`, `furkan:*`, `press:*`, `selin:*` | Sohbetlerde ekilen tohumlar; kişisel hikâyeler ve sonraki bölümler yazılınca bağlanacak |
| `heard:records-odd` ("yurt dışından aranmış gibi görünmüyor"), `heard:mp-refused-money` (babanın "para istedi, vermedim" demesi Deniz'in ifadesiyle çelişir) | Bilerek konmuş çelişkiler: 01'deki "Komiser gerçekte nerede?" ve "Kim yalan söylüyor?" bölümleri |
