import 'dialogue.dart';
import 'story_data.dart';

/// The whole story as Markdown tables: every choice and what it leads to,
/// how each flag is reached and what it opens, numbers, missions, timers and
/// the ending. Written to `story/HIKAYE_SEMASI.md` by the validator tool.
String storyTable(StoryData story) => _TableWriter(story).write();

class _TableWriter {
  _TableWriter(this.story);

  final StoryData story;
  final _out = StringBuffer();

  /// Where each flag is set, and where it is waited for.
  final _setBy = <String, List<String>>{};
  final _usedBy = <String, List<String>>{};

  /// Where each number goes up, goes down or is read.
  final _raisedBy = <String, List<String>>{};
  final _loweredBy = <String, List<String>>{};
  final _readBy = <String, List<String>>{};

  void _line([String text = '']) => _out.writeln(text);

  static String _cell(String text, [int max = 0]) {
    var t = text.replaceAll('\n', ' ').replaceAll('|', r'\|').trim();
    if (max > 0 && t.length > max) t = '${t.substring(0, max - 1)}…';
    return t;
  }

  static String _code(String term) => '`${term.trim()}`';

  /// A condition in words.
  String _condition(Condition c) {
    String term(String t) {
      final r = Requirement.parse(t);
      return switch (r) {
        FlagRequirement(:final flag, negated: true) => '${_code(flag)} yokken',
        _ => _code(t),
      };
    }

    final parts = [
      ...c.all.map(term),
      if (c.any.isNotEmpty) '(${c.any.map(term).join(' ya da ')})',
    ];
    return parts.isEmpty ? 'her zaman' : parts.join(' ve ');
  }

  /// Effects in words.
  String _effects(Iterable<String> effects) => effects.isEmpty
      ? '—'
      : effects
            .map(
              (e) => switch (Effect.parse(e)) {
                SetFlag(:final flag) => _code(flag),
                ClearFlag(:final flag) => '${_code(flag)} kapanır',
                ChangeStat(:final stat, :final delta) =>
                  '${_code(stat)} ${delta >= 0 ? '+' : ''}$delta',
                SetStat(:final stat, :final value) => '${_code(stat)} = $value',
              },
            )
            .join(', ');

  void _sets(Iterable<String> effects, String where) {
    for (final e in effects) {
      switch (Effect.parse(e)) {
        case SetFlag(:final flag):
          (_setBy[flag] ??= []).add(where);
        case ClearFlag():
          break;
        case ChangeStat(:final stat, :final delta):
          ((delta >= 0 ? _raisedBy : _loweredBy)[stat] ??= []).add(where);
        case SetStat(:final stat):
          (_raisedBy[stat] ??= []).add(where);
      }
    }
  }

  void _uses(Condition c, String where) {
    for (final t in c.terms) {
      switch (Requirement.parse(t)) {
        case FlagRequirement(:final flag):
          (_usedBy[flag] ??= []).add(where);
        case StatRequirement(:final stat):
          (_readBy[stat] ??= []).add(where);
      }
    }
  }

