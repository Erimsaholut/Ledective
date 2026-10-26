# Ledective

Bir telefonun içinde geçen dedektif oyunu. Oyuncu, izindeyken ekibinden
gelen mesajlarla bir cinayet davasının içine çekilen bir komiseri oynar;
ipuçları telefonun uygulamalarına (MatesApp sohbetleri, Poltel ifade
tutanakları ve otopsi raporu, notlar, mailler, fotoğraflar) dağılmıştır.
Hikâyenin taslağı `story/Hikaye.pdf` dosyasındadır.

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
  home/                Ana ekran ve uygulama simgeleri
  apps/<uygulama>/     Telefondaki her uygulama ayrı bir klasörde
  story/               Sohbet motoru (dialogue.dart) ve hikâye metinleri
                       (conversations.dart)
  data/                Kalıcı oyun durumu (rehber, notlar, son aramalar,
                       ilk açılış tarihi, ana ekran renkleri) ve sabit
                       oyun içeriği (mailler, galeri)
  widgets/             Ortak arayüz parçaları
assets/                Görseller, sesler ve JSON verileri
test/                  Birim ve widget testleri
```

## Hikâyeye sohbet eklemek

MatesApp sohbetleri `lib/story/conversations.dart` içinde veri olarak
tanımlanır. Her kişinin bir geçmişi (`history`) ve isteğe bağlı bir diyaloğu
(`dialogue`) vardır. Diyalog, kimliklerle birbirine bağlanan düğümlerden
oluşur:

```dart
"start": DialogueNode([
  DialogueOption(
    label: "Klavyede görünen metin",
    message: "Gönderilen mesaj (verilmezse label kullanılır)",
    replies: ["Karşı tarafın yanıtları, sırayla gelir"],
    next: "sonrakiDugum", // null ise sohbet biter
  ),
]),
```

Oyuncunun seçimleri cihazda saklanır; sohbet yeniden açıldığında kaldığı
yerden devam eder. `test/story_test.dart` her düğümün erişilebilir olduğunu
ve her `next` bağlantısının var olan bir düğüme gittiğini kontrol eder.

Oyunu baştan başlatmak için: **Settings → Reset Game Progress**.
