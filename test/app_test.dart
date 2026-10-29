import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/bank/transfer_page.dart';
import 'package:ledective/apps/games/castle_guard/castle_defense.dart';
import 'package:ledective/apps/games/castle_guard/castle_guard_app.dart';
import 'package:ledective/apps/games/castle_guard/castle_profile.dart';
import 'package:ledective/apps/games/farm/farm_app.dart';
import 'package:ledective/apps/games/farm/farm_state.dart';
import 'package:ledective/apps/games/space_runner/space_runner_app.dart';
import 'package:ledective/apps/games/sudoku/sudoku_app.dart';
import 'package:ledective/apps/games/sudoku/sudoku_game.dart';
import 'package:ledective/apps/games/sudoku/sudoku_puzzle.dart';
import 'package:ledective/apps/map/map_app.dart';
import 'package:ledective/apps/news/news_app.dart';
import 'package:ledective/apps/settings/story_state_page.dart';
import 'package:ledective/apps/poltel/lab/inspection_page.dart';
import 'package:ledective/apps/poltel/lab/jigsaw_game.dart';
import 'package:ledective/apps/poltel/lab/uv_game.dart';
import 'package:ledective/story/story_data.dart';
import 'package:ledective/apps/mates/chat_page.dart';
import 'package:ledective/apps/phone/call_screen.dart';
import 'package:ledective/data/bank_account.dart';
import 'package:ledective/data/game_state.dart';
import 'package:ledective/data/installed_games.dart';
import 'package:ledective/home/epilogue_page.dart';
import 'package:ledective/data/recent_calls.dart';
import 'package:ledective/home/app_icon.dart';
import 'package:ledective/main.dart';
import 'package:ledective/story/dialogue.dart';
import 'package:ledective/story/news_feed.dart';
import 'package:ledective/story/story_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.runAsync(loadGameState);
  await tester.pumpWidget(const LedectiveApp());
  await tester.pumpAndSettle();
}

/// The [label] button of [game] in AppShop.
Finder _storeButton(String game, String label) => find.descendant(
  of: find.widgetWithText(Card, game),
  matching: find.text(label),
);

Finder _homeIcon(String title) => find
    .byWidgetPredicate((w) => w is AppIcon && w.title == title)
    .hitTestable();

/// Swipes the home screen to its second page.
Future<void> _toSecondPage(WidgetTester tester) async {
  await tester.fling(find.byType(PageView).first, const Offset(-500, 0), 1000);
  await tester.pumpAndSettle();
}

