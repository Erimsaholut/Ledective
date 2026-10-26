import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });

  final String id;
  final String name;

  /// Price in kuruş, to keep sums exact.
  final int price;
  final IconData icon;
}

const List<Product> products = [
  Product(id: 'trench', name: "Trençkot", price: 349900, icon: Icons.checkroom),
  Product(
    id: 'hat',
    name: "Fötr Şapka",
    price: 89900,
    icon: Icons.face_retouching_natural,
  ),
  Product(id: 'loupe', name: "Büyüteç", price: 24950, icon: Icons.search),
  Product(
    id: 'notebook',
    name: "Cep Defteri",
    price: 4990,
    icon: Icons.menu_book,
  ),
  Product(
    id: 'flashlight',
    name: "El Feneri",
    price: 34900,
    icon: Icons.flashlight_on,
  ),
  Product(id: 'catfood', name: "Kedi Maması", price: 39900, icon: Icons.pets),
  Product(id: 'coffee', name: "Filtre Kahve", price: 18500, icon: Icons.coffee),
  Product(
    id: 'powerbank',
    name: "Powerbank",
    price: 74900,
    icon: Icons.battery_charging_full,
  ),
];

/// Formats kuruş as Turkish lira, e.g. `3.499,00 TL`.
String formatLira(int kurus) {
  final lira = (kurus ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '$lira,${(kurus % 100).toString().padLeft(2, '0')} TL';
}

/// An online shop with a cart, a wallet and an order history.
class ShopperApp extends StatefulWidget {
  const ShopperApp({super.key});

  @override
  State<ShopperApp> createState() => _ShopperAppState();
}

class _ShopperAppState extends State<ShopperApp> {
  static const _prefsKey = 'shopper';
  static const _startingBalance = 500000;

  final Map<String, int> _cart = {};
  int _balance = _startingBalance;
  List<({DateTime date, int total, List<String> items})> _orders = [];

  int get _cartTotal => _cart.entries
      .map((e) => products.firstWhere((p) => p.id == e.key).price * e.value)
      .fold(0, (a, b) => a + b);

  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null || !mounted) return;
    final data = json.decode(stored) as Map<String, dynamic>;
    setState(() {
      _balance = data['balance'] as int;
      _orders = [
        for (final order in data['orders'] as List)
          (
            date: DateTime.parse(
              (order as Map<String, dynamic>)['date'] as String,
            ),
            total: order['total'] as int,
            items: (order['items'] as List).cast<String>(),
          ),
      ];
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      json.encode({
        'balance': _balance,
        'orders': [
          for (final o in _orders)
            {
              'date': o.date.toIso8601String(),
              'total': o.total,
              'items': o.items,
            },
        ],
      }),
    );
  }

  void _add(Product product) {
    setState(() => _cart.update(product.id, (n) => n + 1, ifAbsent: () => 1));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text("${product.name} sepete eklendi"),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  Future<void> _checkout(BuildContext sheetContext) async {
    final total = _cartTotal;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(sheetContext);
    if (total > _balance) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Yetersiz bakiye. Ödeme reddedildi.")),
      );
      return;
    }
    setState(() {
      _balance -= total;
      _orders = [
        (
          date: DateTime.now(),
          total: total,
          items: [
            for (final e in _cart.entries)
              "${e.value} x ${products.firstWhere((p) => p.id == e.key).name}",
          ],
        ),
        ..._orders,
      ];
      _cart.clear();
    });
    await _save();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          "Siparişiniz alındı! Yurt dışında olduğunuz için teslimat dönüşünüzde yapılacak.",
        ),
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final entries = _cart.entries.toList();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Sepetim",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text("Sepetiniz boş", textAlign: TextAlign.center),
                    ),
                  for (final entry in entries)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        products.firstWhere((p) => p.id == entry.key).name,
                      ),
                      subtitle: Text("Adet: ${entry.value}"),
                      trailing: IconButton(
                        tooltip: "Çıkar",
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (entry.value > 1) {
                              _cart[entry.key] = entry.value - 1;
                            } else {
                              _cart.remove(entry.key);
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                    ),
                  const Divider(),
                  Text("Toplam: ${formatLira(_cartTotal)}"),
                  Text("Bakiye: ${formatLira(_balance)}"),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: entries.isEmpty
                        ? null
                        : () => _checkout(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Satın Al"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOrders() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text("Siparişlerim"),
            backgroundColor: Colors.white,
          ),
          body: _orders.isEmpty
              ? const Center(child: Text("Henüz siparişiniz yok"))
              : ListView(
                  children: [
                    for (final order in _orders)
                      ListTile(
                        leading: const Icon(Icons.local_shipping),
                        title: Text(order.items.join(", ")),
                        subtitle: Text(
                          "${order.date.day}.${order.date.month}.${order.date.year}"
                          " · Teslimat bekleniyor",
                        ),
                        trailing: Text(formatLira(order.total)),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopper"),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Siparişlerim",
            onPressed: _showOrders,
            icon: const Icon(Icons.receipt_long),
          ),
          IconButton(
            tooltip: "Sepetim",
            onPressed: _showCart,
            icon: Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Bakiye: ${formatLira(_balance)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Icon(
                            product.icon,
                            size: 64,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(formatLira(product.price)),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _add(product),
                            child: const Text("Sepete Ekle"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
