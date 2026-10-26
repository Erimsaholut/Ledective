import 'package:flutter/material.dart';

import '../apps/calendar/calendar_app.dart';
import '../apps/camera/camera_app.dart';
import '../apps/clock/clock_app.dart';
import '../apps/contacts/contacts_app.dart';
import '../apps/games/games_app.dart';
import '../apps/mail/mail_app.dart';
import '../apps/mates/mates_app.dart';
import '../apps/messages/messages_app.dart';
import '../apps/music/music_app.dart';
import '../apps/notes/notes_app.dart';
import '../apps/phone/phone_app.dart';
import '../apps/photos/photos_app.dart';
import '../apps/pian/pian_app.dart';
import '../apps/poltel/poltel_app.dart';
import '../apps/settings/settings_app.dart';
import '../apps/shopper/shopper_app.dart';
import '../apps/sinstagram/sinstagram_app.dart';
import '../apps/unavailable/unavailable_app.dart';
import '../data/home_colors.dart';
import '../story/story_progress.dart';
import 'app_icon.dart';

int _unreadChats(StoryProgress progress) => progress.totalUnread;

const List<List<AppIcon>> _pages = [
  [
    AppIcon(title: "Mail", iconData: Icons.mail, app: MailApp()),
    AppIcon(title: "Photos", iconData: Icons.photo, app: PhotosApp()),
    AppIcon(
      title: "AppShop",
      iconData: Icons.shop,
      app: UnavailableApp(title: "AppShop"),
    ),
    AppIcon(
      title: "MatesApp",
      iconData: Icons.mark_chat_read,
      app: MatesApp(),
      badgeCount: _unreadChats,
    ),
    AppIcon(
      title: "Calendar",
      iconData: Icons.calendar_today,
      app: CalendarApp(),
    ),
    AppIcon(title: "Settings", iconData: Icons.settings, app: SettingsApp()),
    AppIcon(
      title: "Camera",
      iconData: Icons.camera_alt_rounded,
      app: CameraApp(),
    ),
    AppIcon(
      title: "Sinstagram",
      iconData: Icons.cruelty_free_outlined,
      app: Sinstagram(),
    ),
    AppIcon(
      title: "Poltel",
      iconData: Icons.policy,
      app: Poltel(),
      badgeCount: newDocumentCount,
    ),
  ],
  [
    AppIcon(
      title: "Notes",
      iconData: Icons.mode_edit_outline_rounded,
      app: NotesApp(),
    ),
    AppIcon(
      title: "Clock",
      iconData: Icons.access_time_filled,
      app: ClockApp(),
    ),
    AppIcon(
      title: "Shopper",
      iconData: Icons.shopify_rounded,
      app: ShopperApp(),
    ),
    AppIcon(
      title: "Games",
      iconData: Icons.videogame_asset_sharp,
      app: GamesApp(),
    ),
    AppIcon(title: "Music", iconData: Icons.speaker, app: MusicApp()),
    AppIcon(title: "Pian", iconData: Icons.piano, app: PianApp()),
  ],
];

const List<AppIcon> _dock = [
  AppIcon(title: "Phone", iconData: Icons.phone, app: PhoneApp()),
  AppIcon(title: "Contacts", iconData: Icons.contacts, app: ContactsApp()),
  AppIcon(
    title: "Messages",
    iconData: Icons.message,
    app: MessagesApp(),
    badgeCount: unreadSmsCount,
  ),
];

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
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPageIndex = index),
            children: [
              _HomePage(color: HomeColors.page1, apps: _pages[0]),
              _HomePage(color: HomeColors.page2, apps: _pages[1]),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        Icon(
                          i == _currentPageIndex
                              ? Icons.circle
                              : Icons.circle_outlined,
                          size: 20.0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _dock,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.color, required this.apps});

  static const _columns = 3;
  static const _rowSpacing = 20.0;

  final ValueNotifier<Color> color;
  final List<AppIcon> apps;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: color,
      builder: (context, color, child) =>
          ColoredBox(color: color, child: child),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            children: [
              for (var start = 0; start < apps.length; start += _columns) ...[
                const SizedBox(height: _rowSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = start; i < start + _columns; i++)
                      i < apps.length
                          ? apps[i]
                          : const SizedBox.square(dimension: AppIcon.size),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
