class Mail {
  const Mail({required this.sender, required this.body});

  final String sender;
  final String body;
}

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
