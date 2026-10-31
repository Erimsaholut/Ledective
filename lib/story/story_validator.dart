import '../apps/store_apps/cipher/ciphers.dart';
import 'dialogue.dart';
import 'story_data.dart';

/// Home screen apps, the names `state.json › locks` can close.
const appNames = [
  'Mail', 'Photos', 'Camera', 'Calendar', 'Clock', 'Poltel', 'Harita', //
  'Pano', 'Notes', 'Sinstagram', 'ZaferBank', 'Kayıtlar', 'News', //
  'Settings', 'Games', 'Music', 'Pian', 'Shopper', 'AppShop', 'Phone', //
  'Messages', 'MatesApp', 'Contacts', 'Hesap Makinesi',
];

enum IssueLevel {
  /// Breaks the game.
  error('HATA'),

  /// Probably a mistake.
  warning('UYARI'),

  /// Planned but not written yet.
  note('NOT');

  const IssueLevel(this.label);
  final String label;
}

/// A problem found in the story files.
class StoryIssue {
  const StoryIssue(this.where, this.message, {this.level = IssueLevel.error});

  final String where;
  final String message;
  final IssueLevel level;

  bool get isError => level == IssueLevel.error;

  @override
  String toString() => '${level.label}  $where: $message';
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
      issues.add(StoryIssue(where, message, level: IssueLevel.warning));
  void note(String where, String message) =>
      issues.add(StoryIssue(where, message, level: IssueLevel.note));

  // Flags that something sets, and flags that something waits for.
  final set = <String, String>{};
  final used = <String, String>{};
  final usedNegated = <String, String>{};
  // Numbers that something changes or checks.
  final statsChanged = <String>{};
  final statsRead = <String>{};
  final payeeIds = {for (final p in story.bank.payees) p.id};
  final traitNames = {
    for (final t in Trait.values) ...[t.name, t.label.toLowerCase()],
  };

  bool knownStat(String stat, String where, {required bool write}) {
    if (story.state.stats.containsKey(stat)) return true;
    final (prefix, name) = switch (stat.indexOf(':')) {
      -1 => ('', stat),
      final i => (stat.substring(0, i), stat.substring(i + 1)),
    };
    final derived =
        (prefix == 'trait' && traitNames.contains(name.toLowerCase())) ||
        (prefix == 'paid' && payeeIds.contains(name));
    if (derived && !write) return true;
    error(
      where,
      derived
          ? '"$stat" kendiliğinden hesaplanır, değiştirilemez'
          : '"$stat" sayısı state.json › stats içinde tanımlı değil',
    );
    return false;
  }

  void sets(Iterable<String> effects, String where) {
    for (final term in effects) {
      switch (Effect.parse(term)) {
        case SetFlag(:final flag):
          set.putIfAbsent(flag, () => where);
        case ClearFlag():
          break;
        case ChangeStat(:final stat) || SetStat(:final stat):
          if (knownStat(stat, where, write: true)) statsChanged.add(stat);
      }
    }
  }

