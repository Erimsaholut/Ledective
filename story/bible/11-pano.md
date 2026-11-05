# 11. Soruşturma panosu (01.11.2026)

Kullanıcının isteği: Pano sadece delilleri birbirine bağlamasın; şüphelilerin
fotoğrafları kırmızı iplerle gösterilsin, olaylar birbirine bağlansın,
şüpheli isimleri ve olayın arkasındaki büyük isim görünsün. İsimler
bilinmezken kartta **?** olsun. Pano büyük olduğu için sağa sola da
kaydırılabilsin.

İlk oyun testinden (05.11.2026): pano baştan tam boyutunda açılınca boş
alan ne kadar şey geleceğini ele veriyordu. Artık mantar tahta yalnızca
asılı kartları çevreliyor ve yeni kart geldikçe genişliyor; "OLAY GECESİ"
etiketi de ilk saat bulununca çıkıyor.

Panonun düzeni ve hangi kartın ne zaman asıldığı **[Taslak]**. Bütün
koşullar `assets/story/board.json`'da; tablo hâli `story/HIKAYE_SEMASI.md`
› Pano. Dosya biçimi `story/STORY_FORMAT.md` › board.json.

## Düzen [Taslak]

| Bölge | Kartlar | Etiket ne zaman çıkar |
| --- | --- | --- |
| Tepede: EMRİ VEREN | Milletvekili Haluk Yılmaz, altında **?** (sonra Halit Yener), yanında kaymakam ve 250.000 TL notu | Plaka, mezbaha ya da para |
| Sol: ŞÜPHELİLER | Adil, Kerem, Furkan; defter, yanık harita, yırtık fotoğraf | `part1Done` |
| Orta: MAKTUL | Berat; bardak, kamera karesi, olay yeri, telefonu | Baştan |
| Sağ üst: TANIKLAR | Deniz, Yusuf | `part1Done` |
| Sağ: MEZBAHA, KAYIPLAR | Duvardaki fotoğraflar, sandalye, kayıp ilanları; Melis, Emre, Hakan; Ece ve sözleşmesi | `mezbaha-found` |
| Alt: OLAY GECESİ | 23.40'tan "+2 gün"e yedi saat kartı, siyah bir iple bağlı | İlk saat bulununca; ip bulunan saatler arasında, boş çentikler aradaki bulunmamış anları gösterir |

## Soru işaretleri [Taslak]

| Kart | Önce | Adı ne zaman açılır |
| --- | --- | --- |
| Adil Karaca | "“ADİL ABİ”: Berat o gece kime yalvardı?" | Parmak izi ya da Furkan'ın ifadesi |
| Kerem Aydın | "?: Deri ceketli adam" | `heard:kerem` |
| Halit Yener | "?: Mezbahanın arkasında kim var?" | `heard:danisman` |
| Ece Aydın | "?: Takipsizlikle kapanan ölüm" | `heard:ece` |
| Melis, Emre | Kayıp ilanındaki yüz, adı yok | Kerem'le buluşma / Melis'in ifadesi ya da çiftlik |
| Hakan Demir | "?: Hastanede Emre'yi soran yabancı" | `heard:hakan` |
| 02.05 kartı | "Kapıyı biri çalar mı?" | Kerem'in itirafı |
| Sızıntı notu | "Basına kim sızdırıyor?" | `leak:traced`: "komiserin kendi numarası" |
| Tanık notu | "Hat üç yıl önce ölmüş bir kadına kayıtlı" | `heard:ece` |

Baba ve Berat baştan asılı. Babanın vakıfla ve örtbasla bağını ipler
sonradan kurar: Yener'e "danışmanı" (`heard:danisman`), Ece'ye "örtbas
ettirdi" (`heard:mp-tape`).

## Damgalar [Taslak]

Kartların üstünde kırmızı damga, durum değiştikçe değişir: Berat
"İNTİHAR?" → "CİNAYET"; Adil "ARANIYOR" / "YAKALANDI" / "ÖLDÜ"; Kerem
"ŞÜPHELİ" / "İTİRAF ETTİ" / "GÖZALTINDA" / "SAVCILIKLA ANLAŞTI" / "KAÇTI";
Furkan "GÖZALTINDA" / "SERBEST" / "KAYIP"; Melis "KURTARILDI" / "ÖLÜ
BULUNDU"; para notu "KISMEN İADE" / "İADE EDİLDİ"; Yener "KAÇTI" /
"OPERASYON".

## Laboratuvar sonuçları panoda

10-oyun-testi.md'deki "[?] hangi lab sonuçları hikâyeye bağlansın"
sorusunun ilk adımı: yedi yeni oyunun beşinin sonucu kişinin dosya notlarına
düşüyor (luminol ve telefon Berat'a, kamera Kerem'e, lastik izi Yener'e,
duvar fotoğrafları kayıplara). Hikâyenin gidişini hâlâ değiştirmiyorlar.

## Açık sorular

- [?] Gizli son: bozulma sırasında pano da dağılsın mı (ör. iplerin hepsi
  komiserin kartına bağlansın, ya da kartlarda hep aynı yüz)? Panoda şu an
  komiserin kartı yok.
- [?] Oyuncu kendi ipini çekebilsin mi (iki kartı bağlayıp "bunlar ilişkili"
  demek, doğruysa bir şey açılsın)? Şimdilik ipleri hikâye çekiyor.
- [?] Eksik portreler: Adil, Yener, Furkan, Deniz, Yusuf, Ece, Hakan,
  kaymakam şimdilik siluet. Liste `story/GORSELLER.md` › 6.
