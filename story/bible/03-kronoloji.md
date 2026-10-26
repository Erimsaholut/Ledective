# 3. Gerçek kronoloji

Kim, neyi, ne zaman yaptı ve **o anda kim ne biliyordu**. Belgeler, haberler,
banka hareketleri ve sohbet geçmişleri bu tabloyla çelişmemeli.

## Zaman nasıl yazılır

Oyunda tarihler, oyunun **ilk açıldığı güne** göre geriye sayılır:

| Dosya | Alan |
| --- | --- |
| documents.json | `daysBeforeFirstOpen` |
| news.json, bank.json, sms.json, voicemail.json | `daysAgo` |
| chats.json geçmişi | `{"day": N}` ayracı |
| calendar.json | `dayOffset` (ileriye de sayabilir) |

Bu yüzden tabloda **G-N** (ilk açılıştan N gün önce) ve **G+N** kullan.
Oyun başladıktan sonraki olaylar gün değil **bayrak** sırasıyla gelir; onları
"Oyun içi" bölümüne yaz.

## Oyun başlamadan önce

| Zaman | Olay | Kim yaptı | O anda kim biliyordu | Oyuncu nasıl öğrenir | Durum |
| --- | --- | --- | --- | --- | --- |
| G-2900 (~8 yıl) | Eski belediye mezbahası kapatılır | Belediye | Herkes | News arşivi | [KANON, taslak] |
| G-1100 (~3 yıl) | Üniversiteli genç kadının şüpheli ölümünde takipsizlik | Savcılık | Aile, [?] | News arşivi | [KANON, taslak] |
| [?] | Berat ve arkadaşlarının karıştığı olay | [?] | [?] | [?] | [ÖNERİ] |
| [?] | Komiserin eski dosyasındaki hatalı karar | Komiser | [?] | News arşivi, eski ifadeler | [ÖNERİ] |
| G-700 | Yılmaz Vakfı burs açıklaması | Milletvekili | Herkes | News arşivi | [KANON, taslak] |
| G-40 | Özge'nin sicil değerlendirmesi | Amiri | Personel dairesi | Poltel sicil | [KANON, taslak] |
| [?] | Berat Adil'e 40.000 TL borçlanır | Berat | Berat, Adil | Defter (UV) | [KANON] |
| [?] | Berat derslere girmeyi bırakır, yoklamalar düzeltilir | Babası / okul | Danışman | Harita: üniversite | [KANON] |
| G-12 | Komiser İnanç'a "Raporları cumaya kadar bitirin" yazar | Komiser | İnanç | Sohbet geçmişi | [KANON] |
| G-12 | Maaş yatar | | | ZaferBank | [KANON] |
| G-10 | Komiser Barselona'ya uçar | Komiser | Büro | ZaferBank | [KANON] |
| G-7 | Berat Furkan'a paket verirken düşürür | Berat | Görenler | Yusuf ifadesi | [KANON] |
| G-6 | Atakan izin ister | Atakan | Özge | Sohbet geçmişi | [KANON] |
| G-5 | Orhun "imza işini" halleder | Orhun | [?] | Sohbet geçmişi | [KANON] |
| [?] (G-4/G-3) | Berat Deniz'e borcu olduğunu söyler | Berat | Deniz | Deniz ifadesi | [KANON] |
| Olay gecesi 23.40 | Berat kafeden telefonla konuşup çıkar, deri ceketli adam peşinden | [?] | Kafeci | Harita: kafe | [KANON] |
| Olay gecesi ~02.00 | Komşu "Adil abi, ödeyeceğim" yalvarışını duyar | [?] | Komşu | Harita: komşular | [KANON] |
| Olay gecesi | Berat bayıltılır, bıçaklanır, asılır | [?] | [?] | Otopsi, toksikoloji | [KANON: nasıl], [?: kim] |
| G-2 | Deniz cesedi bulur; ifadeler alınır, otopsi yapılır | Deniz, büro | Büro | Poltel | [KANON] |
| G-0 | Gündem24: "Milletvekilinin oğlu ölü bulundu" | Basın | Herkes | News | [KANON, taslak] |

## Oyun içi (bayrak sırasıyla)

| Tetikleyen | Olay | Kim yaptı | Kim biliyor | Nerede görünür |
| --- | --- | --- | --- | --- |
| Başlangıç | Özge komisere yazar | Özge | Büro | MatesApp |
| `part1Done` | Erdi komisere çıkışır; ilk belgeler gelir; bilinmeyen numara arar | | | MatesApp, Poltel, Kayıtlar |
| `part1Done` | Şehir Postası: "cinayet şüphesi" | Basın | [?] kaynak kim? | News |
| `furkanStatement` | "Dosyayı kapat" EFT'si yatar | [?] | Gönderen | ZaferBank |
| `furkanStatement` + 45 dk oyun süresi | İade edilmezse iç denetim incelemesi başlar | İç Denetim | Erdi? [?] | Mail |
| `plate:mv` | Adil makam aracındaki biriyle görüşür | Adil, [?] | | Harita raporu |
| `mezbaha-found` | Tehdit mesajı: "Cuma geldiğinde sıradaki sen olacaksın" | [?] | | Kayıtlar |

[?] "Cuma" neyin günü? Oyun içinde gerçek bir saat mi (timer), yoksa sadece
korku mu?

## Çelişki kontrolü

- [ ] Bir karakter, kronolojide henüz öğrenmediği bir bilgiden bahsetmiyor.
- [ ] Belge tarihleri ile haber tarihleri tutarlı.
- [ ] Banka hareketleri komiserin yurt dışında olmasıyla tutarlı.
- [ ] Tanık ifadelerindeki saatler (23.40, 02.00) birbirini tutuyor; tutmuyorsa
  bu bilerek konmuş bir ipucu ve 01'de nedeni yazılı.
