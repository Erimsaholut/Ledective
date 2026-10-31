import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledective/story/demo.dart';
import 'package:ledective/story/story_data.dart';

void main() {
  test('the demo closes the hidden ending but keeps option places', () {
    final files = {
      for (final f in StoryData.files)
        f: jsonDecode(File('assets/story/$f').readAsStringSync()),
    };
    final full = StoryData.fromJson(jsonDecode(jsonEncode(files)));
    closeSecret(files);
    final demo = StoryData.fromJson(files);
    expect(full.endings.secret, isNotNull);
    expect(demo.endings.secret, isNull);
    final chats = jsonEncode(files['chats.json']);
    expect(chats, contains('demo:closed'));
    expect(demo.conversations.length, full.conversations.length);
  });
}
