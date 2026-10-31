# Ledective Senaryo Ana Planı (Story Bible)

Bu klasör hikâyenin **gizli gerçeğini** tutar: oyuncunun asla doğrudan
okumayacağı, ama her diyaloğun, belgenin ve ipucunun dayandığı kaynak.
Oyuna giren içerik `assets/story/*.json` dosyalarındadır; burada kararlar
verilir, orada yazılır.

## Dosyalar

| Dosya | İçerik | Çalışma adımı |
| --- | --- | --- |
| [01-ana-gizem.md](01-ana-gizem.md) | Berat cinayetinin ve örtbasın gerçek hikâyesi | 1 |
| [02-karakterler.md](02-karakterler.md) | Karakter dosyaları ve ilişki ağı | 2 |
| [03-kronoloji.md](03-kronoloji.md) | Kim, neyi, ne zaman yaptı; o anda kim ne biliyordu | 3 |
| [04-bolumler.md](04-bolumler.md) | Yedi anlatı evresi ve final | 4 |
| [05-yan-hikayeler.md](05-yan-hikayeler.md) | Ekibin kişisel hikâyeleri, yan dosyalar, ahlaki ikilemler | 5 |
| [06-durumlar.md](06-durumlar.md) | Bayrak ve sayı sözlüğü, seçim-sonuç matrisi | 6 |
| [07-dagitim.md](07-dagitim.md) | Hangi bilgi hangi uygulamada, alternatif yollar | 7 |
| [08-finaller.md](08-finaller.md) | Final katmanları | 6 |
| [09-kontrol.md](09-kontrol.md) | Tutarlılık ve oynanabilirlik kontrol listesi | 9 |
| [10-oyun-testi.md](10-oyun-testi.md) | İlk oyun testinden çıkan öneriler: para, kısmi ödeme, sohbet fotoğrafları, seçim hissi | 9 |

8. adım (sahne, sohbet ve belge yazımı) doğrudan JSON dosyalarında yapılır;
biçim için `story/STORY_FORMAT.md`.

## Çalışma sırası

- [x] 1. Evren ve ana gizem: temel kararlar alındı (27.10.2026); ayrıntılar öneri, açık sorular 01'de.
- [ ] 2. Karakter dosyaları ve ilişki ağı.
- [ ] 3. Olayların gerçek kronolojisi.
- [ ] 4. Ana hikâyenin bölüm iskeleti.
- [ ] 5. Yan hikâyeler ve ahlaki ikilemler.
- [ ] 6. Dallanma ve sonuç sistemi (durumlar, finaller).
- [ ] 7. Telefon uygulamalarına dağıtım.
- [ ] 8. Sahne, sohbet ve belge yazımı (JSON).
- [ ] 9. Tutarlılık ve oynanabilirlik kontrolü.

Önce 1. adım bitmeli: hangi suçların gerçekten işlendiği ve arkasında kimin
olduğu bilinmeden yan hikâyeler kesinleştirilmez.

## Etiketler

Bu dosyalarda her bilginin durumu bellidir:

- **[KANON]** Oyunda şu an var olan içerik. Değiştirmek JSON'u da değiştirmek
  demektir.
- **[ÖNERİ]** Konuşulmuş ama kesinleşmemiş fikir.
- **[KARAR]** Kesinleşti; JSON'a geçirilebilir.
- **[?]** Henüz cevaplanmamış soru.

## Üç bilgi düzeyi

Polisiyenin tutarlı kalması için bunlar asla karıştırılmaz:

1. **Gerçek:** Oyunun evreninde gerçekten yaşananlar. Sadece burada yazılır.
2. **Karakterin inandığı:** Yanlış, eksik ya da manipüle edilmiş olabilir.
   Bir karakter, o an bilmediği bir şeyden bahsetmez.
3. **Oyuncunun öğrenebildiği:** Seçimlerine ve araştırmasına bağlıdır.
   Oyuncu bir yalanı hiç fark etmeyebilir, yanlış yorumlayabilir ya da
   yıllar önceki bir haberle karşılaştırarak çözebilir.

Bir tanık yalan söylüyorsa nedeni önceden burada yazılı olmalı.

## Tasarım ilkeleri

