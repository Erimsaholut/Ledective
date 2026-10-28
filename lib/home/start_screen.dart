import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../apps/bank/bank_app.dart';
import '../apps/board/board_app.dart';
import '../apps/calendar/calendar_app.dart';
import '../apps/camera/camera_app.dart';
import '../apps/clock/clock_app.dart';
import '../apps/contacts/contacts_app.dart';
import '../apps/games/games_app.dart';
import '../apps/mail/mail_app.dart';
import '../apps/map/map_app.dart';
import '../apps/mates/chat_page.dart';
import '../apps/mates/mates_app.dart';
import '../apps/messages/messages_app.dart';
import '../apps/music/music_app.dart';
import '../apps/news/news_app.dart';
import '../apps/notes/notes_app.dart';
import '../apps/phone/phone_app.dart';
import '../apps/photos/photos_app.dart';
import '../apps/pian/pian_app.dart';
import '../apps/poltel/poltel_app.dart';
import '../apps/recordings/recordings_app.dart';
import '../apps/settings/settings_app.dart';
import '../apps/shopper/shopper_app.dart';
import '../apps/sinstagram/sinstagram_app.dart';
import '../apps/unavailable/unavailable_app.dart';
import '../data/contacts_repository.dart';
import '../data/wallpaper.dart';
import '../story/story_progress.dart';
import '../theme/turkish_dates.dart';
import 'app_icon.dart';

int _chatsToCheck(StoryProgress progress) => progress.chatsNeedingAttention;

const List<List<AppIcon>> _pages = [
  [
    AppIcon(
      title: "Mail",
      app: MailApp(),
      iconData: Icons.mail_rounded,
      colors: [Color(0xFF3FA9FF), Color(0xFF0A6CFF)],
      badgeCount: unreadMailCount,
    ),
    AppIcon(title: "Photos", app: PhotosApp(), artwork: photosArtwork),
    AppIcon(
      title: "Camera",
      app: CameraApp(),
      iconData: Icons.camera_alt_rounded,
      colors: [Color(0xFFD1D1D6), Color(0xFF8E8E93)],
      glyphColor: Color(0xFF2C2C2E),
    ),
    AppIcon(title: "Calendar", app: CalendarApp(), artwork: calendarArtwork),
    AppIcon(title: "Clock", app: ClockApp(), artwork: clockArtwork),
    AppIcon(
      title: "Poltel",
      app: Poltel(),
      iconData: Icons.local_police_rounded,
      colors: [Color(0xFF2B4C8C), Color(0xFF0B1F4D)],
      badgeCount: newDocumentCount,
    ),
    AppIcon(
      title: "Harita",
      app: MapApp(),
      iconData: Icons.map_rounded,
      colors: [Color(0xFF7ED957), Color(0xFF2E9E5B)],
      badgeCount: unreadReportCount,
    ),
    AppIcon(
      title: "Pano",
      app: BoardApp(),
      iconData: Icons.push_pin_rounded,
      colors: [Color(0xFFC8955F), Color(0xFF8A5A2F)],
      badgeCount: newEvidenceCount,
    ),
    AppIcon(
      title: "Notes",
      app: NotesApp(),
      iconData: Icons.edit_note_rounded,
      colors: [Color(0xFFFFE066), Color(0xFFFFC300)],
      glyphColor: Color(0xFF5C4A00),
    ),
    AppIcon(
      title: "Sinstagram",
      app: Sinstagram(),
      iconData: Icons.camera_outlined,
      colors: [Color(0xFF833AB4), Color(0xFFE1306C), Color(0xFFF77737)],
    ),
    AppIcon(
      title: "ZaferBank",
      app: BankApp(),
      iconData: Icons.account_balance_rounded,
      colors: [Color(0xFFE0485F), Color(0xFF8E0E21)],
      badgeCount: newTransactionCount,
    ),
    AppIcon(
      title: "Kayıtlar",
      app: RecordingsApp(),
      iconData: Icons.graphic_eq_rounded,
      colors: [Color(0xFF3A3A3C), Color(0xFF1C1C1E)],
      glyphColor: Color(0xFFFF453A),
      badgeCount: unheardRecordingCount,
    ),
    AppIcon(
      title: "News",
      app: NewsApp(),
      iconData: Icons.newspaper_rounded,
      colors: [Color(0xFFFF5A5F), Color(0xFFD70015)],
      badgeCount: newArticleCount,
    ),
    AppIcon(
      title: "Settings",
      app: SettingsApp(),
      iconData: Icons.settings_rounded,
      colors: [Color(0xFFAEAEB2), Color(0xFF636366)],
    ),
  ],
  [
    AppIcon(
      title: "Games",
      app: GamesApp(),
      iconData: Icons.sports_esports_rounded,
      colors: [Color(0xFFB36BFF), Color(0xFF5B2BD6)],
    ),
    AppIcon(
      title: "Music",
      app: MusicApp(),
      iconData: Icons.music_note_rounded,
      colors: [Color(0xFFFF5E7E), Color(0xFFFA233B)],
    ),
    AppIcon(title: "Pian", app: PianApp(), artwork: pianoArtwork),
    AppIcon(
      title: "Shopper",
      app: ShopperApp(),
      iconData: Icons.shopping_bag_rounded,
      colors: [Color(0xFFFFB347), Color(0xFFFF7A00)],
    ),
    AppIcon(
      title: "AppShop",
      app: UnavailableApp(title: "AppShop"),
      iconData: Icons.apps_rounded,
      colors: [Color(0xFF5AC8FA), Color(0xFF007AFF)],
    ),
  ],
];

