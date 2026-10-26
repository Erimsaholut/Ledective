# 4. Ana hikâyenin bölüm iskeleti

Bölümler zorunlu görevler değil, **anlatı evreleridir**. Oyuncu birçok olayı
farklı sırayla keşfedebilir. Bir bölüm, onu açan bayraklarla başlar ve onu
kapatan bayraklarla biter; aradaki her şey sandbox.

Yollar birleşebilir, ama önceki seçimlerin sonuçlarını taşımalıdır
(bayraklar ve sayılar kalıcıdır).

## Şablon

```markdown
## Bölüm N — Ad
**Durum:** [KANON] / [ÖNERİ]
**Açılış:** hangi bayrak(lar)
**Kapanış:** hangi bayrak(lar)

- **Oyuncunun amacı:** ...
- **Öğrenilebilecek gerçekler:** (01'den hangileri, hangi düzeyde)
- **Açılan karakterler:** ...
- **Deliller ve uygulamalar:** ...
- **Büyük kararlar:** (05'teki ikilemler)
- **Değişen sayılar:** (trust, pressure, integrity, witnessDanger...)
- **Yan hikâyeler:** (bu evrede açılabilenler)
- **Alternatif yollar:** bir yol kapanırsa bilgiye nereden ulaşılır
```

## Bölüm I — Tatilde Gelen Ölüm
**Durum:** [KANON]
**Açılış:** oyunun başı
**Kapanış:** `part1Done`

- **Oyuncunun amacı:** Ne olduğunu anlamak, ekibi organize etmek.
- **Öğrenilebilecekler:** Berat'ın ölümü, ilk ifadeler, otopsinin intihar
  süsünü çürütmesi.
- **Uygulamalar:** MatesApp (Özge), Poltel (ifadeler, otopsi), News (ilk haber).
- **Kararlar:** Özge'ye sert mi meraklı mı yaklaşılacağı (`trust:Özge`).

## Bölüm II — Borçlar ve Yalanlar
**Durum:** [KANON] (kısmen)
**Açılış:** `part1Done`
**Kapanış:** `mezbaha-found`

- **Oyuncunun amacı:** Furkan'ı ve Adil'i bulmak.
- **Öğrenilebilecekler:** Paket, borç, parmak izi, kafe, defter, makam aracı,
  yanık harita, mezbaha.
- **Uygulamalar:** Harita (görevler), Pano ve Laboratuvar, Sinstagram (Furkan,
  Yusuf, Deniz, gizli Adil hesabı), Kayıtlar (tehdit), ZaferBank (rüşvet).
- **Kararlar:** Furkan sorgusunun tonu (`trust:Doğa`), Behram'la ilişki,
  rüşvetin iadesi (İkilem 1'in ilk adımı, `bribe-kept` süreli olayı).
- **Yan hikâyeler:** ilk bağımsız dosyalar (05).

## Bölüm III — Unutulan Dosyalar
**Durum:** [ÖNERİ]
**Açılış:** [?] (`mezbaha-found` + `news:old-case-found`?)
**Kapanış:** [?]

- **Oyuncunun amacı:** Mezbahadaki diğer fotoğrafların peşine düşmek.
- **Öğrenilebilecekler:** Yıllar önce örtbas edilen olay, milletvekilinin
  geçmişi, personel sicillerindeki şüpheli ayrıntılar.
- **Uygulamalar:** News arşivi (temel araç), Poltel sicilleri, Sinstagram eski
  gönderileri.

## Bölüm IV — Kimse Masum Değil
**Durum:** [ÖNERİ]

- Hakan'ın hikâyesi, kayıp öğrenciler, ekibin kişisel ilişkileri ve politik
  baskı derinleşir. Oyuncu meslektaşlarının gerçeklerini öğrenmeye başlar.
- İkilemler: 2, 3, 4, 5, 9.

## Bölüm V — Komiser Sanık Sandalyesinde
**Durum:** [ÖNERİ]

- Oyuncunun seçimlerine göre idari inceleme (`case:internal-investigation`),
  görevden uzaklaştırma (`status:suspended`), meslekten çıkarılma
  (`status:dismissed`) ya da adli süreç (`legal:warrant-issued`).
- Poltel kilitlenir; Harita'da sadece komisere güvenen subaylar yardım eder;
  News, Sinstagram, gazeteciler ve eski meslektaşlar temel araç olur.
- Hiçbiri zorunlu değil. Yasal yoldan ilerleyen oyuncu bu bölümü görevde
  geçirir; o zaman baskı (`pressure`) ve Erdi üzerinden yaşanır.
- İkilemler: 6, 10.

## Bölüm VI — Gerçeğin Bedeli
**Durum:** [ÖNERİ]

- Cinayetin ve bağlantılı suçların önemli kısmı ortaya çıkar. Oyuncu artık
  kimin suçlu olduğuna değil, **hangi delili kime vereceğine ve kimi
  koruyacağına** karar verir.
- İkilemler: 7, 8.

## Final — Kimin Adaleti?
**Durum:** İskelet [KANON], metinler [ÖNERİ]
**Açılış:** `final:ready`

Bkz. 08-finaller.md.

## Bölüm geçiş haritası

```mermaid
flowchart TD
  I[Bölüm I: Tatilde Gelen Ölüm] -->|part1Done| II[Bölüm II: Borçlar ve Yalanlar]
  II -->|mezbaha-found| III[Bölüm III: Unutulan Dosyalar]
  II -.->|bribe-kept süresi doldu| V
  III --> IV[Bölüm IV: Kimse Masum Değil]
  IV --> V[Bölüm V: Komiser Sanık Sandalyesinde]
  IV --> VI[Bölüm VI: Gerçeğin Bedeli]
  V --> VI
  VI -->|final:ready| F[Final: Kimin Adaleti?]
```
