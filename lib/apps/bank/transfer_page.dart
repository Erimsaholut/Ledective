import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/bank_account.dart';
import '../../story/story_data.dart';
import '../../story/story_progress.dart';
import '../../theme/app_theme.dart';
import '../shopper/shopper_app.dart' show formatLira;

/// Payees the player can send money to right now.
List<Payee> availablePayees(StoryProgress progress) => [
  for (final p in StoryData.current.bank.payees)
    if (progress.meets(p.requires)) p,
];

/// Sends money to a payee from `bank.json`. Transfers can't be undone, and
/// what the player writes as the description stays on the record.
class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.color});

  final Color color;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final StoryProgress _progress = StoryProgress.instance;
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _description = TextEditingController();
  Payee? _payee;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  /// The amount typed in, in kuruş.
  int get _kurus {
    final text = _amount.text.replaceAll('.', '').replaceAll(',', '.');
    return ((double.tryParse(text) ?? 0) * 100).round();
  }

  Future<void> _send() async {
    final payee = _payee;
    final amount = _kurus;
    if (payee == null || amount <= 0) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Transferi onayla"),
        content: Text(
          "${formatLira(amount)} tutarı ${payee.name} hesabına gönderilecek. "
          "Bu işlem geri alınamaz.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Vazgeç"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Gönder"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final description = _description.text.trim();
    final sent = await BankAccount.instance.pay(
      payee.name,
      description.isEmpty ? "Para transferi" : "Açıklama: '$description'",
      amount,
    );
    if (!mounted) return;
    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bakiyeniz bu işlem için yetersiz.")),
      );
      return;
    }
    final refunded = await _progress.recordTransfer(payee, amount);
    if (refunded > 0) {
      await BankAccount.instance.receive(
        payee.name,
        "Gelen EFT · İade",
        refunded,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          refunded > 0
              ? "${formatLira(amount)} gönderildi, ${payee.name} geri gönderdi."
              : "${formatLira(amount)} gönderildi.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payees = availablePayees(_progress);
    final balance = BankAccount.instance.balance(_progress);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text("Para Gönder", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "ALICI",
            style: TextStyle(color: AppColors.secondaryLabel, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Card(
            clipBehavior: Clip.antiAlias,
            child: RadioGroup<Payee>(
              groupValue: _payee,
              onChanged: (p) => setState(() => _payee = p),
              child: Column(
                children: [
                  for (final p in payees)
                    RadioListTile<Payee>(
                      value: p,
                      title: Text(p.name),
                      subtitle: Text(
                        [p.note, p.iban].where((t) => t.isNotEmpty).join("\n"),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
            ],
            decoration: InputDecoration(
              labelText: "Tutar (TL)",
              helperText: "Kullanılabilir bakiye: ${formatLira(balance)}",
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: "Açıklama",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: widget.color,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: _payee != null && _kurus > 0 ? _send : null,
            child: const Text("Gönder"),
          ),
        ],
      ),
    );
  }
}
