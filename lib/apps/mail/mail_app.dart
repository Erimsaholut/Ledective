import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_dates.dart';
import '../../widgets/avatar.dart';

/// Mail that arrived and hasn't been opened.
int unreadMailCount(StoryProgress progress) =>
    progress.inbox.where((e) => !progress.hasSeen('mail:${e.$1.id}')).length;

class MailApp extends StatefulWidget {
  const MailApp({super.key});

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  static const _deletedKey = 'deletedMails';

  Set<String> _deleted = {};

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

  /// Mail that has arrived, newest first. New mail comes by itself: some
  /// with the story, the rest now and then while the player plays.
  List<(Mail, DateTime)> _inbox(StoryProgress progress) => [
    for (final entry in progress.inbox)
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
    StoryProgress.instance.markSeen('mail:${mail.id}');
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            _MailPage(mail: mail, time: time, onDelete: () => _delete(mail)),
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
          final inbox = _inbox(progress);
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(
                backgroundColor: Colors.white,
                title: Text("Gelen Kutusu"),
              ),
              if (inbox.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      "Gelen kutusu boş",
                      style: TextStyle(color: AppColors.secondaryLabel),
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
  });

  final Mail mail;
  final DateTime time;
  final VoidCallback onDelete;

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
