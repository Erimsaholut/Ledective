import 'dart:math';

import 'package:flutter/material.dart';

class RollTheDice extends StatefulWidget {
  const RollTheDice({super.key, this.random});

  /// Source of randomness; tests pass a seeded one.
  final Random? random;

  @override
  State<RollTheDice> createState() => _RollTheDiceState();
}

class _RollTheDiceState extends State<RollTheDice> {
  static const _faces = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];

  late final Random _random = widget.random ?? Random();
  int _die1 = 1;
  int _die2 = 1;

  void _roll() {
    setState(() {
      _die1 = _random.nextInt(6) + 1;
      _die2 = _random.nextInt(6) + 1;
    });
  }

  Widget _die(int value) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Semantics(
        label: '$value',
        child: ExcludeSemantics(
          child: Text(_faces[value - 1], style: const TextStyle(fontSize: 72)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zar Sallama Oyunu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_die(_die1), _die(_die2)],
            ),
            const SizedBox(height: 20),
            Text(
              'Toplam: ${_die1 + _die2}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _roll,
              child: const Text('Zarları Salla'),
            ),
          ],
        ),
      ),
    );
  }
}
