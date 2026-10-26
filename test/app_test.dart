import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/apps/mates/chat_page.dart';
import 'package:ledective/apps/phone/call_screen.dart';
import 'package:ledective/data/game_state.dart';
import 'package:ledective/data/recent_calls.dart';
import 'package:ledective/home/app_icon.dart';
import 'package:ledective/main.dart';
import 'package:ledective/story/dialogue.dart';
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
    const titles = [
      'Mail', 'Photos', 'AppShop', 'MatesApp', 'Calendar', 'Settings',
      'Camera', 'Sinstagram', 'Poltel', 'Phone', 'Contacts', 'Messages',
      // Second page.
      'Notes', 'Clock', 'Shopper', 'Games', 'Music',
    ];

    for (final title in titles) {
      final icon = find.widgetWithText(AppIcon, title);
      if (icon.hitTestable().evaluate().isEmpty) {
        // The app is on the second home screen page.
        await tester.fling(
          find.byType(PageView).first,
          const Offset(-500, 0),
          1000,
        );
        await tester.pumpAndSettle();
      }
      await tester.tap(icon.hitTestable());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: title);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('chatting with Özge follows the story and is saved', (
    tester,
  ) async {
    await tester.runAsync(loadGameState);
    await tester.pumpWidget(const MaterialApp(home: ChatPage(person: 'Özge')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send Message'));
    await tester.pump();
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
    await tester.tap(find.byIcon(Icons.call_end));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 20));
    await tester.pumpAndSettle();
    expect(find.text('call'), findsOneWidget);
  });
}
