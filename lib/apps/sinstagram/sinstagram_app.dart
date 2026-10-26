import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Post {
  const Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.likes,
    this.image,
    this.daysAgo = 1,
    this.comments = const [],
  });

  final String id;
  final String author;
  final String caption;
  final int likes;

  /// Asset path, or null for a text-only post.
  final String? image;
  final int daysAgo;
  final List<({String author, String text})> comments;
}

const String _images = 'assets/apps/photosApp/images';

const List<Post> posts = [
  Post(
    id: 'berat-cafe',
    author: 'berat.ylmz',
    caption: "Okulun karşısındaki kafe, her zamanki yer ☕",
    likes: 23,
    daysAgo: 4,
    comments: [
      (author: 'furkan.shn', text: "abi bu akşam yine orda mısın"),
      (author: 'adil.abi', text: "borçlar ödenmeden kahve içilmez 😉"),
      (author: 'deniz.yilmaz', text: "Kuzen bi ara arasana"),
    ],
  ),
  Post(
    id: 'orhun-beer',
    author: 'orhun.k',
    image: '$_images/kadr.jpeg',
    caption: "Akşam iki bira kimde? 🍺",
    likes: 41,
    comments: [
      (author: 'atakan.kutay', text: "ben varım amirim"),
      (author: 'ozge.buro', text: "😂😂"),
    ],
  ),
  Post(
    id: 'ozge-cat',
    author: 'ozge.buro',
    image: '$_images/benKedi.jpeg',
    caption: "Pamuk bugün de mesaide 🐱",
    likes: 128,
    daysAgo: 2,
    comments: [(author: 'doga.aksu', text: "Büronun maskotu olsun!")],
  ),
  Post(
    id: 'atakan-gadget',
    author: 'atakan.kutay',
    image: '$_images/aaa.jpg',
    caption: "Amirimiz işbaşında 😂",
    likes: 67,
    daysAgo: 3,
    comments: [(author: 'inanc.k', text: "Görmesin sakın")],
  ),
  Post(
    id: 'behram-op',
    author: 'behram_narkotik',
    image: '$_images/gungun.jpeg',
    caption: "Bu haftaki operasyondan. Şehrimiz daha güvenli.",
    likes: 312,
    daysAgo: 5,
  ),
  Post(
    id: 'berat-dad',
    author: 'berat.ylmz',
    image: '$_images/babba.jpeg',
    caption: "Babam bir milletvekili ama ben kendi yolumu çizerim.",
    likes: 54,
    daysAgo: 9,
    comments: [(author: 'yusuf.kasap', text: "Kral 👑")],
  ),
  Post(
    id: 'me-holiday',
    author: 'komiser',
    image: '$_images/my_foto4.jpg',
    caption: "Tatildeyim, aramayın 🌴",
    likes: 89,
    daysAgo: 7,
    comments: [
      (author: 'erdi.mudur', text: "İzin dilekçen hâlâ masamda değil."),
    ],
  ),
  Post(
    id: 'secret-history',
    author: 'gizli.tarih',
    image: '$_images/freeMason.jpg',
    caption: "Bilinmeyenler... 🔺 #komplo",
    likes: 1024,
    daysAgo: 12,
  ),
];

class Sinstagram extends StatefulWidget {
  const Sinstagram({super.key});

  @override
  State<Sinstagram> createState() => _SinstagramState();
}

class _SinstagramState extends State<Sinstagram> {
  static const _prefsKey = 'sinstagramLikes';

  Set<String> _liked = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() => _liked = {...?prefs.getStringList(_prefsKey)});
    });
  }

  Future<void> _toggleLike(Post post) async {
    setState(() {
      if (!_liked.remove(post.id)) _liked.add(post.id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _liked.toList());
  }

  void _showComments(Post post) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Yorumlar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (post.comments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text("Henüz yorum yok", textAlign: TextAlign.center),
              ),
            for (final comment in post.comments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  comment.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(comment.text),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sinstagram"),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blue.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final liked = _liked.contains(post.id);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    post.author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${post.daysAgo} gün önce"),
                ),
                if (post.image case final image?)
                  GestureDetector(
                    onDoubleTap: () => _toggleLike(post),
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    color: Colors.blueGrey.shade700,
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      post.caption,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      tooltip: liked ? "Beğenmekten vazgeç" : "Beğen",
                      onPressed: () => _toggleLike(post),
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : null,
                      ),
                    ),
                    IconButton(
                      tooltip: "Yorumlar",
                      onPressed: () => _showComments(post),
                      icon: const Icon(Icons.mode_comment_outlined),
                    ),
                    Text("${post.likes + (liked ? 1 : 0)} beğenme"),
                  ],
                ),
                if (post.image != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${post.author} ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: post.caption),
                        ],
                      ),
                    ),
                  ),
                if (post.comments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: GestureDetector(
                      onTap: () => _showComments(post),
                      child: Text(
                        "${post.comments.length} yorumun tümünü gör",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
