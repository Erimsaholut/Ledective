# Ledective

Bir telefonun içinde geçen dedektif oyunu. Oyuncu, izindeyken ekibinden
gelen mesajlarla bir cinayet davasının içine çekilen bir komiseri oynar;
ipuçları telefonun uygulamalarına (MatesApp sohbetleri, Poltel ifade
tutanakları ve otopsi raporu, notlar, mailler, fotoğraflar) dağılmıştır.
Hikâyenin taslağı `story/Hikaye.pdf` dosyasındadır.

## Hikâyenin akışı

1. **Kısım 1 – Özge:** Oyun Özge'nin mesajıyla başlar. Sohbet bittiğinde
   Poltel'e Yusuf Kasap ve Deniz Yılmaz'ın ifadeleri ile otopsi raporu
   düşer.
2. **Kısım 2 – Orhun, Erdi, İnanç:** Orhun ve şube müdürü Erdi yazar.
   Orhun'la konuştuktan sonra İnanç'a sorgu talimatı verilebilir.
3. **Sorgu – Doğa:** Furkan'a sorulacak soruları oyuncu seçer. Seçilen
   sorular ve cevaplar Poltel'deki Furkan Şahin ifade tutanağını oluşturur.
4. **Kısım 3'e hazırlık:** Behram, Narkotik'in Adil dosyasından bahseder;
   Mail ve Messages'a yeni ipuçları gelir.

Ana hikâye sohbetlerle ilerler; aradaki her şeyi oyuncu kendisi keşfeder:

- **Harita:** Bilinen mekânlara ekipten birini gönder. Görev gerçek zamanlı
  sürer, rapor gelince yeni deliller, mekânlar ve ipuçları açılabilir.
- **Delil Panosu:** Bulunan deliller panoya asılır, ilgili olanlar kırmızı
  iple bağlanır. Deliller **Poltel → Laboratuvar**'da incelenir: yırtık
  fotoğraf ve harita birleştirme, parmak izi eşleştirme, UV ışıkla gizli
  yazı bulma.
- **Sinstagram araması:** Şüphelilerin hesapları akışta görünmez; adlarını
  öğrenince arayarak ya da bir yorumdaki kullanıcı adına dokunarak bulunur.
- **ZaferBank**, **Kayıtlar** (sesli mesajlar) ve **Mail / Messages** da
  hikâye ilerledikçe yeni şeyler alır. Yeni bir şey geldiğinde ekranın
  üstünde bildirim çıkar.

Her seçim dedektifin kişiliğine puan ekler (Öfke, Merhamet, Merak, Cesur,
Umursamaz, Temkinli). Puanlar **Settings → Detective Profile** ekranında
görünür.

## Çalıştırma

Flutter 3.35 veya daha yenisi gerekir.

```bash
flutter pub get
flutter run
```

Testler ve statik analiz:

```bash
flutter test
flutter analyze
```

## Proje yapısı

```
lib/
  main.dart            Uygulama girişi, kayıtlı oyun durumunu yükler
  home/                Ana ekran, uygulama simgeleri ve ana ekran çubuğu
  theme/               Tema, renkler ve Türkçe tarih biçimleri
  apps/<uygulama>/     Telefondaki her uygulama ayrı bir klasörde
  story/               Sohbet motoru (dialogue.dart), JSON okuyucu
                       (story_data.dart), doğrulayıcı (story_validator.dart)
                       ve kayıtlı ilerleme (story_progress.dart)
  data/                Kalıcı oyun durumu (rehber, notlar, son aramalar,
                       ilk açılış tarihi, duvar kâğıdı) ve sabit
                       oyun içeriği (mailler, galeri)
  widgets/             Ortak arayüz parçaları (avatar, sohbet balonu,
                       iOS tarzı gruplu liste)
assets/story/          Hikâye içeriği (JSON) ve hikâye görselleri
assets/                Diğer görseller, sesler ve JSON verileri
tool/                  Hikâye doğrulama aracı
test/                  Birim ve widget testleri
```

## Hikâyeyi yazmak

Bütün hikâye içeriği `assets/story/*.json` dosyalarındadır; kod değiştirmeden
düzenlenebilir. Biçim ve örnekler: [`story/STORY_FORMAT.md`](story/STORY_FORMAT.md).

```bash
dart run tool/validate_story.dart          # hataları kontrol et
dart run tool/validate_story.dart --graph  # sohbet şemalarını çiz
```

Denerken **Settings → Hızlı görevler** harita görevlerini hızlandırır.

## Sohbet düğümleri

Sohbetler, kimliklerle birbirine bağlanan düğümlerden oluşur (`chats.json`).
Bir düğüm `waitFor` ile bir hikâye bayrağını bekleyebilir; bayrağı bir
sohbet seçeneği, harita görevi, laboratuvar incelemesi ya da açılan bir
Sinstagram profili açar. Ayrıntılar format rehberinde.

Oyuncunun ilerlemesi cihazda saklanır. `test/story_test.dart` doğrulayıcıyı
çalıştırır ve hikâyenin baştan sona oynanabildiğini kontrol eder.

Oyunu baştan başlatmak için: **Settings → Reset Game Progress**.
