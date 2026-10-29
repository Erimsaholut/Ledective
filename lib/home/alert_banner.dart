import 'dart:async';

import 'package:flutter/material.dart';

import '../story/story_progress.dart';
import '../theme/app_theme.dart';
import '../theme/turkish_dates.dart';
import '../theme/turkish_text.dart';
import 'start_screen.dart';

/// The phone's notifications: a banner that slides in from the top when
/// something arrives, stacking whatever comes while it is up, and the
/// notification centre that pulls down from the top edge.
class AlertBanner extends StatefulWidget {
  const AlertBanner({super.key, required this.alerts, required this.onOpen});

  final AlertQueue alerts;

  /// Opens what a notification is about.
  final void Function(StoryAlert alert) onOpen;

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner> {
  static const _showFor = Duration(milliseconds: 4500);

  /// What the banner shows, oldest first: everything that came since it
  /// slid in.
  final List<StoryAlert> _burst = [];
  bool _visible = false;
  bool _centreOpen = false;
  Timer? _timer;

  /// How far the current drag has moved down, to tell a pull from a flick.
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    widget.alerts.addListener(_update);
    _update();
  }

  @override
  void dispose() {
    widget.alerts.removeListener(_update);
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    final fresh = widget.alerts.takeFresh();
    final kept = widget.alerts.items.toSet();
    setState(() {
      // Notifications cleared elsewhere, e.g. by opening the chat, go.
      if (!_visible) _burst.clear();
      _burst.removeWhere((a) => !kept.contains(a));
      if (fresh.isNotEmpty && !_centreOpen) {
        _burst.addAll(fresh);
        _visible = true;
      }
      if (_burst.isEmpty) _visible = false;
    });
    if (fresh.isNotEmpty && _visible) {
      _timer?.cancel();
      _timer = Timer(_showFor, _hide);
    }
  }

  void _hide() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _visible = false);
  }

  void _open(StoryAlert alert) {
    widget.alerts.clearGroup(alert.group);
    _hide();
    setState(() => _centreOpen = false);
    widget.onOpen(alert);
  }

  void _openCentre() {
    _hide();
    setState(() => _centreOpen = true);
  }

  void _closeCentre() => setState(() => _centreOpen = false);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        // Pulling down from the top edge opens the notification centre.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: top + 14,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: (_) => _drag = 0,
            onVerticalDragUpdate: (details) => _drag += details.delta.dy,
            onVerticalDragEnd: (details) {
              if (_pulled(details, _drag) > 0) _openCentre();
            },
          ),
        ),
        if (_burst.isNotEmpty) _buildBanner(),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_centreOpen,
            child: AnimatedSlide(
              offset: _centreOpen ? Offset.zero : const Offset(0, -1),
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutCubic,
              child: _NotificationCentre(
                alerts: widget.alerts,
                onOpen: _open,
                onClose: _closeCentre,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    final latest = _burst.last;
    final group = [
      for (final a in _burst)
        if (a.group == latest.group) a,
    ];
    final others = _burst.length - group.length;
    final card = _AlertCard(alerts: group, more: others);
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, -1.6),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        onEnd: () {
          if (!_visible) setState(_burst.clear);
        },
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: GestureDetector(
                onTap: () => _open(latest),
                onVerticalDragStart: (_) => _drag = 0,
                onVerticalDragUpdate: (details) => _drag += details.delta.dy,
                onVerticalDragEnd: (details) {
                  switch (_pulled(details, _drag)) {
                    case > 0:
                      _openCentre();
                    case < 0:
                      _hide();
                  }
                },
                child: _Stacked(layers: others > 0 ? 2 : 0, child: card),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1 for a pull or flick down, -1 for one up, 0 for neither, from a drag
/// that moved [distance] in all.
int _pulled(DragEndDetails details, double distance) {
  final velocity = details.primaryVelocity ?? 0;
  if (velocity > 300 || distance > 40) return 1;
  if (velocity < -300 || distance < -40) return -1;
  return 0;
}

/// [child] with the edges of [layers] more cards peeking out below it, like
/// a pile of notifications.
class _Stacked extends StatelessWidget {
  const _Stacked({
    required this.layers,
    required this.child,
    this.color = const Color(0xD9FFFFFF),
  });

  final int layers;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (layers == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = layers; i >= 1; i--)
          Positioned(
            left: 10.0 * i,
            right: 10.0 * i,
            bottom: -7.0 * i,
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: color.a * (1 - 0.25 * i)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 8),
                ],
              ),
            ),
          ),
        child,
      ],
    );
  }
}

/// How long ago [time] was, the way notifications say it.
String _ago(DateTime time) {
  final minutes = DateTime.now().difference(time).inMinutes;
  if (minutes < 1) return 'şimdi';
  if (minutes < 60) return '$minutes dk önce';
  return shortStamp(time);
}

