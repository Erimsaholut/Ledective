import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/bank_account.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/turkish_text.dart';
import '../shopper/shopper_app.dart' show formatLira;
import 'transfer_page.dart';

const _crimson = Color(0xFFB0122B);

/// Story transactions the player hasn't looked at yet.
int newTransactionCount(StoryProgress progress) => [
  for (final t in StoryData.current.bank.transactions)
    if (!t.requires.isAlways &&
        progress.meets(t.requires) &&
        !progress.hasSeen('bank:${t.id}'))
      t,
].length;

class BankApp extends StatefulWidget {
  const BankApp({super.key});

  @override
  State<BankApp> createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> {
  final StoryProgress _progress = StoryProgress.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final t in StoryData.current.bank.transactions) {
        if (_progress.meets(t.requires)) _progress.markSeen('bank:${t.id}');
      }
    });
  }

  void _transfer() {
    if (availablePayees(_progress).isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Kayıtlı alıcınız bulunmuyor.")),
        );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const TransferPage(color: _crimson),
      ),
    );
  }

  void _unavailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            "Bu işlem yurt dışından yapılamıyor. Lütfen şubenize başvurun.",
          ),
        ),
      );
  }

  void _showTransaction(BankTransaction t) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                formatLira(t.amount.abs()),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: t.amount > 0 ? AppColors.green : AppColors.label,
                ),
              ),
              Text(
                t.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.detail,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryLabel),
              ),
              const SizedBox(height: 8),
              Text(
                t.daysAgo == 0 ? "Bugün" : "${t.daysAgo} gün önce",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bank = StoryData.current.bank;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _crimson,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(
          bank.bank,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_progress, BankAccount.instance]),
        builder: (context, _) {
          final transactions = BankAccount.instance.transactions(_progress);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 190,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A0A12), _crimson, Color(0xFFE0485F)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55B0122B),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            turkishUpper(bank.bank),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.contactless_rounded,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      "Kullanılabilir bakiye",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _progress.breakdown?.money(0) ??
                          formatLira(BankAccount.instance.balance(_progress)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "•••• •••• •••• ${bank.card}",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Text(
                          turkishUpper(bank.owner),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final (icon, label, onTap) in [
                    (Icons.send_rounded, "Para Gönder", _transfer),
                    (Icons.receipt_long_rounded, "Fatura Öde", _unavailable),
                    (Icons.credit_card_rounded, "Kartlarım", _unavailable),
                  ])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: onTap,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                children: [
                                  Icon(icon, color: _crimson),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "IBAN: ${bank.iban}",
                style: const TextStyle(
                  color: AppColors.secondaryLabel,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Hesap Hareketleri",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < transactions.length; i++) ...[
                      if (i > 0) const Divider(indent: 64),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transactions[i].amount > 0
                              ? const Color(0xFFE3F6E8)
                              : const Color(0xFFF2F2F7),
                          child: Icon(
                            transactions[i].amount > 0
                                ? Icons.south_west_rounded
                                : Icons.north_east_rounded,
                            color: transactions[i].amount > 0
                                ? AppColors.green
                                : AppColors.label,
                          ),
                        ),
                        title: Text(transactions[i].title),
                        subtitle: Text(
                          transactions[i].detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          "${transactions[i].amount > 0 ? '+' : '-'}${formatLira(transactions[i].amount.abs())}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: transactions[i].amount > 0
                                ? AppColors.green
                                : AppColors.label,
                          ),
                        ),
                        onTap: () => _showTransaction(transactions[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
