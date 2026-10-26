import '../story/story_flags.dart';

class Mail {
  const Mail({required this.sender, required this.body, this.requires});

  final String sender;
  final String body;

  /// Story flag after which the mail arrives. Mails without one arrive one
  /// by one when the player checks for new mail.
  final String? requires;

  String get id => '$sender|$body';
}

/// Mails the story sends when the player reaches a point in the case.
const List<Mail> storyMails = [
  Mail(
    sender: "emniyet.gov.tr",
    requires: StoryFlags.part1Done,
    body:
        "İl Emniyet Müdürlüğü: Berat Yılmaz dosyası tüm birimlerin önceliğidir. Gelişmeler günlük olarak şube müdürlüğüne raporlanacaktır.",
  ),
  Mail(
    sender: "narkotik.emniyet.gov.tr",
    requires: StoryFlags.furkanStatement,
    body:
        "Adil Karaca (lakabı \"Adil abi\") hakkında açık soruşturma dosyası mevcuttur. Bilgi paylaşımı için Narkotik Büro Başkomiseri Behram ile irtibata geçiniz.",
  ),
];

const List<Mail> mails = [
  Mail(sender: "emniyet.gov.tr", body: "Konferansa davetlisiniz !"),
  Mail(
    sender: "zaferbank.com",
    body:
        "Paranızı tanımdağınız milyonlarca kişi ile paylaştığınızın farkında mısınız ?",
  ),
  Mail(
    sender: "besiktas.com",
    body: "Yeni sezon formalarda indirim. Sakın kaçırmayın",
  ),
  Mail(sender: "kargo.com.tr", body: "Kargonuz dağıtıma çıktı. Adresinizde bulunamadığınız için şubemizde bekletilecektir."),
  Mail(
    sender: "havayolu.com.tr",
    body: "Dönüş uçuşunuz için online check-in açılmıştır. İyi yolculuklar dileriz.",
  ),
  Mail(
    sender: "github.com",
    body:
        "Github aktivasyon kodunuz Æ!>2A4@@X?3_ß4523 girmek için 10 saniyeniz var !!!",
  ),
  Mail(
    sender: "cbu.com",
    body:
        "Tebrikler sınıfınızın %10 kontenjanına girdiğiniz için bu sene harç ücretiniz %75 indirimli.",
  ),
];

const String _photosDir = 'assets/apps/photosApp/images';

const List<String> galleryImages = [
  '$_photosDir/1500x500.jpeg',
  '$_photosDir/my_foto2.jpg',
  '$_photosDir/my_foto4.jpg',
  '$_photosDir/myCat.jpeg',
  '$_photosDir/kadr.jpeg',
  '$_photosDir/kadr2.jpeg',
  '$_photosDir/benKedi.jpeg',
  '$_photosDir/my_foto1.jpg',
  '$_photosDir/gungun.jpeg',
  '$_photosDir/babba.jpeg',
];