/// One notification, or a group of them from the same chat or app: the
/// newest on top with the earlier ones' lines under it.
class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alerts, this.more = 0, this.dark = false});

  /// Oldest first; all from the same group.
  final List<StoryAlert> alerts;

  /// Other notifications behind this one.
  final int more;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final latest = alerts.last;
    final icon = homeIcon(latest.app);
    final ink = dark ? Colors.white : AppColors.label;
    final faint = dark ? Colors.white60 : AppColors.secondaryLabel;
    final small = TextStyle(fontSize: 11.5, color: faint);
    final lines = alerts.length > 1
        ? alerts.reversed.take(3).toList().reversed.toList()
        : alerts;
    final count = alerts.length;
    final title = count > 1
        ? '${latest.title} · ${latest.app == 'MatesApp' ? '$count yeni mesaj' : '$count bildirim'}'
        : latest.title;
    return DecoratedBox(
      // No backdrop blur here: inside the sliding transform it can blur the
      // whole screen on some renderers.
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2C2C2E) : const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 18)],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:
                      icon?.colors ??
                      const [Color(0xFF3FA9FF), Color(0xFF0A6CFF)],
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon?.iconData ?? Icons.notifications_rounded,
                color: icon?.glyphColor ?? Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                // Only as tall as its lines: a banner, not a page.
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          turkishUpper(latest.source),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small,
                        ),
                      ),
                      Text(_ago(latest.time), style: small),
                    ],
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: ink,
                    ),
                  ),
                  for (final a in lines)
                    Text(
                      a.body,
                      maxLines: lines.length > 1 ? 1 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: ink, height: 1.3),
                    ),
                  if (count > lines.length)
                    Text('+${count - lines.length} daha', style: small),
                  if (more > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        // In the centre the pile opens with a tap.
                        dark
                            ? '$more bildirim daha'
                            : '$more bildirim daha · görmek için aşağı çek',
                        style: small.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Every notification that hasn't been cleared, grouped by app, newest app
/// first. A group of several shows as a pile until it is tapped open.
class _NotificationCentre extends StatefulWidget {
  const _NotificationCentre({
    required this.alerts,
    required this.onOpen,
    required this.onClose,
  });

  final AlertQueue alerts;
  final void Function(StoryAlert alert) onOpen;
  final VoidCallback onClose;

  @override
  State<_NotificationCentre> createState() => _NotificationCentreState();
}

class _NotificationCentreState extends State<_NotificationCentre> {
  final Set<String> _expanded = {};
  double _drag = 0;

  /// Apps with notifications, the one with the newest first; each app's
  /// notifications newest first.
  List<List<StoryAlert>> _byApp() {
    final apps = <String, List<StoryAlert>>{};
    for (final a in widget.alerts.items.reversed) {
      (apps[a.app] ??= []).add(a);
    }
    return apps.values.toList();
  }

  /// Consecutive notifications of the same chat or kind, newest first.
  List<List<StoryAlert>> _threads(List<StoryAlert> alerts) {
    final threads = <String, List<StoryAlert>>{};
    for (final a in alerts) {
      (threads[a.group] ??= []).add(a);
    }
    return threads.values.toList();
  }

  Widget _card(List<StoryAlert> newestFirst) => Dismissible(
    key: ObjectKey(newestFirst.first),
    onDismissed: (_) {
      for (final a in newestFirst) {
        widget.alerts.remove(a);
      }
    },
    child: GestureDetector(
      onTap: () => widget.onOpen(newestFirst.first),
      child: _AlertCard(alerts: newestFirst.reversed.toList(), dark: true),
    ),
  );

  Widget _app(List<StoryAlert> alerts) {
    final app = alerts.first.app;
    final threads = _threads(alerts);
    final open = _expanded.contains(app) || threads.length == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (threads.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 0, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      app,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (open)
                    TextButton(
                      onPressed: () => setState(() => _expanded.remove(app)),
                      child: const Text("Daha az göster"),
                    ),
                  IconButton(
                    tooltip: "Temizle",
                    visualDensity: VisualDensity.compact,
                    onPressed: () => widget.alerts.clearApp(app),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          if (open)
            for (final thread in threads)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _card(thread),
              )
          else
            GestureDetector(
              onTap: () => setState(() => _expanded.add(app)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _Stacked(
                  layers: threads.length > 2 ? 2 : 1,
                  color: const Color(0xFF2C2C2E),
                  child: AbsorbPointer(
                    child: _AlertCard(
                      alerts: threads.first.reversed.toList(),
                      more: alerts.length - threads.first.length,
                      dark: true,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFC101216),
      child: SafeArea(
        child: GestureDetector(
          onVerticalDragStart: (_) => _drag = 0,
          onVerticalDragUpdate: (details) => _drag += details.delta.dy,
          onVerticalDragEnd: (details) {
            if (_pulled(details, _drag) < 0) widget.onClose();
          },
          child: ListenableBuilder(
            listenable: widget.alerts,
            builder: (context, _) {
              final apps = _byApp();
              final now = DateTime.now();
              return Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    clockTime(now),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    longTurkishDate(now),
                    style: const TextStyle(color: Colors.white70, fontSize: 17),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 8, 6),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Bildirimler",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (apps.isNotEmpty)
                          TextButton(
                            onPressed: widget.alerts.clear,
                            child: const Text("Tümünü temizle"),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: apps.isEmpty
                        ? const Center(
                            child: Text(
                              "Bildirim yok",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            children: [for (final a in apps) _app(a)],
                          ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Bildirimleri kapat',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onClose,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(60, 14, 60, 10),
                        child: Container(
                          width: 134,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