  void uses(Condition c, String where) {
    for (final term in c.terms) {
      switch (Requirement.parse(term)) {
        case FlagRequirement(:final flag, :final negated):
          (negated ? usedNegated : used).putIfAbsent(flag, () => where);
        case StatRequirement(:final stat):
          if (knownStat(stat, where, write: false)) statsRead.add(stat);
      }
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
      pending.addAll(node.events.map((e) => e.next));
    }
    for (final MapEntry(key: id, value: node) in dialogue.nodes.entries) {
      final at = '$where › $id';
      if (!reached.contains(id)) warn(at, 'bu düğüme hiçbir seçenek gitmiyor');
      if (node.options.isEmpty &&
          node.incoming.isEmpty &&
          node.ask.isEmpty &&
          !node.waitFor.isAlways) {
        warn(at, 'bir şey bekliyor ama bekledikten sonra hiçbir şey olmuyor');
      }
      uses(node.waitFor, at);
      for (final event in node.events) {
        if (!dialogue.nodes.containsKey(event.next)) {
          error(at, 'bir olay olmayan "${event.next}" düğümüne gidiyor');
        }
        if (event.requires.isAlways) {
          warn(at, '"${event.next}" olayının koşulu yok: hemen gerçekleşir');
        }
        uses(event.requires, at);
      }
      for (final option in node.ask) {
        if (option.next != null) {
          warn(at, '"${option.label}" bir soru; "next" kullanılmaz');
        }
        uses(option.requires, at);
        sets(option.unlocks, at);
      }
      for (final option in node.options) {
        uses(option.requires, at);
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
  final documentIds = <String>{};
  for (final d in story.documents) {
    final where = 'documents.json › ${d.id}';
    if (!documentIds.add(d.id)) error(where, 'bu kimlik iki kez kullanılmış');
    uses(d.requires, where);
    sets(d.unlocksOnView, where);
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
  final mailIds = <String>{};
  for (final m in story.storyMails) {
    final where = 'mails.json › story › ${m.sender}';
    uses(m.requires, where);
    sets(m.unlocksOnView, where);
    if (!mailIds.add(m.id)) error(where, 'aynı mail iki kez var');
    if (m.after.isNegative) error(where, '"afterMinutes" eksi olamaz');
  }
  final pool = story.mailPool;
  for (final m in pool.mails) {
    final where = 'mails.json › pool › ${m.id}';
    uses(m.requires, where);
    sets(m.unlocksOnView, where);
    if (!mailIds.add(m.id)) error(where, 'aynı mail iki kez var');
    if (m.after != Duration.zero) {
      error(where, 'havuzdaki maillerde "afterMinutes" olmaz');
    }
    if (m.spam && (!m.requires.isAlways || m.unlocksOnView.isNotEmpty)) {
      warn(where, 'hikâyeye bağlı mail spam olmaz, "spam" yok sayılır');
    }
  }
  if (pool.minMinutes < 1 || pool.maxMinutes < pool.minMinutes) {
    error(
      'mails.json › pool',
      '"minMinutes" en az 1, "maxMinutes" da en az "minMinutes" olmalı',
    );
  }
  for (final t in story.smsThreads) {
    uses(t.requires, 'sms.json › ${t.sender}');
    sets(t.unlocksOnView, 'sms.json › ${t.sender}');
  }
  for (final t in story.bank.transactions) {
    uses(t.requires, 'bank.json › ${t.id}');
  }
  for (final p in story.bank.payees) {
    final where = 'bank.json › payees › ${p.id}';
    uses(p.requires, where);
    sets(p.unlocks, where);
    // Set by every transfer; fine if nothing waits for it.
    set.putIfAbsent('sent:${p.id}', () => '');
  }
  if (payeeIds.length != story.bank.payees.length) {
    error('bank.json › payees', 'aynı kimlikle iki alıcı var');
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
    asset(l.image, where);
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
  for (final o in story.map.officers) {
    uses(o.requires, 'map.json › officers › ${o.name}');
  }

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
    if (e.code case final code?) {
      sets(code.unlocks, '$where › code');
      final cipher = Cipher.values
          .where((c) => c.name == code.cipher)
          .firstOrNull;
      if (cipher == null) {
        error(
          where,
          '"${code.cipher}" diye bir şifre yok '
          '(${Cipher.values.map((c) => c.name).join(', ')})',
        );
      } else {
        final hidden = apply(cipher, code.text, shift: code.shift);
        if (!e.description.contains(hidden)) {
          error(where, 'açıklamada şifreli satır yok, şöyle olmalı: "$hidden"');
        }
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

  // News.
  final outletIds = {for (final o in story.news.outlets) o.id};
  final articleIds = <String>{};
  final filler = story.news.filler;
  for (final a in [...story.news.articles, ...filler.articles]) {
    final where = 'news.json › ${a.id}';
    final isFiller = filler.articles.contains(a);
    if (isFiller &&
        (a.archive || a.dayOffset != null || a.after != Duration.zero)) {
      error(
        where,
        'zamansız haberde "archive", "dayOffset" ya da "afterMinutes" olmaz',
      );
    }
    if (a.after.isNegative) error(where, '"afterMinutes" eksi olamaz');
    if ((a.dayOffset ?? 0) < 0) error(where, '"dayOffset" eksi olamaz');
    if (a.hour < 0 || a.hour > 23) {
      error(where, '"hour" 0 ile 23 arasında olmalı');
    }
    if (!articleIds.add(a.id)) error(where, 'bu kimlik iki kez kullanılmış');
    if (!outletIds.contains(a.outlet)) {
      error(where, '"${a.outlet}" diye bir yayın organı yok (outlets)');
    }
    uses(a.requires, where);
    sets(a.unlocksOnRead, where);
    asset(a.image, where);
    if (a.body.isEmpty && a.summary.isEmpty) warn(where, 'haberin metni yok');
  }

  if (filler.minMinutes < 1 || filler.maxMinutes < filler.minMinutes) {
    error(
      'news.json › filler',
      '"minMinutes" en az 1, "maxMinutes" da en az "minMinutes" olmalı',
    );
  }

  // State: locks, timers, hints.
  for (final l in story.state.locks) {
    final where = 'state.json › locks › ${l.app}';
    if (!appNames.contains(l.app)) {
      error(where, '"${l.app}" diye bir uygulama yok (${appNames.join(', ')})');
    }
    if (l.lockedWhen.isAlways) error(where, '"lockedWhen" gerekli');
    uses(l.lockedWhen, where);
  }
  final timerIds = <String>{};
  for (final t in story.state.timers) {
    final where = 'state.json › timers › ${t.id}';
    if (!timerIds.add(t.id)) error(where, 'bu kimlik iki kez kullanılmış');
    if (t.when.isAlways) warn(where, '"when" yok: oyunun başında başlar');
    uses(t.when, where);
    uses(t.unless, where);
    sets(t.unlocks, where);
    if (t.unlocks.isEmpty) warn(where, 'süre dolunca hiçbir şey olmuyor');
  }
  for (final h in story.state.hints) {
    final where = 'state.json › hints › ${h.id}';
    if (!timerIds.add(h.id)) error(where, 'bu kimlik iki kez kullanılmış');
    if (h.when.isAlways) warn(where, '"when" yok: oyunun başında başlar');
    if (h.unless.isAlways) {
      warn(where, '"unless" yok: oyuncu zaten yapmış olsa da ipucu gelir');
    }
    final app = h.alert!.app;
    if (!appNames.contains(app)) {
      error(where, '"$app" diye bir uygulama yok (${appNames.join(', ')})');
    }
    uses(h.when, where);
    uses(h.unless, where);
  }

  // Endings.
  final endings = story.endings;
  if (endings.secret case final secret?) {
    const where = 'endings.json › secret';
    uses(secret.requires, where);
    // The breakdown sets the finale; listening to the last recording sets
    // the flag that ends the game.
    sets([secret.finale], '$where (bozulma bitince)');
    uses(Condition(all: [secret.endsWith]), '$where (oyunu bitirir)');
    if (secret.paragraphs.isEmpty) warn(where, 'gizli sonun metni yok');
  }
  if (endings.sections.isNotEmpty) {
    uses(endings.requires, 'endings.json');
    if (endings.requires.isAlways) {
      error('endings.json', '"requires" yok: oyun açılır açılmaz biter');
    }
  }
  for (final section in endings.sections) {
    final where = 'endings.json › ${section.id}';
    if (section.variants.isEmpty) error(where, 'hiç "variants" yok');
    for (final (i, v) in section.variants.indexed) {
      uses(v.requires, '$where › ${v.title.isEmpty ? '${i + 1}' : v.title}');
    }
    if (section.variants.isNotEmpty &&
        !section.variants.last.requires.isAlways) {
      warn(where, 'son seçeneğin koşulu var; hiçbiri tutmazsa bölüm boş kalır');
    }
  }

  for (final m in story.state.milestones) {
    used.putIfAbsent(m.flag, () => 'state.json › milestones › ${m.title}');
  }

  // Numbers.
  for (final stat in story.state.stats.keys) {
    final where = 'state.json › stats › $stat';
    if (!statsChanged.contains(stat)) {
      warn(where, 'hiçbir şey bu sayıyı değiştirmiyor');
    } else if (!statsRead.contains(stat)) {
      warn(where, 'hiçbir koşul bu sayıya bakmıyor');
    }
  }

  // Flags.
  final planned = story.state.flags;
  for (final MapEntry(key: flag, value: where) in used.entries) {
    if (set.containsKey(flag)) continue;
    if (planned.containsKey(flag)) {
      note(where, '"$flag" planlanmış, henüz hiçbir şey onu açmıyor');
    } else {
      error(where, '"$flag" bayrağını bekliyor ama hiçbir şey onu açmıyor');
    }
  }
  for (final MapEntry(key: flag, value: where) in usedNegated.entries) {
    if (!set.containsKey(flag) && !planned.containsKey(flag)) {
      warn(where, '"!$flag" hep doğru: hiçbir şey "$flag" bayrağını açmıyor');
    }
  }
  for (final MapEntry(key: flag, value: where) in set.entries) {
    if (where.isEmpty) continue;
    if (!used.containsKey(flag) && !usedNegated.containsKey(flag)) {
      note(where, '"$flag" açılıyor, henüz hiçbir şey onu beklemiyor');
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
        : '<br/><i>bekler: ${node.waitFor.terms.join(', ')}</i>';
    final incoming = node.incoming.isEmpty
        ? ''
        : '<br/>${short(node.incoming.first)}';
    final ask = node.ask.isEmpty ? '' : '<br/>❓ ${node.ask.length} soru';
    buffer.writeln('  $id["<b>$id</b>$wait$incoming$ask"]');
    for (var i = 0; i < node.options.length; i++) {
      final option = node.options[i];
      final target = option.next ?? '${id}_end$i';
      if (option.next == null) buffer.writeln('  $target(((son)))');
      final unlocks = option.unlocks.isEmpty
          ? ''
          : ' ⇒ ${option.unlocks.join(', ')}';
      buffer.writeln('  $id -->|"${short(option.label)}$unlocks"| $target');
    }
    for (final event in node.events) {
      buffer.writeln(
        '  $id -.->|"⚡ ${esc(event.requires.terms.join(', '))}"| ${event.next}',
      );
    }
  }
  return buffer.toString();
}