const List<AppIcon> _dock = [
  AppIcon(
    title: "Phone",
    app: PhoneApp(),
    iconData: Icons.phone_rounded,
    colors: [Color(0xFF65E08A), Color(0xFF1FB84E)],
    showLabel: false,
  ),
  AppIcon(
    title: "Messages",
    app: MessagesApp(),
    iconData: Icons.sms_rounded,
    colors: [Color(0xFF7DF29B), Color(0xFF2BC74F)],
    badgeCount: unreadSmsCount,
    showLabel: false,
  ),
  AppIcon(
    title: "MatesApp",
    app: MatesApp(),
    iconData: Icons.forum_rounded,
    colors: [Color(0xFF3DDC84), Color(0xFF128C7E)],
    badgeCount: _chatsToCheck,
    showLabel: false,
  ),
  AppIcon(
    title: "Contacts",
    app: ContactsApp(),
    iconData: Icons.person_rounded,
    colors: [Color(0xFFC7B299), Color(0xFF8A7259)],
    showLabel: false,
  ),
];

/// Opens what [alert] is about on top of the home screen: its app, and for
/// a message the chat it came in.
Future<void> openAlert(NavigatorState navigator, StoryAlert alert) async {
  final icon = homeIcon(alert.app);
  if (icon == null) return;
  navigator.popUntil((route) => route.isFirst);
  unawaited(navigator.push(icon.route()));
  final person = alert.thread;
  if (alert.app != 'MatesApp' || person == null) return;
  final contacts = await ContactsRepository().loadAll();
  final number = contacts
      .where((c) => !c.userAdded && c.name == person)
      .firstOrNull
      ?.number;
  unawaited(
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(person: person, number: number),
      ),
    ),
  );
}

/// The home screen icon of the app called [title].
AppIcon? homeIcon(String title) => [
  ..._pages.expand((page) => page),
  ..._dock,
].where((icon) => icon.title == title).firstOrNull;

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<Wallpaper>(
              valueListenable: WallpaperSetting.current,
              builder: (context, wallpaper, _) =>
                  WallpaperView(wallpaper: wallpaper),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPageIndex = index),
                      children: [
                        _HomePage(
                          apps: _pages[0],
                          header: const _ClockWidget(),
                        ),
                        _HomePage(apps: _pages[1]),
                      ],
                    ),
                  ),
                  _PageDots(count: _pages.length, current: _currentPageIndex),
                  const SizedBox(height: 12),
                  const _Dock(apps: _dock),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A page of app icons in a four-column grid.
class _HomePage extends StatelessWidget {
  const _HomePage({required this.apps, this.header});

  static const _columns = 4;

  final List<AppIcon> apps;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        children: [
          if (header != null) ...[header!, const SizedBox(height: 28)],
          for (var start = 0; start < apps.length; start += _columns)
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Row(
                children: [
                  for (var i = start; i < start + _columns; i++)
                    Expanded(
                      child: Center(
                        child: i < apps.length ? apps[i] : const SizedBox(),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The large time and date at the top of the first home page.
class _ClockWidget extends StatefulWidget {
  const _ClockWidget();

  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late DateTime _now = DateTime.now();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const shadow = [Shadow(color: Color(0x66000000), blurRadius: 12)];
    return Column(
      children: [
        Text(
          clockTime(_now),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 76,
            fontWeight: FontWeight.w200,
            height: 1.05,
            shadows: shadow,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          longTurkishDate(_now),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            shadows: shadow,
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: i == current ? 1 : 0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The frosted glass bar at the bottom of the home screen.
class _Dock extends StatelessWidget {
  const _Dock({required this.apps});

  final List<AppIcon> apps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: apps,
            ),
          ),
        ),
      ),
    );
  }
}
