// Checks the story files in assets/story for mistakes.
//
//   dart run tool/validate_story.dart          # check
//   dart run tool/validate_story.dart --graph  # also draw story/graphs/*.md
import 'dart:io';

import 'package:ledective/story/story_data.dart';
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
  for (final issue in issues) {
    (issue.isError ? stderr : stdout).writeln(issue);
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

  final errors = issues.where((i) => i.isError).length;
  final warnings = issues.length - errors;
  stdout.writeln(
    errors == 0
        ? 'Hikâye geçerli ($warnings uyarı).'
        : '$errors hata, $warnings uyarı.',
  );
  exit(errors == 0 ? 0 : 1);
}
