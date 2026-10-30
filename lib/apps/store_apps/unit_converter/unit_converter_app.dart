import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../pro_calculator/expression.dart' show formatResult;
import 'units.dart';

/// Birim Çevirici from AppShop: a value in one unit, shown in another and
/// in every unit of its kind.
class UnitConverterApp extends StatefulWidget {
  const UnitConverterApp({super.key});

  @override
  State<UnitConverterApp> createState() => _UnitConverterAppState();
}

class _UnitConverterAppState extends State<UnitConverterApp> {
  static const _green = Color(0xFF0B7A3E);

  final _input = TextEditingController(text: '1');
  Quantity _quantity = Quantity.length;
  late Unit _from = _quantity.units[1];
  late Unit _to = _quantity.units[0];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  double? get _value => double.tryParse(_input.text.replaceAll(',', '.'));

  void _choose(Quantity quantity) {
    setState(() {
      _quantity = quantity;
      _from = quantity.units[1];
      _to = quantity.units[0];
    });
  }

  void _swap() => setState(() {
    final from = _from;
    _from = _to;
    _to = from;
  });

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final result = value == null
        ? "—"
        : formatResult(_quantity.convert(value, _from, _to));
    return Scaffold(
      appBar: AppBar(title: const Text("Birim Çevirici")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final quantity in Quantity.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('quantity-${quantity.name}'),
                      label: Text("${quantity.emoji} ${quantity.title}"),
                      selected: quantity == _quantity,
                      selectedColor: const Color(0xFFD7F5E1),
                      onSelected: (_) => _choose(quantity),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _UnitPicker(
                    units: _quantity.units,
                    value: _from,
                    onChanged: (unit) => setState(() => _from = unit),
                  ),
                  TextField(
                    key: const ValueKey('unit-input'),
                    controller: _input,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(suffixText: _from.symbol),
                    onChanged: (_) => setState(() {}),
                  ),
                  Center(
                    child: IconButton.filledTonal(
                      key: const ValueKey('swap-units'),
                      tooltip: "Birimleri değiştir",
                      onPressed: _swap,
                      icon: const Icon(Icons.swap_vert_rounded),
                    ),
                  ),
                  _UnitPicker(
                    units: _quantity.units,
                    value: _to,
                    onChanged: (unit) => setState(() => _to = unit),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$result ${_to.symbol}",
                    key: const ValueKey('unit-result'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 20, 4, 8),
            child: Text(
              "Bütün birimlerde",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (final unit in _quantity.units)
                  ListTile(
                    dense: true,
                    title: Text(unit.name),
                    trailing: Text(
                      value == null
                          ? "—"
                          : "${formatResult(_quantity.convert(value, _from, unit))} "
                                "${unit.symbol}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Sonuçlar on haneye yuvarlanır.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryLabel, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _UnitPicker extends StatelessWidget {
  const _UnitPicker({
    required this.units,
    required this.value,
    required this.onChanged,
  });

  final List<Unit> units;
  final Unit value;
  final ValueChanged<Unit> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Unit>(
      value: value,
      isExpanded: true,
      underline: const SizedBox(),
      items: [
        for (final unit in units)
          DropdownMenuItem(
            value: unit,
            child: Text("${unit.name} (${unit.symbol})"),
          ),
      ],
      onChanged: (unit) {
        if (unit != null) onChanged(unit);
      },
    );
  }
}
