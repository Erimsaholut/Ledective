import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../widgets/avatar.dart';

class MailApp extends StatefulWidget {
  const MailApp({super.key});

  @override
  State<MailApp> createState() => _MailAppState();
}

class _MailAppState extends State<MailApp> {
  static const _countKey = 'mailCount';
  static const _deletedKey = 'deletedMails';
  static const _initialMailCount = 3;

  int _mailCount = _initialMailCount;
  Set<String> _deleted = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final count = prefs.getInt(_countKey);
      if (count != null) {
        _mailCount = count.clamp(0, StoryData.current.inboxMails.length);
      }
      _deleted = {...?prefs.getStringList(_deletedKey)};
    });
  }

  /// Story mails that have arrived, newest first, then the regular inbox
  /// with the most recently received mail on top.
  List<Mail> _inbox(StoryProgress progress) => [
    for (final mail in StoryData.current.storyMails.reversed)
      if (progress.meets(mail.requires)) mail,
    ...StoryData.current.inboxMails.take(_mailCount).toList().reversed,
  ].where((mail) => !_deleted.contains(mail.id)).toList();

  Future<void> _checkForNewMail() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_mailCount >= StoryData.current.inboxMails.length) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text("No new mail")));
      return;
    }
    setState(() => _mailCount++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _mailCount);
  }

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
          content: Text("${mail.sender} deleted"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () => _setDeleted(mail, false),
          ),
        ),
      );
  }

  void _open(Mail mail) {
    StoryProgress.instance.markSeen('mail:${mail.id}');
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _MailPage(mail: mail, onDelete: () => _delete(mail)),
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
          return RefreshIndicator(
            onRefresh: _checkForNewMail,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverAppBar.large(
                  backgroundColor: Colors.white,
                  title: Text("Inbox"),
                ),
                if (inbox.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "Inbox is empty",
                        style: TextStyle(color: AppColors.secondaryLabel),
                      ),
                    ),
                  ),
                SliverList.separated(
                  itemCount: inbox.length,
                  separatorBuilder: (_, _) => const Divider(indent: 72),
                  itemBuilder: (context, index) {
                    final mail = inbox[index];
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
                        title: Text(
                          mail.sender,
                          style: TextStyle(
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          mail.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _open(mail),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "Yeni posta için aşağı çekin",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryLabel,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MailPage extends StatelessWidget {
  const _MailPage({required this.mail, required this.onDelete});

  final Mail mail;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Delete",
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
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text(mail.body, style: const TextStyle(fontSize: 17, height: 1.45)),
        ],
      ),
    );
  }
}
