import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_dates.dart';
import '../../widgets/avatar.dart';

/// Mail in the inbox that hasn't been opened. Spam doesn't count, as on a
/// phone.
int unreadMailCount(StoryProgress progress) => progress.inboxFolder
    .where((e) => !progress.hasSeen('mail:${e.$1.id}'))
    .length;

class MailApp extends StatefulWidget {
  const MailApp({super.key});

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  static const _deletedKey = 'deletedMails';

  Set<String> _deleted = {};

  /// Whether the Spam folder is showing instead of the inbox.
  bool _showSpam = false;

  @override
  void initState() {
    super.initState();
    _load();
    StoryProgress.instance.lookedAt();
  }

  @override
  void dispose() {
    // What came while the inbox was open has been seen too.
    StoryProgress.instance.lookedAt();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _deleted = {...?prefs.getStringList(_deletedKey)});
  }

  /// The folder on screen, newest first. New mail comes by itself: some
  /// with the story, the rest now and then while the player plays.
  List<(Mail, DateTime)> _folder(
    StoryProgress progress, {
    required bool spam,
  }) => [
    for (final entry in spam ? progress.spam : progress.inboxFolder)
      if (!_deleted.contains(entry.$1.id)) entry,
  ];

  Future<void> _setDeleted(Mail mail, bool deleted) async {
    setState(() {
      if (deleted) {
        _deleted.add(mail.id);
      } else {
        _deleted.remove(mail.id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_deletedKey, _deleted.toList());
  }

  void _delete(Mail mail) {
    _setDeleted(mail, true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("${mail.sender} silindi"),
          action: SnackBarAction(
            label: "Geri al",
            onPressed: () => _setDeleted(mail, false),
          ),
        ),
      );
  }

  void _open(Mail mail, DateTime time) {
    final progress = StoryProgress.instance;
    progress.markSeen('mail:${mail.id}', mail.unlocksOnView);
    final inSpam = _showSpam;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _MailPage(
          mail: mail,
          time: time,
          onDelete: () => _delete(mail),
          onNotSpam: inSpam
              ? () => progress.markSeen('notspam:${mail.id}')
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = StoryProgress.instance;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final inbox = _folder(progress, spam: _showSpam);
          final spamCount = _folder(progress, spam: true).length;
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: Colors.white,
                title: Text(_showSpam ? "Spam" : "Gelen Kutusu"),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      const ButtonSegment(
                        value: false,
                        icon: Icon(Icons.inbox_rounded),
                        label: Text("Gelen Kutusu"),
                      ),
                      ButtonSegment(
                        value: true,
                        icon: const Icon(Icons.report_gmailerrorred_rounded),
                        label: Text(
                          spamCount == 0 ? "Spam" : "Spam ($spamCount)",
                        ),
                      ),
                    ],
                    selected: {_showSpam},
                    onSelectionChanged: (choice) =>
                        setState(() => _showSpam = choice.single),
                  ),
                ),
              ),
              if (_showSpam && inbox.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      "Dolandırıcılık gibi görünen mailler ve okuduğun eski "
                      "gündelik mailler buraya düşer. Önemli bir şeyse aç ve "
                      "\"Spam değil\"e dokun.",
                      style: TextStyle(
                        color: AppColors.secondaryLabel,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              if (inbox.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _showSpam ? "Spam klasörü boş" : "Gelen kutusu boş",
                      style: const TextStyle(color: AppColors.secondaryLabel),
                    ),
                  ),
                ),
              SliverList.separated(
                itemCount: inbox.length,
                separatorBuilder: (_, _) => const Divider(indent: 72),
                itemBuilder: (context, index) {
                  final (mail, time) = inbox[index];
                  final unread = !progress.hasSeen('mail:${mail.id}');
                  return Dismissible(
                    key: ValueKey(mail.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _delete(mail),
                    background: Container(
                      color: AppColors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                    ),
                    child: ListTile(
                      tileColor: Colors.white,
                      contentPadding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            child: unread
                                ? const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: AppColors.blue,
                                  )
                                : null,
                          ),
                          Avatar(
                            name: mail.sender,
                            icon: Icons.alternate_email_rounded,
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              mail.sender,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shortStamp(time),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          children: [
                            if (mail.subject.isNotEmpty)
                              TextSpan(
                                text: '${mail.subject}\n',
                                style: TextStyle(
                                  color: AppColors.label,
                                  fontWeight: unread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            TextSpan(text: mail.body),
                          ],
                        ),
                        maxLines: mail.subject.isEmpty ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _open(mail, time),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MailPage extends StatelessWidget {
  const _MailPage({
    required this.mail,
    required this.time,
    required this.onDelete,
    this.onNotSpam,
  });

  final Mail mail;
  final DateTime time;
  final VoidCallback onDelete;

  /// Moves a mail opened from Spam back to the inbox.
  final VoidCallback? onNotSpam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Sil",
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.blue,
            ),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (onNotSpam case final notSpam?) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.report_gmailerrorred_rounded,
                    color: AppColors.secondaryLabel,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: Text("Bu mail Spam klasöründe.")),
                  TextButton(
                    onPressed: () {
                      notSpam();
                      Navigator.pop(context);
                    },
                    child: const Text("Spam değil"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Avatar(name: mail.sender, icon: Icons.alternate_email_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mail.sender,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      "Kime: komiser@emniyet.gov.tr",
                      style: TextStyle(color: AppColors.secondaryLabel),
                    ),
                  ],
                ),
              ),
              Text(
                shortStamp(time),
                style: const TextStyle(color: AppColors.secondaryLabel),
              ),
            ],
          ),
          if (mail.subject.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              mail.subject,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text(mail.body, style: const TextStyle(fontSize: 17, height: 1.45)),
        ],
      ),
    );
  }
}
