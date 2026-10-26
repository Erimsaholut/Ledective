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
  story/               Sohbet motoru (dialogue.dart), hikâye metinleri
                       (conversations.dart) ve kayıtlı ilerleme
                       (story_progress.dart)
  data/                Kalıcı oyun durumu (rehber, notlar, son aramalar,
                       ilk açılış tarihi, duvar kâğıdı) ve sabit
                       oyun içeriği (mailler, galeri)
  widgets/             Ortak arayüz parçaları (avatar, sohbet balonu,
                       iOS tarzı gruplu liste)
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

Bir düğüm `waitFor` ile bir hikâye bayrağını bekleyebilir; bayrağı bir
seçeneğin `unlocks` listesi açar. Böylece bir kişi, başka bir sohbette bir
noktaya gelinince yazmaya başlar. Poltel belgeleri, hikâye mailleri ve
SMS'ler de aynı bayraklarla açılır. `traits` kişilik puanı ekler, `silent`
seçenek mesaj göndermez ("(Cevap verme)"), `testimony` ise sorgu
cevaplarını ifade tutanağına yazar.

Oyuncunun seçimleri cihazda saklanır; sohbet yeniden açıldığında kaldığı
yerden devam eder. `test/story_test.dart` her düğümün erişilebilir olduğunu
ve her `next` bağlantısının var olan bir düğüme gittiğini, beklenen her
bayrağın bir yerde açıldığını ve hikâyenin baştan sona oynanabildiğini
kontrol eder.

Oyunu baştan başlatmak için: **Settings → Reset Game Progress**.
