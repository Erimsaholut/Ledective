// Checks the story files in assets/story for mistakes.
//
//   dart run tool/validate_story.dart          # check
//   dart run tool/validate_story.dart --graph  # also draw story/graphs/*.md
//   dart run tool/validate_story.dart --table  # also write story/HIKAYE_SEMASI.md
import 'dart:io';

import 'package:ledective/story/story_data.dart';
import 'package:ledective/story/story_table.dart';
import 'package:ledective/story/story_validator.dart';

Future<void> main(List<String> args) async {
  final StoryData story;
  try {
    story = await StoryData.load((path) => File(path).readAsString());
  } on FormatException catch (e) {
    stderr.writeln('HATA  ${e.message}');
    exit(1);
  }

  final issues = validateStory(story, assetExists: (p) => File(p).existsSync());
  // Notes last: they are the to-do list, not problems.
  for (final level in IssueLevel.values) {
    for (final issue in issues.where((i) => i.level == level)) {
      (issue.isError ? stderr : stdout).writeln(issue);
    }
  }

  if (args.contains('--graph')) {
    Directory('story/graphs').createSync(recursive: true);
    for (final MapEntry(key: person, value: c) in story.conversations.entries) {
      if (c.dialogue == null) continue;
      File('story/graphs/$person.md').writeAsStringSync(
        '# $person\n\n```mermaid\n${dialogueToMermaid(person, c)}```\n',
      );
    }
    stdout.writeln('Sohbet şemaları story/graphs/ klasörüne yazıldı.');
  }

  if (args.contains('--table')) {
    File('story/HIKAYE_SEMASI.md').writeAsStringSync(storyTable(story));
    stdout.writeln('Hikâye şeması story/HIKAYE_SEMASI.md dosyasına yazıldı.');
  }

  int count(IssueLevel level) => issues.where((i) => i.level == level).length;
  final errors = count(IssueLevel.error);
  final summary =
      '${count(IssueLevel.warning)} uyarı, ${count(IssueLevel.note)} not';
  stdout.writeln(
    errors == 0 ? 'Hikâye geçerli ($summary).' : '$errors hata, $summary.',
  );
  exit(errors == 0 ? 0 : 1);
}