  String write() {
    _line('# Hikâye şeması');
    _line();
    _line(
      'Bu dosya `assets/story/*.json` dosyalarından üretilir; elle '
      'düzenleme. Güncellemek için:',
    );
    _line();
    _line('```bash');
    _line('dart run tool/validate_story.dart --table');
    _line('```');
    _line();
    _line('Nasıl okunur:');
    _line();
    _line(
      '- **Kişiler:** Her sohbetin adımları. "Ne zaman" o adımın hangi '
      'koşulla geldiğini, "Sonuç" seçeneğin açtığı bayrakları ve '
      'değiştirdiği sayıları gösterir.',
    );
    _line(
      '- **Bayraklar:** Bir bayrağa nasıl ulaşılır, ulaşılınca ne olur. Bir '
      'yolu açmak için ne gerektiğini buradan izle.',
    );
    _line(
      '- **Sayılar:** Güven, baskı, dürüstlük... Hangi seçim artırır, hangisi '
      'azaltır, nerede işe yarar.',
    );
    _line(
      '- Koşullarda "ve" hepsinin, "ya da" birinin gerektiğini; "yokken" o '
      'bayrağın açılmamış olması gerektiğini söyler.',
    );
    _line();
    _line('## İçindekiler');
    _line();
    for (final person in story.conversations.keys) {
      _line('- [$person](#${_anchor(person)})');
    }
    _line(
      '- [Harita görevleri](#harita-görevleri) · '
      '[Laboratuvar](#laboratuvar) · [Para](#para) · '
      '[Süreli olaylar](#süreli-olaylar) · [Kilitler](#kilitler) · '
      '[Final](#final) · [Bayraklar](#bayraklar) · [Sayılar](#sayılar)',
    );
    _line();

    // Sections are written to a side buffer first, so every flag's sources
    // are known when the milestone summary at the top is written.
    final head = _out.toString();
    _out.clear();
    _line('## Kişiler');
    _line();
    for (final MapEntry(key: person, value: c) in story.conversations.entries) {
      _conversation(person, c);
    }
    _map();
    _lab();
    _money();
    _timers();
    _locks();
    _otherSources();
    _ending();
    _flags();
    _numbers();
    final body = _out.toString();
    _out.clear();
    _milestones();
    return '$head${_out.toString()}$body';
  }

  void _milestones() {
    final milestones = story.state.milestones;
    if (milestones.isEmpty) return;
    _line('## Ana yol');
    _line();
    _line(
      'Hikâyenin kilometre taşları sırayla (`state.json › milestones`). '
      'Her aşamaya "Nasıl ulaşılır" sütunundaki yollardan biriyle varılır; '
      'aradaki her şey oyuncunun keşfine kalır.',
    );
    _line();
    _line('| # | Aşama | Bayrak | Nasıl ulaşılır | Neyi açar |');
    _line('| --- | --- | --- | --- | --- |');
    for (final (i, m) in milestones.indexed) {
      String list(List<String>? items) =>
          items == null ? '—' : {...items}.map(_cell).join('<br>');
      _line(
        '| ${i + 1} | ${_cell(m.title)} | ${_code(m.flag)} '
        '| ${list(_setBy[m.flag])} | ${list(_usedBy[m.flag])} |',
      );
    }
    _line();
  }