/// A screen with a "call" button that opens a [CallScreen] for [number].
Future<void> _pumpCallLauncher(WidgetTester tester, String number) async {
  await tester.runAsync(loadGameState);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CallScreen(number: number),
              ),
            ),
            child: const Text('call'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('every home screen app opens and closes', (tester) async {
    await _pumpApp(tester);

    // Pian needs the audio plugin, which isn't available in widget tests.
    const firstPage = [
      'Mail', 'Photos', 'Camera', 'Calendar', 'Clock', 'Poltel', 'Harita',
      'Pano', 'Notes', 'Sinstagram', 'ZaferBank', 'Kayıtlar', 'News', //
      'Settings',
      // The dock.
      'Phone', 'Messages', 'MatesApp', 'Contacts',
    ];
    const secondPage = ['Games', 'Music', 'Shopper', 'AppShop'];

    Finder icon(String title) => find
        .byWidgetPredicate((w) => w is AppIcon && w.title == title)
        .hitTestable();

    Future<void> openAndClose(String title) async {
      await tester.tap(icon(title));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: title);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
    }

    for (final title in firstPage) {
      await openAndClose(title);
    }
    await tester.fling(
      find.byType(PageView).first,
      const Offset(-500, 0),
      1000,
    );
    await tester.pumpAndSettle();
    for (final title in secondPage) {
      await openAndClose(title);
    }
  });

  testWidgets('chatting with Özge follows the story and is saved', (
    tester,
  ) async {
    await tester.runAsync(loadGameState);
    await tester.pumpWidget(const MaterialApp(home: ChatPage(person: 'Özge')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Neymiş bu kadar önemli olan durum'));
    await tester.pump();

    // The first of Özge's three replies arrives after a second.
    expect(find.textContaining('3 gün önce akşam saatlerinde'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('3 gün önce akşam saatlerinde'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Yakınlarının ifadesini aldınız mı ?'), findsOneWidget);

    expect(StoryProgress.instance.choicesFor('Özge'), [1]);
    expect(StoryProgress.instance.trait(Trait.curiosity), 1);

    // Reopening the chat restores the conversation.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MaterialApp(home: ChatPage(person: 'Özge')));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 gün önce akşam saatlerinde'), findsOneWidget);
  });

  testWidgets('a call hangs up by itself and is added to recents', (
    tester,
  ) async {
    await _pumpCallLauncher(tester, '0535 031 53 53');

    await tester.tap(find.text('call'));
    await tester.pump();
    // The ringing animation repeats forever, so pump a fixed time instead
    // of waiting for it to settle.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CallScreen), findsOneWidget);
    expect(RecentCalls.calls.value.first.number, '0535 031 53 53');

    await tester.pump(const Duration(seconds: 14));
    await tester.pumpAndSettle();
    expect(find.byType(CallScreen), findsNothing);
    expect(
      find.text('call'),
      findsOneWidget,
      reason: 'only the call screen is closed',
    );
  });

  testWidgets('hanging up early does not close the screen below later', (
    tester,
  ) async {
    await _pumpCallLauncher(tester, '123');

    await tester.tap(find.text('call'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.call_end_rounded));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    expect(find.text('call'), findsOneWidget);
  });

  testWidgets('sending an officer from the map brings back a report', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(loadGameState);
    await StoryProgress.instance.discover(['part1Done']);
    await tester.pumpWidget(const MaterialApp(home: MapApp()));
    await tester.pump();

    await tester.tap(find.text("Berat'ın Evi"), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text("Olay yerini yeniden ara"), findsOneWidget);
    // The place's photo is above its tasks.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.endsWith('olay_yeri.jpg'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Gönder').first);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(find.text('Doğa').last);
    await tester.pump();
    expect(StoryProgress.instance.missionOf('Doğa'), isNotNull);

    // Close everything so the map's ticker stops.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('lab minigames complete their inspections', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.runAsync(loadGameState);
    final evidence = StoryData.current.evidence;
    final progress = StoryProgress.instance;

    // Fingerprint: a wrong guess is rejected, the right one solves it.
    final glass = evidence.firstWhere((e) => e.id == 'glass');
    await tester.pumpWidget(MaterialApp(home: InspectionPage(evidence: glass)));
    await tester.ensureVisible(find.text('Yusuf Kasap'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yusuf Kasap'));
    await tester.pump();
    expect(progress.isInspected('glass'), isFalse);
    await tester.ensureVisible(find.text('Adil Karaca'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adil Karaca'));
    await tester.pumpAndSettle();
    expect(progress.isInspected('glass'), isTrue);
    expect(find.text('LABORATUVAR SONUCU'), findsOneWidget);

    // UV: sweeping the lamp over the writing reveals it.
    final notebook = evidence.firstWhere((e) => e.id == 'notebook');
    await tester.pumpWidget(
      MaterialApp(home: InspectionPage(evidence: notebook)),
    );
    final page = tester.getRect(find.byType(UvGame));
    for (var row = 0.3; row < 0.75; row += 0.1) {
      await tester.timedDragFrom(
        Offset(page.left + 4, page.top + page.height * row),
        Offset(page.width - 8, 0),
        const Duration(milliseconds: 400),
      );
    }
    await tester.pumpAndSettle();
    expect(progress.isInspected('notebook'), isTrue);

    // Jigsaw: swapping the pieces back solves it.
    final photo = evidence.firstWhere((e) => e.id == 'torn-photo');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JigsawGame(
            image: photo.image!,
            rows: 2,
            cols: 2,
            board: JigsawBoard.fromPieces(2, 2, [1, 0, 2, 3]),
            onSolved: () => progress.completeInspection(photo),
          ),
        ),
      ),
    );
    final pieces = find.byType(GestureDetector);
    await tester.tap(pieces.at(0));
    await tester.tap(pieces.at(1));
    await tester.pumpAndSettle();
    expect(progress.isInspected('torn-photo'), isTrue);
    expect(progress.has('photo-restored'), isTrue);
  });

  testWidgets('a suspended detective finds Poltel locked', (tester) async {
    await _pumpApp(tester);
    await tester.runAsync(
      () => StoryProgress.instance.discover(['status:suspended']),
    );
    await tester.tap(
      find.byWidgetPredicate((w) => w is AppIcon && w.title == 'Poltel'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Erişim askıya alındı'), findsOneWidget);
    expect(find.text('Belgeler'), findsNothing);
  });

  testWidgets('money sent from ZaferBank reaches the story', (tester) async {
    await tester.runAsync(loadGameState);
    await tester.runAsync(() => StoryProgress.instance.discover(['mp:wrote']));
    await tester.pumpWidget(
      const MaterialApp(home: TransferPage(color: Colors.red)),
    );
    final before = BankAccount.instance.balance(StoryProgress.instance);
    await tester.tap(find.text('Gönderene iade'));
    await tester.enterText(find.byType(TextField).first, '50.000');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Gönder'));
    await tester.pumpAndSettle();
    expect(find.textContaining('geri alınamaz'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Gönder').last);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(
      BankAccount.instance.balance(StoryProgress.instance),
      before - 5000000,
    );
    expect(StoryProgress.instance.has('bribe:returned'), isTrue);
  });

  testWidgets('reading an archived article sets its flag', (tester) async {
    await tester.runAsync(loadGameState);
    final article = StoryData.current.news.articles.firstWhere(
      (a) => a.id == 'old-case',
    );
    await tester.pumpWidget(
      MaterialApp(home: ArticlePage(item: NewsItem(article, DateTime(2023)))),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.text(article.title), findsOneWidget);
    expect(StoryProgress.instance.has('news:old-case-found'), isTrue);
  });

  testWidgets('the epilogue tells every part of the ending', (tester) async {
    await tester.runAsync(loadGameState);
    await tester.runAsync(
      () => StoryProgress.instance.discover(['case:solved', 'final:ready']),
    );
    await tester.pumpWidget(const MaterialApp(home: EpiloguePage()));
    await tester.pumpAndSettle();
    expect(find.text('Sessiz Zafer'), findsOneWidget);
    expect(find.text('DOSYA KAPANDI'), findsOneWidget);
  });

  testWidgets('the story state page changes numbers and flags', (tester) async {
    await tester.runAsync(loadGameState);
    await tester.pumpWidget(const MaterialApp(home: StoryStatePage()));
    await tester.runAsync(() async {
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    expect(StoryProgress.instance.value('trust:Özge'), 60);
    expect(find.text('60'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a game downloaded from AppShop can be opened and deleted', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _toSecondPage(tester);
    expect(_homeIcon('Sudoku'), findsNothing);

    await tester.tap(_homeIcon('AppShop'));
    await tester.pumpAndSettle();
    expect(find.text('Sudoku'), findsOneWidget);
    await tester.tap(_storeButton('Sudoku', 'İndir'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Aç'), findsNothing);
    await tester.pump(InstalledGames.downloadTime);
    await tester.pumpAndSettle();
    expect(find.text('Aç'), findsOneWidget);
    expect(InstalledGames.ids.value, ['sudoku']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('installedGames'), ['sudoku']);

    // "Aç" opens the game.
    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();
    expect(find.text('Zorluk seç'), findsOneWidget);
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.popUntil((route) => route.isFirst);
    await tester.pumpAndSettle();

    // It's on the home screen too.
    await tester.tap(_homeIcon('Sudoku'));
    await tester.pumpAndSettle();
    expect(find.text('Zorluk seç'), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();

    // A long press deletes it, with its saved game.
    await prefs.setString(SudokuApp.saveKey, '{}');
    await tester.longPress(_homeIcon('Sudoku'));
    await tester.pumpAndSettle();
    expect(find.text('“Sudoku” silinsin mi?'), findsOneWidget);
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
    expect(_homeIcon('Sudoku'), findsNothing);
    expect(InstalledGames.ids.value, isEmpty);
    expect(prefs.getStringList('installedGames'), isEmpty);
    expect(prefs.containsKey(SudokuApp.saveKey), isFalse);

    // The store offers it again, and can delete it as well.
    await tester.tap(_homeIcon('AppShop'));
    await tester.pumpAndSettle();
    expect(_storeButton('Sudoku', 'İndir'), findsOneWidget);
    await tester.tap(_storeButton('Sudoku', 'İndir'));
    await tester.pump(InstalledGames.downloadTime);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sil').last);
    await tester.pumpAndSettle();
    expect(_storeButton('Sudoku', 'İndir'), findsOneWidget);
    expect(InstalledGames.ids.value, isEmpty);
  });

  testWidgets('a download goes on after the store is closed', (tester) async {
    await _pumpApp(tester);
    await _toSecondPage(tester);
    await tester.tap(_homeIcon('AppShop'));
    await tester.pumpAndSettle();

    // A download can be stopped by tapping its progress.
    await tester.tap(_storeButton('Sudoku', 'İndir'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();
    expect(InstalledGames.downloads.value, isEmpty);
    expect(_storeButton('Sudoku', 'İndir'), findsOneWidget);

    // Leaving the store half way doesn't stop it.
    await tester.tap(_storeButton('Sudoku', 'İndir'));
    await tester.pump(const Duration(milliseconds: 500));
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.popUntil((route) => route.isFirst);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Yükleniyor…'), findsOneWidget);
    expect(_homeIcon('Sudoku'), findsNothing);
    await tester.pump(InstalledGames.downloadTime);
    await tester.pumpAndSettle();
    expect(find.text('Yükleniyor…'), findsNothing);
    expect(_homeIcon('Sudoku'), findsOneWidget);
    expect(InstalledGames.ids.value, ['sudoku']);

    // Opened again, the store knows it is there.
    await tester.tap(_homeIcon('AppShop'));
    await tester.pumpAndSettle();
    expect(_storeButton('Sudoku', 'Aç'), findsOneWidget);
  });

  testWidgets(
    'games not sold here or still in development cannot be downloaded',
    (tester) async {
      await _pumpApp(tester);
      await _toSecondPage(tester);
      await tester.tap(_homeIcon('AppShop'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        _storeButton('Pist Canavarı', 'İndir'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(_storeButton('Pist Canavarı', 'İndir'));
      await tester.pumpAndSettle();
      expect(find.text('Ülkenizde kullanılamıyor'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(_storeButton('Pist Canavarı', 'İndir'), findsOneWidget);

      // A game still being made says so instead of downloading.
      expect(find.text('Geliştirme aşamasında'), findsOneWidget);
      await tester.scrollUntilVisible(
        _storeButton('Kelime Avı', 'Yakında'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(_storeButton('Kelime Avı', 'Yakında'));
      await tester.pumpAndSettle();
      expect(find.text('Geliştirme aşamasında'), findsNWidgets(2));
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(InstalledGames.ids.value, isEmpty);
    },
  );

  testWidgets('installed games are still there after a restart', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'installedGames': ['sudoku'],
    });
    await _pumpApp(tester);
    await _toSecondPage(tester);
    expect(_homeIcon('Sudoku'), findsOneWidget);
  });

  testWidgets('a Sudoku is saved while played and celebrated when solved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    // Leave two cells with different answers open.
    final game = SudokuGame.generate(SudokuDifficulty.easy, random: Random(1));
    final solution = game.puzzle.solution;
    final last = game.values.lastIndexOf(0);
    final other = game.values.indexWhere((d) => d == 0);
    expect(solution[other], isNot(solution[last]));
    for (var i = other + 1; i < last; i++) {
      if (game.values[i] == 0) game.enter(i, solution[i]);
    }
    Future<void> tapKey(String key) async {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pump();
    }

    await tester.pumpWidget(MaterialApp(home: SudokuApp(initialGame: game)));

    // A wrong digit is marked and the game is saved.
    await tapKey('sudoku-cell-$last');
    await tapKey('sudoku-digit-${solution[other]}');
    expect(find.text('Hata: 1'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final saved = SudokuGame.fromJson(
      json.decode(prefs.getString(SudokuApp.saveKey)!) as Map<String, dynamic>,
    );
    expect(saved.values[last], solution[other]);
    expect(saved.mistakes, 1);

    await tester.tap(find.text('Sil'));
    await tapKey('sudoku-digit-${solution[last]}');
    await tapKey('sudoku-cell-$other');
    await tapKey('sudoku-digit-${solution[other]}');
    await tester.pumpAndSettle();
    expect(find.text('Tebrikler!'), findsOneWidget);
    expect(prefs.containsKey(SudokuApp.saveKey), isFalse);
  });

  testWidgets('an unfinished Sudoku is picked up again', (tester) async {
    final game = SudokuGame.generate(SudokuDifficulty.hard, random: Random(2))
      ..elapsed = const Duration(minutes: 4, seconds: 5);
    SharedPreferences.setMockInitialValues({
      SudokuApp.saveKey: json.encode(game.toJson()),
    });
    await tester.pumpWidget(const MaterialApp(home: SudokuApp()));
    await tester.pump();
    expect(find.text('Zor'), findsOneWidget);
    expect(find.text('04:05'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('04:06'), findsOneWidget);
  });

  testWidgets('a space run ends and keeps the record', (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(home: SpaceRunnerApp(random: Random(1))),
    );
    await tester.pump();
    await tester.tap(find.text('Başla'));
    var frames = 0;
    // Hold still until a rock or an empty tank ends the run.
    while (find.text('Tekrar dene').evaluate().isEmpty && frames < 3000) {
      await tester.pump(const Duration(milliseconds: 50));
      frames++;
    }
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.text('Yeni rekor!'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(SpaceRunnerApp.bestKey), greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the farm grows, harvests, sells and is saved', (tester) async {
    _phoneSize(tester);
    var now = DateTime(2026, 10, 28, 9);
    Widget farm() => MaterialApp(
      home: FarmApp(clock: () => now, random: Random(1)),
    );
    await tester.pumpWidget(farm());
    await tester.pumpAndSettle();
    expect(find.text('Günlük hediye'), findsOneWidget);
    expect(find.text('+30 🪙'), findsOneWidget);
    await tester.tap(find.text('Topla'));
    await tester.pumpAndSettle();
    expect(find.text('🪙 50'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('plot-0')));
    await tester.pumpAndSettle();
    expect(find.text('Ne ekelim?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('crop-wheat')));
    await tester.pumpAndSettle();
    expect(find.text('0:30'), findsOneWidget);

    // Half a minute later the wheat is ripe.
    now = now.add(const Duration(seconds: 30));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('plot-0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('+2 🌾 Buğday · +1 XP'), findsOneWidget);
    expect(find.text('1 / 11 XP'), findsOneWidget);

    await tester.tap(find.text('Ambar'));
    await tester.pumpAndSettle();
    expect(find.text('Buğday × 2'), findsOneWidget);
    await tester.tap(find.text('Hepsini sat'));
    await tester.pumpAndSettle();
    expect(find.text('🪙 54'), findsOneWidget);

    // The other tabs lay out on a phone.
    await tester.tap(find.text('Siparişler'));
    await tester.pumpAndSettle();
    expect(find.text('Teslim et'), findsNWidgets(FarmState.startOrderSlots));
    expect(find.text('Sipariş Panosu'), findsOneWidget);
    await tester.tap(find.text('Dükkân'));
    await tester.pumpAndSettle();
    expect(find.text('Sulama Kovası'), findsOneWidget);
    await tester.tap(find.text('Hayvanlar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Seviye 2\'te açılır'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('league')));
    await tester.pumpAndSettle();
    expect(find.text('Tahta Ligi'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Reopening the farm the same day brings it back, without a new gift.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    final prefs = await SharedPreferences.getInstance();
    final saved = FarmState.fromJson(
      json.decode(prefs.getString(FarmApp.saveKey)!) as Map<String, dynamic>,
    );
    expect(saved.coins, 54);
    await tester.pumpWidget(farm());
    await tester.pump();
    expect(find.text('🪙 54'), findsOneWidget);
    expect(find.textContaining('Günlük hediye'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the ZaferBank chest is paid from the bank and filled', (
    tester,
  ) async {
    _phoneSize(tester);
    final now = DateTime(2026, 10, 28, 9);
    FarmState saved() => FarmState(level: 3, coins: 400)
      ..claimDailyBonus(now)
      ..rollWeek(now)
      ..offerUntil = now.add(const Duration(hours: 1));
    final payments = <(int, String)>[];

    // An empty account turns the payment down.
    await _pumpFarm(
      tester,
      saved(),
      clock: () => now,
      pay: (_, _) async => false,
    );
    await tester.tap(find.byKey(const ValueKey('offer-banner')));
    await tester.pumpAndSettle();
    expect(find.text('Bereket Sandığı'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('buy-offer')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Yetersiz bakiye'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());

    await _pumpFarm(
      tester,
      saved(),
      clock: () => now,
      pay: (kurus, detail) async {
        payments.add((kurus, detail));
        return true;
      },
    );
    await tester.tap(find.byKey(const ValueKey('offer-banner')));
    await tester.pumpAndSettle();
    expect(find.text('250,00 TL öde'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('buy-offer')));
    await tester.pumpAndSettle();
    expect(payments, [
      (FarmState.offerPrice, 'Oyun içi satın alma · Bereket Sandığı'),
    ]);
    expect(find.textContaining('Bereket Sandığı açıldı'), findsOneWidget);
    expect(find.byKey(const ValueKey('offer-banner')), findsNothing);
    // Let the toast go before using the tabs under it.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ambar'));
    await tester.pumpAndSettle();
    expect(find.text('Buğday × 5'), findsOneWidget);

    // The coins buy a decoration that then stands on the field.
    await tester.tap(find.text('Dükkân'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Süsleme'));
    await tester.pumpAndSettle();
    // The shop's own list, not the row of themes in it.
    final shop = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('cosmetic-tree')),
      200,
      scrollable: shop,
    );
    // Bring it to the middle, clear of the tab bar.
    unawaited(
      Scrollable.ensureVisible(
        tester.element(find.byKey(const ValueKey('cosmetic-tree'))),
        alignment: 0.5,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cosmetic-tree')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ulu Çınar artık senin'), findsOneWidget);
    await tester.tap(find.text('Tarla'));
    await tester.pumpAndSettle();
    expect(find.text('🌳'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('towers are previewed, built and kept across visits', (
    tester,
  ) async {
    _phoneSize(tester);
    await tester.pumpWidget(const MaterialApp(home: CastleGuardApp()));
    await tester.pumpAndSettle();

    // The later maps stay locked until the first is won.
    expect(find.text('1. Yeşil Vadi'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('map-swamp')));
    await tester.pump();
    expect(
      find.text('🔒 Önce Yeşil Vadi haritasını kurtar.'),
      findsNWidgets(2),
      reason: 'on the card and in the toast',
    );
    expect(find.byKey(const ValueKey('castle-board')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('map-meadow')));
    await tester.pump();
    expect(find.text('🪙 ${CastleDefense.startGold}'), findsOneWidget);

    // Choosing a tower only previews it; choosing it again builds it.
    final board = tester.getRect(find.byKey(const ValueKey('castle-board')));
    final tile = board.width / CastleDefense.cols;
    final grass = board.topLeft + Offset(2.5 * tile, 1.5 * tile);
    await tester.tapAt(grass);
    await tester.pump();
    expect(find.text('Kule seç, menzilini haritada gör'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('build-archer')));
    await tester.pump();
    expect(find.text('🪙 ${CastleDefense.startGold}'), findsOneWidget);
    expect(find.text('Okçu Kulesi: kurmak için tekrar dokun'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('build-archer')));
    await tester.pump();
    expect(
      find.text('🪙 ${CastleDefense.startGold - TowerKind.archer.cost}'),
      findsOneWidget,
    );
    expect(find.text('🏹 Okçu Kulesi · Seviye 1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('upgrade')));
    await tester.pump();
    expect(find.text('🏹 Okçu Kulesi · Seviye 2'), findsOneWidget);

    // Tapping the previewed tile again builds too.
    final other = board.topLeft + Offset(0.5 * tile, 4.5 * tile);
    await tester.tapAt(other);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('build-archer')));
    await tester.pump();
    await tester.tapAt(other);
    await tester.pump();
    expect(find.text('🏹 Okçu Kulesi · Seviye 1'), findsOneWidget);

    // Deselect, then send the first wave and let the towers work.
    await tester.tapAt(other);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('start-wave')));
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Dalga 1/${CastleDefense.waves}'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Leaving keeps the game; coming back continues it.
    await tester.tap(find.byKey(const ValueKey('castle-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('castle-continue')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CastleGuardApp.gameKey), isNotNull);
    await tester.pumpWidget(const MaterialApp(home: CastleGuardApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('castle-continue')));
    await tester.pump();
    expect(find.text('Dalga 1/${CastleDefense.waves}'), findsOneWidget);
    await tester.tapAt(grass);
    await tester.pump();
    expect(find.text('🏹 Okçu Kulesi · Seviye 2'), findsOneWidget);

    // The record and achievements are a tap away on the menu.
    await tester.tap(find.byKey(const ValueKey('castle-menu')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('castle-stats')),
      200,
    );
    await tester.tap(find.byKey(const ValueKey('castle-achievements')));
    await tester.pumpAndSettle();
    expect(find.text('Usta Mimar'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('castle-stats')));
    await tester.pumpAndSettle();
    expect(find.text('🌿 Yeşil Vadi'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a fallen castle is recorded and can be played again', (
    tester,
  ) async {
    _phoneSize(tester);
    // A castle with one life left and no towers falls to the first goblin.
    final doomed = CastleDefense(random: Random(1))..lives = 1;
    await tester.pumpWidget(
      MaterialApp(home: CastleGuardApp(initialGame: doomed)),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('start-wave')));
    var frames = 0;
    while (find.text('Kale düştü!').evaluate().isEmpty && frames++ < 600) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Kale düştü!'), findsOneWidget);
    expect(find.text('Ana menü'), findsOneWidget);
    await tester.pump();
    final prefs = await SharedPreferences.getInstance();
    final profile = CastleProfile.fromJson(
      json.decode(prefs.getString(CastleGuardApp.profileKey)!)
          as Map<String, dynamic>,
    );
    expect(profile.games, 1);
    expect(profile.losses, 1);
    expect(prefs.getString(CastleGuardApp.gameKey), isNull);
    await tester.tap(find.text('Tekrar oyna'));
    await tester.pump();
    expect(find.text('❤️ ${CastleDefense.startLives}'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('farm animals are bought, fed and collected', (tester) async {
    _phoneSize(tester);
    var now = DateTime(2026, 10, 28, 9);
    final saved = FarmState(level: 2, coins: 100)
      ..barn['wheat'] = 1
      ..claimDailyBonus(now)
      ..rollWeek(now);
    SharedPreferences.setMockInitialValues({
      'flutter.${FarmApp.saveKey}': json.encode(saved.toJson()),
    });
    await tester.pumpWidget(
      MaterialApp(
        home: FarmApp(clock: () => now, random: Random(3)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hayvanlar'));
    await tester.pumpAndSettle();
    expect(find.text('🐔 Kümes · 0/5'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('buy-chicken')));
    await tester.pumpAndSettle();
    expect(find.text('🐔 Kümes · 1/5'), findsOneWidget);
    expect(find.textContaining('Yeni bir Tavuk aldın'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('animal-0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tavuk karnını doyurdu'), findsOneWidget);

    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('animal-0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('🥚 Yumurta · +'), findsOneWidget);

    // Hungry again, with no wheat left.
    await tester.tap(find.byKey(const ValueKey('animal-0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('ambarda 1 🌾 Buğday olmalı'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _pumpFarm(
  WidgetTester tester,
  FarmState saved, {
  required DateTime Function() clock,
  Future<bool> Function(int kurus, String detail)? pay,
}) async {
  SharedPreferences.setMockInitialValues({
    'flutter.${FarmApp.saveKey}': json.encode(saved.toJson()),
  });
  await tester.pumpWidget(
    MaterialApp(
      home: FarmApp(clock: clock, random: Random(3), pay: pay),
    ),
  );
  await tester.pumpAndSettle();
}

void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
}
