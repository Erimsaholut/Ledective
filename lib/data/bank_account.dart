import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../story/story_data.dart';
import '../story/story_progress.dart';

/// The detective's ZaferBank account: the starting balance from the story,
/// story transactions as they arrive, and the player's own payments.
class BankAccount extends ChangeNotifier {
  BankAccount._();

  static final BankAccount instance = BankAccount._();

  static const _prefsKey = 'bankPayments';

  final List<BankTransaction> _payments = [];

  BankData get _bank => StoryData.current.bank;

  /// Every transaction the player can see, newest first.
  List<BankTransaction> transactions(StoryProgress progress) => [
    ..._payments,
    for (final t in _bank.transactions)
      if (progress.meets(t.requires)) t,
  ]..sort((a, b) => a.daysAgo.compareTo(b.daysAgo));

  /// Balance in kuruş.
  int balance(StoryProgress progress) {
    var total = _bank.balance;
    for (final t in _bank.transactions) {
      if (!t.requires.isAlways && progress.meets(t.requires)) total += t.amount;
    }
    for (final t in _payments) {
      total += t.amount;
    }
    return total;
  }

  void load(SharedPreferences prefs) {
    _payments.clear();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      for (final item in json.decode(stored) as List) {
        final m = item as Map<String, dynamic>;
        _payments.add(
          BankTransaction(
            id: m['id'] as String,
            title: m['title'] as String,
            detail: m['detail'] as String,
            amount: m['amount'] as int,
          ),
        );
      }
    }
    notifyListeners();
  }

  /// Pays [amount] kuruş. Returns false if the balance is too low.
  Future<bool> pay(String title, String detail, int amount) async {
    if (amount > balance(StoryProgress.instance)) return false;
    _payments.insert(
      0,
      BankTransaction(
        id: 'pay-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        detail: detail,
        amount: -amount,
      ),
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode([
        for (final t in _payments)
          {
            'id': t.id,
            'title': t.title,
            'detail': t.detail,
            'amount': t.amount,
          },
      ]),
    );
    return true;
  }
}