  static String _anchor(String title) => title
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N} -]', unicode: true), '')
      .replaceAll(' ', '-');

  void _conversation(String person, Conversation c) {
    final dialogue = c.dialogue;
    if (dialogue == null) return;
    _line('### $person');
    _line();

    // How each node is reached by an event from another node.
    final eventsInto = <String, List<Condition>>{};
    for (final node in dialogue.nodes.values) {
      for (final e in node.events) {
        (eventsInto[e.next] ??= []).add(e.requires);
      }
    }

    _line(
      '| Adım | Ne zaman | Karşı taraf yazar | Seçenek | Cevap | Sonuç | Sonra |',
    );
    _line('| --- | --- | --- | --- | --- | --- | --- |');
    final asks = <(String, DialogueOption)>[];
    // A scene that can start from several steps is stored once per step;
    // list it once.
    String scene(DialogueNode n) =>
        [...n.incoming, ...n.options.map((o) => o.label)].join('|');
    final scenes = <String, String>{};
    final repeated = <String>{};
    for (final MapEntry(key: id, value: node) in dialogue.nodes.entries) {
      if (node.incoming.isEmpty || node.options.isEmpty) continue;
      final first = scenes.putIfAbsent(scene(node), () => id);
      if (first != id) repeated.add(first);
    }
    for (final MapEntry(key: id, value: node) in dialogue.nodes.entries) {
      final where = '$person › $id';
      final copyOf = node.incoming.isNotEmpty && node.options.isNotEmpty
          ? scenes[scene(node)]
          : null;
      if (copyOf != null && copyOf != id) {
        // Still counted for the flag tables, just not printed again.
        for (final o in node.options) {
          _sets(o.unlocks, '$person › "${_cell(o.label, 40)}"');
        }
        continue;
      }
      _uses(node.waitFor, where);
      final whens = [
        if (!node.waitFor.isAlways) _condition(node.waitFor),
        for (final c in eventsInto[id] ?? const <Condition>[])
          'kendiliğinden: ${_condition(c)}',
      ];
      for (final e in node.events) {
        _uses(e.requires, '$where (kendiliğinden yazar)');
      }
      final when = whens.isEmpty ? '' : whens.join('<br>');
      final incoming = _cell(node.incoming.join(' / '), 160);
      if (node.options.isEmpty) {
        if (node.incoming.isNotEmpty || when.isNotEmpty) {
          _line('| $id | $when | $incoming | — | | | |');
        }
      }
      for (final (i, o) in node.options.indexed) {
        final at = '$person › "${_cell(o.label, 40)}"';
        _sets(o.unlocks, at);
        _uses(o.requires, at);
        final label = [
          _cell(o.label, 90),
          if (!o.requires.isAlways) '<br>_sadece: ${_condition(o.requires)}_',
        ].join();
        _line(
          '| ${i == 0 ? id : ''} | ${i == 0 ? when : ''} '
          '| ${i == 0 ? incoming : ''} | $label '
          '| ${_cell(o.replies.join(' / '), 120)} '
          '| ${_effects(o.unlocks)} '
          '| ${repeated.contains(id) ? 'geldiği adıma döner' : o.next ?? 'biter'} |',
        );
      }
      for (final o in node.ask) {
        asks.add((id, o));
      }
    }
    _line();

    if (asks.isNotEmpty) {
      _line('**Sorulabilecekler**');
      _line();
      _line('| Soru | Ne zaman sorulabilir | Cevap | Sonuç |');
      _line('| --- | --- | --- | --- |');
      final seen = <String>{};
      for (final (_, o) in asks) {
        final at = '$person › soru "${_cell(o.label, 40)}"';
        _sets(o.unlocks, at);
        _uses(o.requires, at);
        // The same question at several steps is listed once.
        if (!seen.add('${o.label}|${o.replies.join()}')) continue;
        _line(
          '| ${_cell(o.label, 80)}${o.once ? '' : ' (tekrar sorulabilir)'} '
          '| ${_condition(o.requires)} '
          '| ${_cell(o.replies.join(' / '), 140)} | ${_effects(o.unlocks)} |',
        );
      }
      _line();
    }
  }

  void _map() {
    _line('## Harita görevleri');
    _line();
    final officers = story.map.officers;
    _line(
      'Subaylar: ${officers.map((o) => o.requires.isAlways ? o.name : '${o.name} (${_condition(o.requires)})').join(', ')}',
    );
    for (final o in officers) {
      _uses(o.requires, 'Harita › ${o.name} görev alabilir');
    }
    _line();
    _line(
      '| Mekân | Mekân ne zaman görünür | Görev | Görev ne zaman görünür | Süre | Rapor | Sonuç |',
    );
    _line('| --- | --- | --- | --- | --- | --- | --- |');
    for (final l in story.map.locations) {
      _uses(l.requires, 'Harita › ${l.name} görünür');
      for (final (i, t) in l.tasks.indexed) {
        final at = 'Harita › ${l.name} › ${t.label}';
        _uses(t.requires, '$at görünür');
        _sets(t.unlocks, at);
        _line(
          '| ${i == 0 ? l.name : ''} | ${i == 0 ? _condition(l.requires) : ''} '
          '| ${_cell(t.label)} | ${_condition(t.requires)} '
          '| ${t.duration.inMinutes} dk | ${_cell(t.report, 140)} '
          '| ${_effects(t.unlocks)} |',
        );
      }
    }
    _line();
  }

  void _lab() {
    _line('## Laboratuvar');
    _line();
    _line('| Delil | Ne zaman bulunur | İnceleme | Sonuç |');
    _line('| --- | --- | --- | --- |');
    for (final e in story.evidence) {
      _uses(e.requires, 'Pano › ${e.name} bulunur');
      final i = e.inspection;
      if (i != null) _sets(i.unlocks, 'Laboratuvar › ${e.name}');
      _line(
        '| ${_cell(e.name)} | ${_condition(e.requires)} '
        '| ${switch (i) {
          null => '—',
          JigsawInspection() => 'Yapboz',
          FingerprintInspection(:final answer) => 'Parmak izi (cevap: $answer)',
          UvInspection() => 'UV lamba',
        }} | ${i == null ? '—' : _effects(i.unlocks)} |',
      );
    }
    _line();
  }

  void _money() {
    _line('## Para');
    _line();
    _line('| Hareket | Ne zaman gelir | Tutar |');
    _line('| --- | --- | --- |');
    for (final t in story.bank.transactions) {
      if (t.requires.isAlways) continue;
      _uses(t.requires, 'ZaferBank › ${t.title} gelir');
      _line(
        '| ${_cell('${t.title}: ${t.detail}')} | ${_condition(t.requires)} '
        '| ${(t.amount / 100).toStringAsFixed(2)} TL |',
      );
    }
    _line();
    if (story.bank.payees.isNotEmpty) {
      _line('**Para gönderilebilecekler**');
      _line();
      _line('| Alıcı | Ne zaman | En az | Sonuç |');
      _line('| --- | --- | --- | --- |');
      for (final p in story.bank.payees) {
        final at = 'ZaferBank › ${p.name} hesabına para gönder';
        _uses(p.requires, '$at (görünür)');
        _sets([...p.unlocks, 'sent:${p.id}'], at);
        _line(
          '| ${_cell('${p.name} (${p.note})')} | ${_condition(p.requires)} '
          '| ${(p.minAmount / 100).toStringAsFixed(0)} TL '
          '| ${_effects(p.unlocks)}; her gönderim `sent:${p.id}` ve `paid:${p.id}` |',
        );
      }
      _line();
    }
  }

  void _timers() {
    _line('## Süreli olaylar');
    _line();
    _line(
      'Süre sadece oyun açıkken işler; Settings › Hızlı görevler 30 kat hızlandırır.',
    );
    _line();
    _line('| Olay | Başlar | Süre | İptal olur | Sonuç |');
    _line('| --- | --- | --- | --- | --- |');
    for (final t in story.state.timers) {
      final at = 'Süreli olay › ${t.id}';
      _uses(t.when, '$at başlar');
      _uses(t.unless, '$at iptal olur');
      _sets(
        t.unlocks,
        '$at: ${_condition(t.when)} olduktan ${t.duration.inMinutes} dk sonra'
        '${t.unless.isAlways ? '' : ', ${_condition(t.unless)} olmadıysa'}',
      );
      _line(
        '| ${t.id} | ${_condition(t.when)} | ${t.duration.inMinutes} dk '
        '| ${t.unless.isAlways ? '—' : _condition(t.unless)} '
        '| ${_effects(t.unlocks)} |',
      );
    }
    _line();
  }

  void _locks() {
    _line('## Kilitler');
    _line();
    _line('| Uygulama | Kilitlenir | Mesaj |');
    _line('| --- | --- | --- |');
    for (final l in story.state.locks) {
      _uses(l.lockedWhen, '${l.app} kilitlenir');
      _line(
        '| ${l.app} | ${_condition(l.lockedWhen)} | ${_cell(l.message, 100)} |',
      );
    }
    _line();
  }

  /// Everything else that waits for or sets flags, for the flag table.
  void _otherSources() {
    for (final d in story.documents) {
      _uses(d.requires, 'Poltel › ${d.title} gelir');
      _sets(d.unlocksOnView, 'Poltel › ${d.title} açılınca');
    }
    for (final m in story.storyMails) {
      final wait = m.after > Duration.zero
          ? ' (${m.after.inMinutes} dk sonra)'
          : '';
      _uses(m.requires, 'Mail › ${m.sender}$wait');
    }
    for (final m in story.mailPool.mails) {
      if (m.requires.isAlways) continue;
      _uses(m.requires, 'Mail havuzu › ${m.sender} gelebilir');
    }
    for (final t in story.smsThreads) {
      _uses(t.requires, 'Messages › ${t.sender}');
    }
    for (final r in story.recordings) {
      _uses(r.requires, 'Kayıtlar › ${r.from} (${r.id}) gelir');
      _sets(r.unlocksOnListen, 'Kayıtlar › ${r.from} (${r.id}) dinlenince');
    }
    for (final p in story.profiles) {
      _uses(p.requires, 'Sinstagram › @${p.handle} aranabilir');
      _sets(p.unlocksOnView, 'Sinstagram › @${p.handle} açılınca');
    }
    for (final a in [...story.news.articles, ...story.news.filler.articles]) {
      _uses(a.requires, 'News › "${_cell(a.title, 50)}" çıkar');
      _sets(a.unlocksOnRead, 'News › "${_cell(a.title, 50)}" okununca');
    }
  }

  void _ending() {
    _line('## Final');
    _line();
    final endings = story.endings;
    if (endings.sections.isEmpty) {
      _line('Henüz final yok.');
      _line();
      return;
    }
    _uses(endings.requires, 'Final başlar');
    _line(
      'Oyun ${_condition(endings.requires)} olunca biter. Her bölümde '
      'koşulu tutan **ilk** satır anlatılır.',
    );
    _line();
    _line('| Bölüm | Sonuç | Koşul |');
    _line('| --- | --- | --- |');
    for (final s in endings.sections) {
      for (final (i, v) in s.variants.indexed) {
        _uses(
          v.requires,
          'Final › ${s.title}${v.title.isEmpty ? '' : ' › ${v.title}'}',
        );
        _line(
          '| ${i == 0 ? s.title : ''} '
          '| ${_cell([if (v.title.isNotEmpty) '**${v.title}**', v.text].join(' '), 120)} '
          '| ${_condition(v.requires)} |',
        );
      }
    }
    _line();
  }

  void _flags() {
    _line('## Bayraklar');
    _line();
    _line(
      'Bir yolu açmak için: o bayrağın "Nasıl açılır" sütunundaki '
      'yollardan **biri** yeterli.',
    );
    _line();
    _line('| Bayrak | Anlamı | Nasıl açılır | Neyi açar |');
    _line('| --- | --- | --- | --- |');
    final flags = {..._setBy.keys, ..._usedBy.keys}.toList()..sort();
    for (final flag in flags) {
      String list(List<String>? items, String empty) =>
          items == null ? empty : {...items}.map(_cell).join('<br>');
      _line(
        '| ${_code(flag)} | ${_cell(story.state.flags[flag] ?? '')} '
        '| ${list(_setBy[flag], '_henüz hiçbir şey_')} '
        '| ${list(_usedBy[flag], '_henüz hiçbir şey (ileride bağlanacak)_')} |',
      );
    }
    _line();
  }

  void _numbers() {
    _line('## Sayılar');
    _line();
    _line(
      'Oyuncu bu sayıları görmez. Başlangıç değerleri `state.json` içinde.',
    );
    _line();
    _line(
      '| Sayı | Anlamı | Başlangıç | Artıranlar | Azaltanlar | İşe yaradığı yerler |',
    );
    _line('| --- | --- | --- | --- | --- | --- |');
    final stats = {
      ...story.state.stats.keys,
      ..._readBy.keys,
      ..._raisedBy.keys,
      ..._loweredBy.keys,
    }.toList()..sort();
    for (final stat in stats) {
      final def = story.state.stats[stat];
      String list(List<String>? items) =>
          items == null ? '—' : {...items}.map(_cell).join('<br>');
      _line(
        '| ${_code(stat)} | ${_cell(def?.label ?? '')} | ${def?.start ?? 0} '
        '| ${list(_raisedBy[stat])} | ${list(_loweredBy[stat])} '
        '| ${list(_readBy[stat])} |',
      );
    }
    _line();
  }
}
