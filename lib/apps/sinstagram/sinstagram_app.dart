import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/avatar.dart';

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

/// The feed only shows the bureau and strangers. Suspects get their own
/// profiles later in the story, found through search.
const List<Post> posts = [
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
    id: 'cat-world',
    author: 'kedi.dunyasi',
    image: '$_images/myCat.jpeg',
    caption: "Pazartesi sendromu bu sabah böyle görünüyor 😾",
    likes: 2310,
    daysAgo: 2,
    comments: [(author: 'ozge.buro', text: "Pamuk'un kuzeni gibi 😍")],
  ),
  Post(
    id: 'series-quotes',
    author: 'dizi.replikleri',
    image: '$_images/my_foto1.jpg',
    caption: "Ankara'nın en karizmatik komiseri. Katılmayan? #behzatç",
    likes: 5874,
    daysAgo: 6,
    comments: [
      (author: 'orhun.k', text: "Amirime benziyor bence"),
      (author: 'komiser', text: "@orhun.k mesaiye dön"),
    ],
  ),
  Post(
    id: 'art-gallery',
    author: 'sanat.galerisi',
    image: '$_images/1500x500.jpeg',
    caption: "Bu hafta sonu sergimiz ziyaretçilerini bekliyor. Giriş ücretsiz.",
    likes: 418,
    daysAgo: 8,
  ),
  Post(
    id: 'detective-memes',
    author: 'dedektif.memes',
    image: '$_images/my_foto5.jpg',
    caption: "Tatildeyken bile ipucu arayan polis olmak 🔍",
    likes: 9120,
    daysAgo: 10,
    comments: [(author: 'atakan.kutay', text: "Amirim bu siz 😂")],
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

  static const _ring = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFFFEDA75),
      Color(0xFFFA7E1E),
      Color(0xFFD62976),
      Color(0xFF962FBF),
    ],
  );

  Widget _storyAvatar(String name, {double radius = 30}) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _ring),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Avatar(name: name, radius: radius),
      ),
    );
  }

  Widget _buildPost(Post post) {
    final liked = _liked.contains(post.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              _storyAvatar(post.author, radius: 15),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  post.author,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.more_horiz_rounded),
              const SizedBox(width: 8),
            ],
          ),
        ),
        if (post.image case final image?)
          GestureDetector(
            onDoubleTap: () => _toggleLike(post),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          )
        else
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3A1C71),
                    Color(0xFFD76D77),
                    Color(0xFFFFAF7B),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    post.caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Row(
          children: [
            IconButton(
              tooltip: liked ? "Beğenmekten vazgeç" : "Beğen",
              onPressed: () => _toggleLike(post),
              icon: Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: liked ? const Color(0xFFED4956) : null,
                size: 28,
              ),
            ),
            IconButton(
              tooltip: "Yorumlar",
              onPressed: () => _showComments(post),
              icon: const Icon(Icons.mode_comment_outlined, size: 26),
            ),
            const Icon(Icons.send_outlined, size: 26),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.bookmark_border_rounded, size: 28),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${post.likes + (liked ? 1 : 0)} beğenme",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (post.image != null) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${post.author} ",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
              ],
              if (post.comments.isNotEmpty)
                GestureDetector(
                  onTap: () => _showComments(post),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "${post.comments.length} yorumun tümünü gör",
                      style: const TextStyle(color: Color(0xFF8E8E8E)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  "${post.daysAgo} gün önce",
                  style: const TextStyle(
                    color: Color(0xFF8E8E8E),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authors = {for (final post in posts) post.author}.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Sinstagram",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
          ),
        ),
        actions: const [
          Icon(Icons.favorite_border_rounded),
          SizedBox(width: 16),
          Icon(Icons.send_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 104,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final author in authors)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _storyAvatar(author),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 70,
                          child: Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          for (final post in posts) _buildPost(post),
        ],
      ),
    );
  }
}
