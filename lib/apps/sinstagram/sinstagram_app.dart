import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';

/// Lower-cases and strips Turkish letters, so "ozge" finds "Özge".
String searchKey(String text) {
  const map = {'ı': 'i', 'ş': 's', 'ç': 'c', 'ğ': 'g', 'ö': 'o', 'ü': 'u'};
  final lower = text.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
  return lower.split('').map((c) => map[c] ?? c).join();
}

/// Feed authors become browsable profiles too.
List<Profile> _feedProfiles() {
  final byAuthor = <String, List<Post>>{};
  for (final post in StoryData.current.feed) {
    (byAuthor[post.author] ??= []).add(post);
  }
  return [
    for (final MapEntry(key: handle, value: posts) in byAuthor.entries)
      Profile(handle: handle, name: handle, posts: posts),
  ];
}

/// Any profile by [handle], whether or not search can find it yet.
Profile? findProfile(String handle) {
  for (final profile in [...StoryData.current.profiles, ..._feedProfiles()]) {
    if (profile.handle == handle) return profile;
  }
  return null;
}

/// Profiles search can find right now.
List<Profile> searchProfiles(String query, StoryProgress progress) {
  final key = searchKey(query.trim());
  if (key.length < 2) return const [];
  return [
    for (final profile in [...StoryData.current.profiles, ..._feedProfiles()])
      if (progress.meets(profile.requires) &&
          (searchKey(profile.handle).contains(key) ||
              searchKey(profile.name).contains(key)))
        profile,
  ];
}

/// Likes, shared by every Sinstagram screen.
class _Likes extends ChangeNotifier {
  static const _prefsKey = 'sinstagramLikes';
  static final instance = _Likes();

  Set<String> _liked = {};

  bool isLiked(Post post) => _liked.contains(post.id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _liked = {...?prefs.getStringList(_prefsKey)};
    notifyListeners();
  }

  Future<void> toggle(Post post) async {
    if (!_liked.remove(post.id)) _liked.add(post.id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _liked.toList());
  }
}

class Sinstagram extends StatefulWidget {
  const Sinstagram({super.key});

  @override
  State<Sinstagram> createState() => _SinstagramState();
}

class _SinstagramState extends State<Sinstagram> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _Likes.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _tab,
        children: const [_FeedPage(), _SearchPage()],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.manage_search_rounded),
            label: 'Ara',
          ),
        ],
      ),
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage();

  @override
  Widget build(BuildContext context) {
    final feed = StoryData.current.feed;
    final authors = {for (final post in feed) post.author}.toList();
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
                  GestureDetector(
                    onTap: () => openProfile(context, author),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StoryAvatar(name: author),
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
                  ),
              ],
            ),
          ),
          const Divider(),
          for (final post in feed) PostView(post: post),
        ],
      ),
    );
  }
}

class _SearchPage extends StatefulWidget {
  const _SearchPage();

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = searchProfiles(_query, StoryProgress.instance);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        title: TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: "Ara",
            prefixIcon: Icon(Icons.search_rounded),
            isDense: true,
          ),
        ),
      ),
      body: _query.trim().length < 2
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Bir kullanıcı adı ya da isim ara.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondaryLabel),
                ),
              ),
            )
          : results.isEmpty
          ? const Center(
              child: Text(
                "Sonuç bulunamadı",
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
            )
          : ListView(
              children: [
                for (final profile in results)
                  ListTile(
                    tileColor: Colors.white,
                    leading: Avatar(name: profile.handle),
                    title: Text(
                      profile.handle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(profile.name),
                    onTap: () => openProfile(context, profile.handle),
                  ),
              ],
            ),
    );
  }
}

/// Opens [handle]'s profile, or says it doesn't exist. Tapping a name in a
/// comment works even before search can find the account: the player found
/// the trail themselves.
void openProfile(BuildContext context, String handle) {
  final profile = findProfile(handle);
  if (profile == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("@$handle bulunamadı")));
    return;
  }
  StoryProgress.instance.discover(profile.unlocksOnView);
  Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => ProfilePage(profile: profile)),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    Widget stat(int value, String label) => Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profile.private)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.lock_outline_rounded, size: 18),
              ),
            Text(profile.handle),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                StoryAvatar(name: profile.handle, radius: 40),
                stat(profile.posts.length, "gönderi"),
                stat(profile.followers, "takipçi"),
                stat(profile.following, "takip"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (profile.bio.isNotEmpty) Text(profile.bio),
              ],
            ),
          ),
          const Divider(),
          if (profile.private)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 56),
                  SizedBox(height: 12),
                  Text(
                    "Bu hesap gizli",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Fotoğraflarını görmek için takip et.",
                    style: TextStyle(color: AppColors.secondaryLabel),
                  ),
                ],
              ),
            )
          else if (profile.posts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                "Henüz gönderi yok",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
            )
          else
            for (final post in profile.posts) PostView(post: post),
        ],
      ),
    );
  }
}

const _ring = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: [
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFFD62976),
    Color(0xFF962FBF),
  ],
);

class StoryAvatar extends StatelessWidget {
  const StoryAvatar({super.key, required this.name, this.radius = 30});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
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
}

class PostView extends StatelessWidget {
  const PostView({super.key, required this.post});

  final Post post;

  void _showComments(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
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
                leading: Avatar(name: comment.author, radius: 18),
                title: Text(
                  comment.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(comment.text),
                onTap: () {
                  Navigator.pop(sheetContext);
                  openProfile(context, comment.author);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _Likes.instance,
      builder: (context, _) {
        final liked = _Likes.instance.isLiked(post);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: GestureDetector(
                onTap: () => openProfile(context, post.author),
                child: Row(
                  children: [
                    StoryAvatar(name: post.author, radius: 15),
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
            ),
            if (post.image case final image?)
              GestureDetector(
                onDoubleTap: () => _Likes.instance.toggle(post),
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
                  onPressed: () => _Likes.instance.toggle(post),
                  icon: Icon(
                    liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: liked ? const Color(0xFFED4956) : null,
                    size: 28,
                  ),
                ),
                IconButton(
                  tooltip: "Yorumlar",
                  onPressed: () => _showComments(context),
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
                      onTap: () => _showComments(context),
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
      },
    );
  }
}