- Katili bulmak soruşturmayı bitirmez. Asıl zor karar, suçluyu bulduktan
  sonra onunla ne yapılacağıdır.
- Hikâye üç soruyu birlikte sorar: **Hukuki gerçek** (kim, nasıl, neden),
  **ahlaki gerçek** (maktul masum muydu, failin anlaşılabilir bir gerekçesi
  var mı), **kişisel gerçek** (oyuncu doğru için nelerden vazgeçer).
- Oyuncu her zaman kahraman değildir. Bir hayat kurtarmak için yaptığı ilk
  usulsüzlük, onu gizlemek için daha büyüklerine dönüşebilir; tersine
  umursamaz başlayan komiser fedakâr birine de dönüşebilir.
- Her seçeneğin mantıklı bir gerekçesi, bir kazancı ve bir bedeli olur.
  Bariz iyi/kötü seçenek yoktur, ama iyi kararlar bazen gerçekten işe yarar.
- Görevden uzaklaştırılmak ya da meslekten çıkarılmak oyun sonu değil, yeni
  bir oynanış biçimidir. Hiçbiri zorunlu da değildir: yasal yoldan ilerleyip
  görevini koruyan oyuncu da sona ulaşabilmeli.

### Kaçınılacaklar

- Her karakterin mutlaka cinayetle bağlantılı çıkması. Şehirdeki her olayın
  milletvekiline bağlanması yapay olur; bazı hikâyeler tamamen bağımsızdır.
- Seçimlerin sadece bir sonraki mesajı değiştirip unutulması.
- Her ahlaki ikilemin sonunda oyuncunun cezalandırılması.
- Oyuncunun hiç bilemeyeceği bilgiler yüzünden cezalandırılması.
- Yan görevlerin zorunlu olması. Yan görev yapılmazsa aynı bilgiye daha zor
  bir yoldan ulaşılabilmeli.
- Bir karakterle ilişkiyi bozmanın oyunu bitirilemez hâle getirmesi.

## Mekaniklerin oyundaki karşılığı

Tasarım belgelerinde geçen mekaniklerin şu anki durumu:

| Mekanik | Durum | Nasıl yazılır |
| --- | --- | --- |
| Dallanan sohbetler, sorgular | Var | chats.json |
| Kişilik özellikleri | Var | `traits`, koşullarda `trait:merhamet >= 3` |
| Karakter başına güven | Var | state.json `trust:<isim>`, `unlocks` ile `+=` / `-=` |
| Ekip güveni, baskı, dürüstlük, tanık tehlikesi | Var | state.json `stats` |
| Saha görevleri, subay gönderme | Var | map.json |
| Güvenen subaylardan yardım (uzaklaştırılınca) | Var | map.json koşullu `officers` |
| Laboratuvar mini oyunları | Var | evidence.json |
| Haber ve gazete arşivi araması | Var | news.json |
| Personel sicili, iç denetim kayıtları | Var | documents.json `category` |
| Erişim kaydı | Var | `unlocksOnView` |
| Banka transferleri, bakiye kaynağı | Var | bank.json `payees` |
| Görevden uzaklaştırma, uygulama kilidi | Var | state.json `locks`, `status:*` bayrakları |
| Süreli kararlar (oyun süresiyle) | Var | state.json `timers` |
| Çok katmanlı final | Var | endings.json |
| Anonim ihbar hattı | Kısmen | sms.json'da bilinmeyen numaradan koşullu mesaj |
| Avukat, gazeteci, eski meslektaş ile konuşma | Kısmen | Rehbere kişi ve chats.json'a sohbet ekle |
| Kamuoyu algısı | Kısmen | Bir sayı (`publicOpinion`) ve Gündem haberleri |
| Delil güvenilirliği, mahkemede kullanılabilirlik | Kısmen | Bayraklarla (`ev:<id>-tainted`) |
| Sesli arama ile yürüyen sahneler | Yok | Phone uygulamasında senaryolu arama |
| Silinen mesajların izleri | Yok | Bildirim geçmişi ya da ekran görüntüsü uygulaması |
| Gazeteciye haberi yayımlatma/erteletme | Kısmen | Gazeteci sohbeti + `press:*` bayrakları + koşullu haber |
