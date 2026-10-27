# 9. Tutarlılık ve oynanabilirlik kontrolü

Her büyük yazım turundan sonra bu listeyi baştan sona geç.

## Otomatik

```bash
dart run tool/validate_story.dart
```

- [ ] HATA yok: olmayan düğüm, tanımsız sayı, hiçbir şeyin açmadığı ve
  planlanmamış bayrak, eksik görsel.
- [ ] Her UYARI ya düzeltildi ya da bilerek bırakıldı (aşağıya not al).
- [ ] NOT listesi (planlanmış bayraklar) yapılacaklarla örtüşüyor.
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

### Anlamlı seçimler
- [ ] Her büyük seçimin gerekçesi, kazancı ve bedeli var (05).
- [ ] Her büyük seçim sonradan en az bir yerde karşısına çıkıyor (06 matrisi).
- [ ] Bazı iyi kararlar gerçekten işe yarıyor.
- [ ] Bariz iyi/kötü seçenek yok.
- [ ] Yan görevler zorunlu değil.

## Bilerek bırakılan uyarılar

| Uyarı | Neden |
| --- | --- |
| `erdi-kept-out`, `photo-restored`, `print:adil`, `notebook-read`, `seen:*` açılıyor ama beklenmiyor | Hikâyenin devamına bağlanacak kancalar |
| `poltel:ozge-file-read`, `bribe:returned`, `news:old-case-found` açılıyor ama beklenmiyor | İskelet örnekleri; Bölüm III-V'te kullanılacak |
| `heard:*` (orhun-secret, atakan-secret, fake-police, adil-missing-case, erdi-ordered, berat-past, witness), `kaymakam:informed`, `behram:helps`, `ozge:knows-money` | Sohbetlerde ekilen tohumlar; kişisel hikâyeler yazılınca bağlanacak |
