import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../poltel/lab/inspection_page.dart';
import 'board_widgets.dart';

/// Evidence the player hasn't looked at yet.
int newEvidenceCount(StoryProgress progress) => _visible(
  progress,
).where((e) => !progress.hasSeen('evidence:${e.id}')).length;

/// New evidence, people and notes on the board, for the home screen badge.
int newBoardCount(StoryProgress progress) =>
    newEvidenceCount(progress) +
    visiblePins(progress).where((p) => _isNew(progress, p)).length;

List<Evidence> _visible(StoryProgress progress) => [
  for (final e in StoryData.current.evidence)
    if (progress.meets(e.requires)) e,
];

/// The people and notes on the board right now.
List<BoardPin> visiblePins(StoryProgress progress) => [
  for (final p in StoryData.current.board.pins)
    if (progress.meets(p.requires)) p,
];

/// A pin is new when it turns up, and again when its question mark gets a
/// name.
String _seenKey(StoryProgress progress, BoardPin pin) =>
    !pin.known.isAlways && progress.meets(pin.known)
    ? 'board:${pin.id}:known'
    : 'board:${pin.id}';

/// Pins that hang there from the start, such as the victim, never are.
bool _isNew(StoryProgress progress, BoardPin pin) =>
    !(pin.requires.isAlways && pin.known.isAlways) &&
    !progress.hasSeen(_seenKey(progress, pin));

/// The last of a pin's stamps that holds now.
String? _stamp(StoryProgress progress, BoardPin pin) {
  String? stamp;
  for (final s in pin.stamps) {
    if (progress.meets(s.requires)) stamp = s.text;
  }
  return stamp;
}

/// A large cork board with the case on it: the people, with a question mark
/// until they are known; the evidence; notes and the night's timeline; and
/// red string between them, labelled. It pans both ways and zooms.
/// Inspections happen in Poltel's lab.
class BoardApp extends StatefulWidget {
  const BoardApp({super.key});

  @override
  State<BoardApp> createState() => _BoardAppState();
}

