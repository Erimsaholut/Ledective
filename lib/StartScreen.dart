import 'package:flutter/material.dart';
import 'package:ledective/apps/appShop_app/appShop.dart';
import 'package:ledective/apps/clock_app/clock.dart';
import 'package:ledective/apps/contacts_app/contacts.dart';
import 'package:ledective/apps/matesApp_app/mates_app.dart';
import 'package:ledective/apps/notes_app/Notes_app.dart';
import 'package:ledective/apps/photos_app/photos.dart';
import 'package:ledective/apps/pian_app/pian.dart';
import 'package:ledective/apps/poltel_app/poltel.dart';
import 'package:ledective/apps/settings_app/settings.dart';
import 'package:ledective/apps/sinstagram_app/sinstagram.dart';
import 'package:ledective/widgets/AppWidgetTest.dart';
import 'package:ledective/widgets/sized_row.dart';
import 'apps/calendar_app/calendar.dart';
import 'apps/games_app/games.dart';
import 'apps/phone_app/phone.dart';
import 'apps/mail_app/mail.dart';
import 'widgets/AppWidget.dart';
import 'constants/constants.dart';

class _StartScreenState extends State<StartScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  double sizedBoxHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            PageView(
              onPageChanged: (int pageIndex) {
                setState(() {
                  _currentPageIndex = pageIndex;
                });
              },
              controller: pageController,
              physics: const ClampingScrollPhysics(),
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  decoration: BoxDecoration(
                    color: kStartScreenPage1Color,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const AppWidget(
                                  title: "Mail",
                                  iconData: Icons.mail,
                                  child: MailApp()),
                              AppWidgetTest(
                                  title: "Photos",
                                  function: () {
                                    Navigator.pushNamed(context, "/photosApp");
                                  },
                                  iconData: Icons.photo),
                              const AppWidget(
                                  title: "AppShop",
                                  iconData: Icons.shop,
                                  child: AppShop()),
                            ],
                          ),
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AppWidget(
                                  title: "MatesApp",
                                  iconData: Icons.mark_chat_read,
                                  child: MatesApp()),
                              AppWidget(
                                  title: "Calendar",
                                  iconData: Icons.calendar_today,
                                  child: CalendarApp()),
                              AppWidget(
                                  title: "Settings",
                                  iconData: Icons.settings,
                                  child: Settings()),
                            ],
                          ),
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AppWidget(
                                  title: "Camera",
                                  iconData: Icons.camera_alt_rounded,
                                  child: SizedBox()),
                              AppWidget(
                                  title: "Sinstagram",
                                  iconData: Icons.cruelty_free_outlined,
                                  child: Sinstagram()),
                              AppWidget(
                                  title: "Poltel",
                                  iconData: Icons.policy,
                                  child: Poltel()),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  decoration: BoxDecoration(color: kStartScreenPage2Color),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AppWidget(
                                  title: "Notes",
                                  iconData: Icons.mode_edit_outline_rounded,
                                  child: NotesApp()),
                              AppWidget(
                                  title: "Clock",
                                  iconData: Icons.access_time_filled,
                                  child: Clock()),
                              AppWidget(
                                  title: "Shopper",
                                  iconData: Icons.shopify_rounded,
                                  child: SizedBox()),
                            ],
                          ),
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AppWidget(
                                  title: "Games",
                                  iconData: Icons.videogame_asset_sharp,
                                  child: Games()),
                              AppWidget(
                                  title: "Music",
                                  iconData: Icons.speaker,
                                  child: SizedBox()),
                              AppWidget(
                                  title: "Pian",
                                  iconData: Icons.piano,
                                  child: PianApp()),
                            ],
                          ),
                          SizedBox(
                            height: sizedBoxHeight,
                          ),
                          const sizedRow(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _currentPageIndex == 0
                        ? [
                            const Icon(Icons.circle, size: 20.0),
                            const Icon(Icons.circle_outlined, size: 20.0)
                          ]
                        : [
                            const Icon(Icons.circle_outlined, size: 20.0),
                            const Icon(Icons.circle, size: 20.0)
                          ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppWidget(
                          title: "Phone",
                          iconData: Icons.phone,
                          child: PhoneContacts()),
                      AppWidget(
                          title: "Contacts",
                          iconData: Icons.contacts,
                          child: Contacts()),
                      AppWidget(
                          title: "Messages",
                          iconData: Icons.message,
                          child: SizedBox()),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}
