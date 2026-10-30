import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ciphers.dart';

const _background = Color(0xFF111111);
const _card = Color(0xFF1E1E1E);
const _gold = Color(0xFFFFD60A);

/// Şifre Çözücü from AppShop: writes a message in a cipher or reads one
/// back. For Sezar it can try every shift at once, the way to crack a
/// message when the shift isn't known.
class CipherApp extends StatefulWidget {
  const CipherApp({super.key});

  @override
  State<CipherApp> createState() => _CipherAppState();
}

class _CipherAppState extends State<CipherApp> {
  final _input = TextEditingController();
  Cipher _cipher = Cipher.caesar;
  int _shift = 3;

  /// For Sezar, whether the message is being read rather than written.
  bool _decode = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String get _output =>
      apply(_cipher, _input.text, shift: _decode ? -_shift : _shift);

  void _copy() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Panoya kopyalandı")));
  }

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(color: Colors.white60, fontSize: 13);
    final output = _output;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text("Şifre Çözücü"),
        backgroundColor: _background,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('cipher-input'),
            controller: _input,
            minLines: 3,
            maxLines: 6,
            style: const TextStyle(color: Colors.white, fontSize: 17),
            decoration: InputDecoration(
              hintText: "Mesajı ya da şifreyi yaz…",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: _card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cipher in Cipher.values)
                ChoiceChip(
                  key: ValueKey('cipher-${cipher.name}'),
                  label: Text("${cipher.emoji} ${cipher.title}"),
                  selected: cipher == _cipher,
                  selectedColor: _gold,
                  backgroundColor: _card,
                  labelStyle: TextStyle(
                    color: cipher == _cipher ? Colors.black : Colors.white,
                  ),
                  onSelected: (_) => setState(() => _cipher = cipher),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_cipher.hint, style: label),
          if (_cipher == Cipher.caesar) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text("Kaydırma: $_shift", style: label),
                Expanded(
                  child: Slider(
                    value: _shift.toDouble(),
                    min: 1,
                    max: alphabet.length - 1.0,
                    divisions: alphabet.length - 2,
                    activeColor: _gold,
                    onChanged: (v) => setState(() => _shift = v.round()),
                  ),
                ),
              ],
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text("Şifrele")),
                ButtonSegment(value: true, label: Text("Çöz")),
              ],
              selected: {_decode},
              onSelectionChanged: (choice) =>
                  setState(() => _decode = choice.single),
              style: SegmentedButton.styleFrom(
                foregroundColor: Colors.white,
                selectedBackgroundColor: _gold,
                selectedForegroundColor: Colors.black,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SelectableText(
                    output.isEmpty ? "Sonuç burada görünecek" : output,
                    key: const ValueKey('cipher-output'),
                    style: TextStyle(
                      color: output.isEmpty ? Colors.white38 : _gold,
                      fontSize: 18,
                      fontFamily: _cipher == Cipher.morse ? 'monospace' : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: "Kopyala",
                  onPressed: output.isEmpty ? null : _copy,
                  icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),
          if (_cipher == Cipher.caesar && _input.text.trim().isNotEmpty)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const ValueKey('all-shifts'),
                collapsedIconColor: Colors.white70,
                iconColor: _gold,
                title: const Text(
                  "🕵️ Bütün kaydırmaları dene",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "Kaydırmayı bilmiyorsan anlamlı olanı bul.",
                  style: label,
                ),
                children: [
                  for (var shift = 1; shift < alphabet.length; shift++)
                    ListTile(
                      dense: true,
                      leading: Text("−$shift", style: label),
                      title: Text(
                        caesar(_input.text, -shift),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => setState(() {
                        _shift = shift;
                        _decode = true;
                      }),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