class _BoardAppState extends State<BoardApp>
    with SingleTickerProviderStateMixin {
  /// Where the player was looking last time, so the board opens there.
  static Matrix4? _lastView;
  static Offset _lastOrigin = Offset.zero;

  /// The board's corner on the whole board, as last drawn.
  Offset? _origin;

  final _view = TransformationController();
  late final _flight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  Animation<Matrix4>? _path;
  Size _screen = Size.zero;

  static const _minScale = 0.15;
  static const _maxScale = 2.5;

  @override
  void initState() {
    super.initState();
    _flight.addListener(() {
      if (_path case final path?) _view.value = path.value;
    });
  }

  @override
  void dispose() {
    _lastView = _view.value.clone();
    _lastOrigin = _origin ?? Offset.zero;
    _flight.dispose();
    _view.dispose();
    super.dispose();
  }

  Matrix4 _looking(Offset at, double scale) {
    final t = Offset(_screen.width / 2, _screen.height / 2) - at * scale;
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, t.dx)
      ..setEntry(1, 3, t.dy);
  }

  double get _scale => _view.value.getMaxScaleOnAxis();

  /// [view] taken on a board whose corner was at [from], moved so the same
  /// cards stay on screen now that the corner is at [to].
  static Matrix4 _moved(Matrix4 view, Offset from, Offset to) {
    final shift = (to - from) * view.getMaxScaleOnAxis();
    return view.clone()
      ..setEntry(0, 3, view.entry(0, 3) + shift.dx)
      ..setEntry(1, 3, view.entry(1, 3) + shift.dy);
  }

  void _fly(Matrix4 to) {
    _path = Matrix4Tween(
      begin: _view.value,
      end: to,
    ).animate(CurvedAnimation(parent: _flight, curve: Curves.easeInOut));
    _flight.forward(from: 0);
  }

  void _zoom(double factor) {
    final scale = (_scale * factor).clamp(_minScale, _maxScale);
    final centre = _view.toScene(Offset(_screen.width / 2, _screen.height / 2));
    _fly(_looking(centre, scale));
  }

  void _fitAll(Size board) {
    final scale = min(
      _screen.width / board.width,
      _screen.height / board.height,
    ).clamp(_minScale, _maxScale);
    _fly(_looking(Offset(board.width / 2, board.height / 2), scale));
  }

  void _openEvidence(Evidence evidence) {
    StoryProgress.instance.markSeen('evidence:${evidence.id}');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EvidenceSheet(evidence: evidence),
    );
  }

  void _openPin(BoardPin pin, _Layout layout) {
    final progress = StoryProgress.instance;
    progress.markSeen(_seenKey(progress, pin));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PinSheet(
        pin: pin,
        layout: layout,
        onGo: (at) {
          Navigator.pop(context);
          _fly(_looking(at.translate(0, 110), max(_scale, 0.8)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF3B2A1C),
        body: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            final layout = _Layout.of(progress);
            return LayoutBuilder(
              builder: (context, constraints) {
                final first = _screen == Size.zero;
                _screen = constraints.biggest;
                if (first) {
                  _view.value = switch (_lastView) {
                    final last? => _moved(last, _lastOrigin, layout.origin),
                    null => _looking(
                      layout.home.translate(0, 120),
                      min(0.7, _screen.width / 500),
                    ),
                  };
                } else if (_origin case final was? when was != layout.origin) {
                  // The board grew while open; keep the cards in place.
                  _flight.stop();
                  _view.value = _moved(_view.value, was, layout.origin);
                }
                _origin = layout.origin;
                return Stack(
                  children: [
                    InteractiveViewer(
                      key: const ValueKey('board-viewer'),
                      transformationController: _view,
                      constrained: false,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      boundaryMargin: const EdgeInsets.all(400),
                      child: _BoardSurface(
                        layout: layout,
                        onEvidence: _openEvidence,
                        onPin: (pin) => _openPin(pin, layout),
                      ),
                    ),
                    _TopBar(
                      title: StoryData.current.board.title,
                      summary: layout.summary,
                    ),
                    Positioned(
                      right: 12,
                      bottom: MediaQuery.paddingOf(context).bottom + 28,
                      child: Column(
                        children: [
                          _RoundButton(
                            key: const ValueKey('board-zoom-in'),
                            icon: Icons.add_rounded,
                            tooltip: "Yakınlaş",
                            onTap: () => _zoom(1.4),
                          ),
                          const SizedBox(height: 8),
                          _RoundButton(
                            key: const ValueKey('board-zoom-out'),
                            icon: Icons.remove_rounded,
                            tooltip: "Uzaklaş",
                            onTap: () => _zoom(1 / 1.4),
                          ),
                          const SizedBox(height: 8),
                          _RoundButton(
                            key: const ValueKey('board-fit'),
                            icon: Icons.zoom_out_map_rounded,
                            tooltip: "Bütün pano",
                            onTap: () => _fitAll(layout.size),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Where everything on the board hangs right now, and what string runs
/// between them.
class _Layout {
  _Layout({
    required this.size,
    required this.origin,
    required this.evidence,
    required this.pins,
    required this.places,
    required this.strings,
    required this.timeline,
    required this.home,
  });

  factory _Layout.of(StoryProgress progress) {
    final board = StoryData.current.board;
    final evidence = _visible(progress);
    final pins = visiblePins(progress);
    final width = board.width > 0 ? board.width : 1200.0;
    var height = board.height > 0 ? board.height : 400.0;

    // Evidence the board file doesn't place goes in rows along the bottom.
    final places = <String, Offset>{};
    var spare = 0;
    final perRow = max(1, (width - 100) ~/ 180);
    for (final e in StoryData.current.evidence) {
      final at = board.places[e.id];
      if (at != null) {
        places[e.id] = Offset(at.$1, at.$2);
      } else {
        places[e.id] = Offset(
          120 + (spare % perRow) * 180,
          height + (spare ~/ perRow) * 250,
        );
        spare++;
      }
    }
    if (spare > 0) height += ((spare - 1) ~/ perRow + 1) * 250 + 40;
    for (final p in board.pins) {
      places[p.id] = Offset(p.x, p.y);
    }

    // The board is only as big as what hangs on it, so its size gives
    // nothing away. It grows as cards turn up, up to the full board.
    final whole = Offset.zero & Size(width, height);
    Rect card(String id, PinKind? kind) {
      final at = places[id]!;
      final w = cardWidth(kind);
      return Rect.fromLTWH(at.dx - w / 2, at.dy - 8, w, _cardHeight(kind));
    }

    final home =
        places[board.pins.firstOrNull?.id] ?? Offset(width / 2, height / 3);
    final cards = [
      for (final e in evidence) card(e.id, null),
      for (final p in pins) card(p.id, p.kind),
      for (final z in board.zones)
        if (progress.meets(z.requires))
          Rect.fromCenter(
            center: Offset(z.x, z.y),
            width: z.label.length * 14.0 + 40,
            height: 44,
          ),
      if (evidence.isEmpty)
        Rect.fromLTWH(home.dx + 140, home.dy + 40, 220, 120),
    ];
    final bounds = _grown(
      cards.fold(cards.first, (a, b) => a.expandToInclude(b)),
      whole,
    );
    final origin = bounds.topLeft;
    places.updateAll((_, at) => at - origin);

    final shown = {...evidence.map((e) => e.id), ...pins.map((p) => p.id)};
    // Strings hang from the pins at the top of each card.
    Offset pinOf(String id) => places[id]!.translate(0, 8);
    final strings = <_String>[
      for (final e in evidence)
        for (final link in e.links)
          if (shown.contains(link)) _String(pinOf(e.id), pinOf(link), ''),
      for (final p in pins)
        for (final link in p.links)
          if (shown.contains(link.to) && progress.meets(link.requires))
            _String(pinOf(p.id), pinOf(link.to), link.label),
    ];
    // The timeline runs between the moments found so far, with an empty
    // notch for each one still missing in between.
    final found = [
      for (final p in pins)
        if (p.kind == PinKind.time) places[p.id]!.dx,
    ];
    final timeline = found.isEmpty
        ? <Offset>[]
        : [
            for (final p in board.pins)
              if (p.kind == PinKind.time &&
                  places[p.id]!.dx >= found.reduce(min) &&
                  places[p.id]!.dx <= found.reduce(max))
                pinOf(p.id),
          ];
    timeline.sort((a, b) => a.dx.compareTo(b.dx));

    return _Layout(
      size: bounds.size,
      origin: origin,
      evidence: evidence,
      pins: pins,
      places: places,
      strings: strings,
      timeline: timeline,
      home: home - origin,
    );
  }

  /// A card's height on the board, near enough to size the board by.
  static double _cardHeight(PinKind? kind) => switch (kind) {
    null => 230,
    PinKind.person => 250,
    PinKind.note => 150,
    PinKind.time => 120,
  };

  /// [cards] with room around them, at least a screen or two big, and
  /// never past the edges of the whole board.
  static Rect _grown(Rect cards, Rect whole) {
    const margin = 120.0;
    var r = cards.inflate(margin);
    r = Rect.fromCenter(
      center: r.center,
      width: max(r.width, min(900.0, whole.width)),
      height: max(r.height, min(1100.0, whole.height)),
    );
    // Slide back inside the board before trimming, so a small board near
    // an edge keeps its size.
    final dx = r.left < whole.left
        ? whole.left - r.left
        : (r.right > whole.right ? whole.right - r.right : 0.0);
    final dy = r.top < whole.top
        ? whole.top - r.top
        : (r.bottom > whole.bottom ? whole.bottom - r.bottom : 0.0);
    return r.shift(Offset(dx, dy)).intersect(whole);
  }

  final Size size;

  /// Where this board's top left corner is on the whole board in
  /// board.json. Everything else here is measured from it.
  final Offset origin;
  final List<Evidence> evidence;
  final List<BoardPin> pins;

  /// The pin at the top of each card, by evidence or pin id.
  final Map<String, Offset> places;
  final List<_String> strings;
  final List<Offset> timeline;

  /// Where the board opens: the first pin, the victim.
  final Offset home;

  String get summary {
    final people = pins.where((p) => p.kind == PinKind.person).length;
    return "$people kişi · ${evidence.length} delil · "
        "${strings.length} bağlantı";
  }

  /// The name a pin or piece of evidence goes by on the board now.
  String nameOf(String id, StoryProgress progress) {
    for (final e in evidence) {
      if (e.id == id) return e.name;
    }
    final pin = StoryData.current.board.pin(id);
    if (pin == null) return id;
    if (pin.kind == PinKind.time) return pin.time;
    if (pin.kind == PinKind.note) return "Not";
    return progress.meets(pin.known) ? pin.name : pin.unknownName;
  }
}

class _String {
  const _String(this.from, this.to, this.label);

  final Offset from;
  final Offset to;
  final String label;
}

class _BoardSurface extends StatelessWidget {
  const _BoardSurface({
    required this.layout,
    required this.onEvidence,
    required this.onPin,
  });

  final _Layout layout;
  final ValueChanged<Evidence> onEvidence;
  final ValueChanged<BoardPin> onPin;

  static double _tilt(String id, double amount) =>
      (Random(id.hashCode).nextDouble() - 0.5) * amount;

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final board = StoryData.current.board;
    Positioned hang(String id, double width, Widget child) {
      final at = layout.places[id]!;
      return Positioned(
        left: at.dx - width / 2,
        top: at.dy - 8,
        width: width,
        child: child,
      );
    }

    return SizedBox.fromSize(
      key: const ValueKey('board-surface'),
      size: layout.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: CorkPainter(origin: layout.origin)),
            ),
          ),
          for (final z in board.zones)
            if (progress.meets(z.requires))
              Positioned(
                left: z.x - layout.origin.dx,
                top: z.y - layout.origin.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: ZoneLabel(z.label),
                ),
              ),
          Positioned.fill(
            child: CustomPaint(
              painter: StringPainter([
                for (final s in layout.strings) (s.from, s.to),
              ], timeline: layout.timeline),
            ),
          ),
          for (final s in layout.strings)
            if (s.label.isNotEmpty)
              Positioned(
                left: sag(s.from, s.to).middle.dx,
                top: sag(s.from, s.to).middle.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: StringTag(s.label),
                ),
              ),
          if (layout.evidence.isEmpty)
            Positioned(
              left: layout.home.dx + 140,
              top: layout.home.dy + 40,
              width: 220,
              child: Transform.rotate(
                angle: 0.04,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  color: const Color(0xFFFFF59D),
                  child: const Text(
                    "Pano boş.\nEkibi sahaya gönder, deliller buraya asılır.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ),
            ),
          for (final e in layout.evidence)
            hang(
              e.id,
              cardWidth(null),
              EvidenceCard(
                key: ValueKey('evidence-${e.id}'),
                evidence: e,
                tilt: _tilt(e.id, 0.12),
                isNew: !progress.hasSeen('evidence:${e.id}'),
                onTap: () => onEvidence(e),
              ),
            ),
          for (final p in layout.pins)
            hang(p.id, cardWidth(p.kind), switch (p.kind) {
              PinKind.person => PersonCard(
                key: ValueKey('pin-${p.id}'),
                pin: p,
                known: progress.meets(p.known),
                stamp: _stamp(progress, p),
                tilt: _tilt(p.id, 0.06),
                isNew: _isNew(progress, p),
                onTap: () => onPin(p),
              ),
              PinKind.note || PinKind.time => NoteCard(
                key: ValueKey('pin-${p.id}'),
                pin: p,
                known: progress.meets(p.known),
                stamp: _stamp(progress, p),
                tilt: _tilt(p.id, p.kind == PinKind.time ? 0.03 : 0.1),
                isNew: _isNew(progress, p),
                onTap: () => onPin(p),
              ),
            }),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC1B120B), Color(0x001B120B)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
          child: Row(
            children: [
              IconButton(
                tooltip: "Back",
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Transform.rotate(
                        angle: -0.02,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          color: const Color(0xFFF5F0E1),
                          child: Text(
                            title.isEmpty ? "DELİLLER" : title,
                            style: typewriter.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      style: typewriter.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE6F5F0E1),
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF3B2A1C)),
      ),
    );
  }
}

/// A person's or note's case file: what is known about them and who they
/// are tied to. Tapping a tie flies the board there.
class _PinSheet extends StatelessWidget {
  const _PinSheet({
    required this.pin,
    required this.layout,
    required this.onGo,
  });

  final BoardPin pin;
  final _Layout layout;
  final ValueChanged<Offset> onGo;

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final known = progress.meets(pin.known);
    final facts = [
      for (final f in pin.facts)
        if (progress.meets(f.requires)) f.text,
    ];
    final hidden = pin.facts.length - facts.length;
    final shown = {
      ...layout.evidence.map((e) => e.id),
      ...layout.pins.map((p) => p.id),
    };
    // Ties both ways: this pin's strings and strings to it.
    final ties = <(String, String)>[
      for (final l in pin.links)
        if (shown.contains(l.to) && progress.meets(l.requires)) (l.to, l.label),
      for (final other in layout.pins)
        for (final l in other.links)
          if (l.to == pin.id && progress.meets(l.requires)) (other.id, l.label),
    ];
    final stamp = _stamp(progress, pin);
    final title = switch (pin.kind) {
      PinKind.person => known ? pin.name : pin.unknownName,
      PinKind.time => "Olay gecesi · ${pin.time}",
      PinKind.note => "Not",
    };
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pin.kind == PinKind.person) ...[
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Mugshot(pin: pin, known: known),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pin.tag.isNotEmpty)
                        Text(
                          pin.tag,
                          style: typewriter.copyWith(
                            color: tagColor(pin.tag),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (pin.kind == PinKind.person)
                        Text(
                          known ? pin.role : pin.unknownRole,
                          style: const TextStyle(
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                      if (stamp != null) ...[
                        const SizedBox(height: 8),
                        Stamp(stamp, size: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (pin.kind != PinKind.person) ...[
              const SizedBox(height: 8),
              Text(known ? pin.role : pin.unknownRole),
            ],
            if (facts.isNotEmpty || hidden > 0) ...[
              const SizedBox(height: 18),
              const _Heading("DOSYA NOTLARI"),
              for (final f in facts)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("—  "),
                      Expanded(child: Text(f)),
                    ],
                  ),
                ),
              if (hidden > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    hidden == 1
                        ? "Bir şey daha var, henüz bilmiyoruz."
                        : "$hidden şey daha var, henüz bilmiyoruz.",
                    style: const TextStyle(
                      color: AppColors.secondaryLabel,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
            if (ties.isNotEmpty) ...[
              const SizedBox(height: 18),
              const _Heading("BAĞLANTILAR"),
              for (final (id, label) in ties)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(
                    Icons.timeline_rounded,
                    color: Color(0xFFD32F2F),
                  ),
                  title: Text(layout.nameOf(id, progress)),
                  subtitle: label.isEmpty ? null : Text(label),
                  trailing: const Icon(Icons.my_location_rounded, size: 18),
                  onTap: () => onGo(layout.places[id]!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: typewriter.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
      fontSize: 12,
      color: AppColors.secondaryLabel,
    ),
  );
}

class _EvidenceSheet extends StatelessWidget {
  const _EvidenceSheet({required this.evidence});

  final Evidence evidence;

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    final inspection = evidence.inspection;
    final done = progress.isInspected(evidence.id);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              evidence.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            // Selectable, so a hidden line can be copied into Şifre Çözücü.
            SelectableText(evidence.description),
            if (evidence.image case final image?
                when inspection == null || done) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image),
              ),
            ],
            if (inspection != null) ...[
              const SizedBox(height: 16),
              if (done)
                Card(
                  color: AppColors.background,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(inspection.result),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => InspectionPage(evidence: evidence),
                      ),
                    );
                  },
                  icon: const Icon(Icons.science_rounded),
                  // Pending inspections go on from here while a suspension
                  // locks Poltel, so the case can't get stuck.
                  label: Text(
                    progress.lockOf('Poltel') == null
                        ? "Poltel Laboratuvarı'nda incele"
                        : "Laboratuvar talebini sürdür",
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
