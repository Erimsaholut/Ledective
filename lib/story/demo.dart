/// Whether this is the alpha demo for friends, built with
/// `--dart-define=DEMO=true`. The demo closes the hidden ending (its omens
/// stay), hides the author's settings and starts at double tempo.
const demoBuild = bool.fromEnvironment('DEMO');

/// Closes the hidden ending in the decoded story [files]: drops
/// endings.json › `secret` and makes every chat option that would begin it
/// unreachable. Options keep their places, since saves store them by index.
void closeSecret(Map<String, Object?> files) {
  final endings = files['endings.json'];
  if (endings is! Map<String, Object?>) return;
  final secret = endings.remove('secret');
  if (secret is! Map<String, Object?>) return;
  final starts = <String>{
    for (final key in ['requires', 'requiresAny'])
      ...switch (secret[key]) {
        final String term => [term],
        final List<Object?> terms => terms.whereType<String>(),
        _ => const <String>[],
      },
  };

  void visit(Object? node) {
    if (node is Map<String, Object?>) {
      final unlocks = node['unlocks'];
      if (node.containsKey('label') &&
          unlocks is List &&
          unlocks.any(starts.contains)) {
        node['requires'] = 'demo:closed';
        node.remove('requiresAny');
      }
      node.values.forEach(visit);
    } else if (node is List) {
      node.forEach(visit);
    }
  }

  visit(files['chats.json']);
}

/// [text] without the writer's leading "[Taslak]" mark, for the demo.
String withoutDraftMark(String text) =>
    text.replaceFirst(RegExp(r'^\s*\[Taslak\]\s*'), '');

/// Whether [text] only says a part isn't written yet, which the demo
/// leaves out ("Özge için hikâye henüz yazılmadı.").
bool isUnwritten(String text) => text.contains('henüz yazılmadı');
