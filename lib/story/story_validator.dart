import 'dialogue.dart';
import 'story_data.dart';

/// A problem found in the story files. Errors break the game; warnings are
/// probably mistakes.
class StoryIssue {
  const StoryIssue(this.where, this.message, {this.isError = true});

  final String where;
  final String message;
  final bool isError;

  @override
  String toString() => '${isError ? 'HATA' : 'UYARI'}  $where: $message';
}

/// Checks that the story hangs together: every link points somewhere,
/// every flag something waits for can be set, every asset exists.
/// [assetExists] is asked about image and audio paths.
List<StoryIssue> validateStory(
  StoryData story, {
  bool Function(String path)? assetExists,
}) {
  final issues = <StoryIssue>[];
  void error(String where, String message) =>
      issues.add(StoryIssue(where, message));
  void warn(String where, String message) =>
      issues.add(StoryIssue(where, message, isError: false));

  // Flags that something sets, and flags that something waits for.
  final set = <String, String>{};
  final used = <String, String>{};
  void sets(Iterable<String> flags, String where) {
    for (final f in flags) {
      set.putIfAbsent(f, () => where);
    }
  }

  void uses(Condition c, String where) {
    for (final f in c.flags) {
      used.putIfAbsent(f, () => where);
    }
  }

  void asset(String? path, String where) {
    if (path == null || assetExists == null) return;
    if (!assetExists(path)) error(where, 'dosya bulunamadı: $path');
  }

  // Conversations.
  for (final MapEntry(key: person, value: c) in story.conversations.entries) {
    final dialogue = c.dialogue;
    if (dialogue == null) continue;
    final where = 'chats.json › $person';
    if (!dialogue.nodes.containsKey(dialogue.start)) {
      error(where, 'başlangıç düğümü "${dialogue.start}" yok');
    }
    final reached = <String>{};
    final pending = [dialogue.start];
    while (pending.isNotEmpty) {
      final id = pending.removeLast();
      if (!reached.add(id)) continue;
      final node = dialogue.nodes[id];
      if (node == null) continue;
      for (final option in node.options) {
        final next = option.next;
        if (next != null) pending.add(next);
      }
    }
    for (final MapEntry(key: id, value: node) in dialogue.nodes.entries) {
      final at = '$where › $id';
      if (!reached.contains(id)) warn(at, 'bu düğüme hiçbir seçenek gitmiyor');
      if (node.options.isEmpty && node.incoming.isEmpty) {
        error(at, 'düğüm boş: ne "incoming" ne "options" var');
      }
      uses(node.waitFor, at);
      for (final option in node.options) {
        final next = option.next;
        if (next != null && !dialogue.nodes.containsKey(next)) {
          error(
            at,
            '"${option.label}" seçeneği olmayan "$next" düğümüne gidiyor',
          );
        }
        sets(option.unlocks, at);
      }
    }
  }

  // Documents.
  for (final d in story.documents) {
    final where = 'documents.json › ${d.id}';
    uses(d.requires, where);
    if (d is Statement) {
      final from = d.testimonyFrom;
      if (from != null && !story.conversations.containsKey(from)) {
        error(where, 'testimonyFrom "$from" diye bir sohbet yok');
      }
      if (from == null && d.qa.isEmpty) {
        warn(where, 'ifadede hiç soru-cevap yok');
      }
    }
  }

  // Mails, SMS, bank, recordings, Sinstagram.
  for (final m in story.storyMails) {
    uses(m.requires, 'mails.json › ${m.sender}');
  }
  for (final t in story.smsThreads) {
    uses(t.requires, 'sms.json › ${t.sender}');
  }
  for (final t in story.bank.transactions) {
    uses(t.requires, 'bank.json › ${t.id}');
  }
  for (final r in story.recordings) {
    final where = 'voicemail.json › ${r.id}';
    uses(r.requires, where);
    sets(r.unlocksOnListen, where);
    asset(r.audio, where);
  }
  final handles = <String>{};
  for (final p in story.profiles) {
    final where = 'sinstagram.json › ${p.handle}';
    if (!handles.add(p.handle)) {
      error(where, 'bu kullanıcı adı iki kez tanımlı');
    }
    uses(p.requires, where);
    sets(p.unlocksOnView, where);
    for (final post in p.posts) {
      asset(post.image, where);
    }
  }
  for (final post in story.feed) {
    asset(post.image, 'sinstagram.json › feed › ${post.id}');
  }

  // Map.
  asset(story.map.image, 'map.json');
  final taskIds = <String>{};
  for (final l in story.map.locations) {
    final where = 'map.json › ${l.id}';
    uses(l.requires, where);
    if (l.x < 0 || l.x > 1 || l.y < 0 || l.y > 1) {
      error(where, 'x ve y 0 ile 1 arasında olmalı');
    }
    for (final t in l.tasks) {
      final at = '$where › ${t.id}';
      if (!taskIds.add(t.id)) error(at, 'bu görev kimliği iki kez kullanılmış');
      uses(t.requires, at);
      sets(t.unlocks, at);
    }
  }
  if (story.map.officers.isEmpty) error('map.json', 'hiç subay yok');

  // Evidence.
  final evidenceIds = {for (final e in story.evidence) e.id};
  for (final e in story.evidence) {
    final where = 'evidence.json › ${e.id}';
    uses(e.requires, where);
    asset(e.image, where);
    for (final link in e.links) {
      if (!evidenceIds.contains(link)) {
        error(where, '"$link" diye bir delil yok');
      }
    }
    final inspection = e.inspection;
    if (inspection == null) continue;
    sets(inspection.unlocks, '$where › inspection');
    switch (inspection) {
      case JigsawInspection() || UvInspection() when e.image == null:
        error(where, 'bu inceleme için "image" gerekli');
      case FingerprintInspection(:final options, :final answer)
          when !options.contains(answer):
        error(where, 'cevap "$answer" seçenekler arasında yok');
      default:
    }
  }

  // Flags.
  for (final MapEntry(key: flag, value: where) in used.entries) {
    if (!set.containsKey(flag)) {
      error(where, '"$flag" bayrağını bekliyor ama hiçbir şey onu açmıyor');
    }
  }
  for (final MapEntry(key: flag, value: where) in set.entries) {
    if (!used.containsKey(flag)) {
      warn(where, '"$flag" bayrağını açıyor ama hiçbir şey onu beklemiyor');
    }
  }
  return issues;
}

