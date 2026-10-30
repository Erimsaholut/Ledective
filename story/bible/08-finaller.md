# 8. Finaller

Sonucu tek bir son seçim belirlemez; oyun boyunca verilen onlarca küçük karar
belirler. Final bölümlerden oluşur ve her bölüm ayrı değerlendirilir. Böylece
aynı ana finale ulaşan iki oyuncunun deneyimi farklı olur ve her birleşim için
baştan sona ayrı hikâye yazmak gerekmez.

Oyunda: `assets/story/endings.json`. Oyun `final:ready` bayrağıyla biter.
Settings → Hikâye durumu → **Finali önizle** o anki seçimlerle finali gösterir.

## Bölümler

Her bölümde koşulu tutan **ilk** seçenek anlatılır. En özel durum en üstte,
koşulsuz yedek en altta.

### Berat Yılmaz dosyası

Fail Kerem Aydın [KARAR]. "Çözüldü" (`case:solved`) Kerem'in fail olarak
bulunması demek; "Yanlış İnsan" (`case:wrong-person`) en olası haliyle
Adil'in suçlanması.

| Final | Koşul (taslak) | Özet |
| --- | --- | --- |
| Yanlış İnsan | `case:wrong-person` | Deliller yanlış yorumlandı, yanlış kişi suçlandı. Gerçek fail bulunamasa da oyun biter; oyuncu hatasının sonuçlarını görür |
| Adaletin Bedeli | `case:solved` + `coverup:exposed` | Cinayet çözülür, siyasi bağlantılar ortaya çıkar; ekip dağılır, komiser soruşturma geçirir |
| Kirli Eller | `case:solved` + `player:dirty-hands` | İnsanları kurtarmak için usulsüzlük yapıldı; masumlar hayatta ama komiser artık kendisi soruşturulabilir |
| Sessiz Zafer | `case:solved` | Katil yakalanır, dosya kapanır; emri verenler dokunulmaz kalır |
| Çözülemeyen Dosya | (yedek) | Dosya faili meçhul kapanır |

### Komiser

| Durum | Koşul |
| --- | --- |
| Yakalama kararı | `legal:warrant-issued` |
| Meslekten çıkarıldı | `status:dismissed` |
| Görevden uzaklaştırıldı | `status:suspended` |
| Görevde ama itibarsız | `integrity < 40` |
| Görevde | (yedek) |

İki oyuncu aynı katili bulabilir; biri görevine devam ederken diğeri
meslekten çıkarılmış olabilir. Biri gerçeği ortaya çıkarıp hüküm giyebilir,
diğeri cinayeti çözemese de dürüstçe görevini sürdürmüş olabilir.

### Tanıklar ve kayıp öğrenciler

| Durum | Koşul |
| --- | --- |
| Kritik tanık korundu | `witness:protected` |
| Bir tanık kayboldu | `witnessDanger >= 60` |
| [?] Kayıp öğrenciler bulundu / bulunamadı | [?] |

### Ekip

Her ekip üyesi için ayrı bölüm: Özge, Atakan, Orhun, Doğa, İnanç, Behram.
Şu an güvene göre üç taslak var (`>= 70`, `<= 30`, yedek). Kişisel hikâyeler
yazıldıkça her birine o hikâyenin bayraklarına bağlı seçenekler eklenir
(ör. Atakan ihbar edildiyse, İnanç'ın disiplin soruşturması nasıl bitti).

### Ankara (üstlerden gelen baskı)

`pressure >= 70` ya da yedek.

### Gerçek: Komiser neredeydi? [KARAR: gizli son]

| Durum | Koşul |
| --- | --- |
| Hiç yurt dışında değildi | `twist:never-abroad` |

Sadece yeterince ipucu toplayan oyuncu bu sona ulaşır (gizli `doubt`
sayısı; bkz. 01). **[KARAR, 30.10.2026]** Diğer bölümlerin yerine geçer:
final ekranından önce telefon bozulur (sayılar, galeri, "SEN DELİ
DEĞİLSİN" mailleri, hasta bakıcının ses kaydı) ve komiserin her şeyi
uydurduğu ortaya çıkar. Ayrıntılar 01-ana-gizem.md › Gizli son.

**Final soruşturması [KARAR]:** savcıya ifade, MatesApp'te. Sorular ve
seçenekler 04-bolumler.md › Bölüm VI.

### [?] Eklenecek bölümler

- Örtbas edilen suçlar ortaya çıktı mı?
- Komiserin kendi işlediği ya da gizlediği suçlar ortaya çıktı mı?
- Yan hikâyelerin sonuçları (Kayıp Kız, Eski Dosya...).
- Hakan ve eşi.
