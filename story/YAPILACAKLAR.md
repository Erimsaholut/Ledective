# Yapılacaklar

Bitenleri işaretle (`[x]`), yeni işleri ekle. Hikâye kararları
[`bible/`](bible/README.md) klasöründe, oyundaki hali
[`HIKAYE_SEMASI.md`](HIKAYE_SEMASI.md) tablosunda.

## Görseller

- [ ] Test görsellerini değiştir: listesi ve tarifleri [`GORSELLER.md`](GORSELLER.md).
- [ ] Telif sorunlu görselleri kaldır (dizi ve film kareleri, gerçek kişiler).
  Oyun herkese açık yayımlanmadan önce bitmeli.
- [ ] Kişi profil fotoğrafları için kodu hazırla: şu an sohbetlerde ve
  Sinstagram'da baş harfli renkli daireler var (`widgets/avatar.dart`).

## Ana gizem: oyuna geçirilecekler

Gerçek kesinleşti (`bible/01-ana-gizem.md`); oyunda henüz yok:

- [ ] **Kerem'e ulaşma yolları.** En az ikisi, birbirinden bağımsız:
  - [ ] Vakfın gönüllü listesi (Harita görevi: vakıf binası)
  - [ ] Kafe kamerasındaki kart (netleştirilmiş görüntü: Atakan'ın teknik birimi)
  - [ ] Yırtık fotoğraf ile kamera karesindeki adamın aynı kişi olduğu
  - [ ] Ece'nin eski hattı (Özge'nin sorgusu: "üç yıl önce ölmüş bir kadın")
  - [ ] Sinstagram'da Ece'nin eski hesabı ve Kerem'in yorumları
- [ ] **Berat'ın kanıtları.** Telefonu Kerem'de; oyuncu bunu nasıl öğrenir,
  kanıtlara nasıl ulaşır?
- [ ] **Kerem'le yüzleşme ve İkilem 2.** Gözaltı, savcıyla iş birliği ya da kaçmasına
  göz yumup kayıpların yerini öğrenmek.
- [ ] **Kayıp öğrenci (hayatta olan) ve İkilem 5.**
- [ ] **Furkan "sıradaki" mi?** Mezbahadaki ileri tarihin Furkan'a bağlanması.
- [ ] **Vakıf ve danışman.** Burs sözleşmesi, burs listesi; danışmanın adı ve
  rolü.

## Açık sorular (önce karar)

- [ ] Erdi neyi biliyor, kimden emir alıyor?
- [ ] Kaymakamın vakıfla bağı ne?
- [ ] Behram'ın sırrı: "Adil bir zamanlar muhbirdi." Narkotik bu ağı biliyor muydu?
- [ ] Basına kim sızdırıyor? (Adaylar: Atakan, Orhun, kaymakam/milletvekili
  çevresi, Erdi, komiserin kendisi.)
- [ ] Adil'in deposundaki listede geçen "H.Y." kim?
- [ ] Hakan Demir'in hedefi kim? (Berat'ın katili artık o değil.)
- [ ] Gizli son ("hiç yurt dışında değildi") diğer finallerle nasıl birleşir?

## Sistemler

- [ ] **Gizli son için şüphe sayısı.** `doubt` sayısı; iki türlü okunabilen her
  ipucu artırsın; finalde yeterliyse son bir seçenek çıksın.
- [ ] **Görevden uzaklaştırma kilidi.** Poltel kilitlenince laboratuvar da
  kapanıyor. Ya laboratuvar ayrı bir uygulama olsun ya da kilitliyken
  bekleyen incelemeler başka yoldan çözülsün.
- [ ] **Rüşvet ikileminin eksik seçenekleri.** Savcılığa bildirmek, göndericiyi
  araştırmak.
- [ ] **Senaryolu telefon aramaları.** Avukat, gazeteci, tanık (Phone uygulaması).
- [ ] **Silinen mesaj izleri.**

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