/// The conversation as a Mermaid flowchart, for reviewing branches.
String dialogueToMermaid(String person, Conversation conversation) {
  final dialogue = conversation.dialogue;
  final buffer = StringBuffer('flowchart TD\n');
  if (dialogue == null) return buffer.toString();
  String esc(String text) => text.replaceAll('"', "'");
  String short(String text) =>
      esc(text.length > 60 ? '${text.substring(0, 57)}...' : text);
  for (final MapEntry(key: id, value: node) in dialogue.nodes.entries) {
    final wait = node.waitFor.isAlways
        ? ''
        : '<br/><i>bekler: ${node.waitFor.flags.join(', ')}</i>';
    final incoming = node.incoming.isEmpty
        ? ''
        : '<br/>${short(node.incoming.first)}';
    buffer.writeln('  $id["<b>$id</b>$wait$incoming"]');
    for (var i = 0; i < node.options.length; i++) {
      final option = node.options[i];
      final target = option.next ?? '${id}_end$i';
      if (option.next == null) buffer.writeln('  $target(((son)))');
      final unlocks = option.unlocks.isEmpty
          ? ''
          : ' ⇒ ${option.unlocks.join(', ')}';
      buffer.writeln('  $id -->|"${short(option.label)}$unlocks"| $target');
    }
  }
  return buffer.toString();
}
