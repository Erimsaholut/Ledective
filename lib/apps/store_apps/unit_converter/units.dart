/// A unit of measure, converted through its kind's base unit.
class Unit {
  const Unit(this.name, this.symbol, this.factor, {this.offset = 0});

  final String name;
  final String symbol;

  /// How many base units one of this is, and what is added after scaling;
  /// only temperatures need an offset.
  final double factor;
  final double offset;

  double toBase(double value) => value * factor + offset;
  double fromBase(double value) => (value - offset) / factor;
}

/// Something to measure, with the units it can be given in. The first
/// unit is the base: metres, kilograms, kelvins, square metres, litres
/// and metres per second.
enum Quantity {
  length("Uzunluk", '📏', [
    Unit("Metre", "m", 1),
    Unit("Kilometre", "km", 1000),
    Unit("Santimetre", "cm", 0.01),
    Unit("Milimetre", "mm", 0.001),
    Unit("Mil", "mi", 1609.344),
    Unit("Yarda", "yd", 0.9144),
    Unit("Fit", "ft", 0.3048),
    Unit("İnç", "in", 0.0254),
  ]),
  weight("Ağırlık", '⚖️', [
    Unit("Kilogram", "kg", 1),
    Unit("Gram", "g", 0.001),
    Unit("Ton", "t", 1000),
    Unit("Pound", "lb", 0.45359237),
    Unit("Ons", "oz", 0.028349523125),
  ]),
  temperature("Sıcaklık", '🌡️', [
    Unit("Kelvin", "K", 1),
    Unit("Santigrat", "°C", 1, offset: 273.15),
    Unit("Fahrenhayt", "°F", 5 / 9, offset: 273.15 - 32 * 5 / 9),
  ]),
  area("Alan", '🟩', [
    Unit("Metrekare", "m²", 1),
    Unit("Dönüm", "dönüm", 1000),
    Unit("Hektar", "ha", 10000),
    Unit("Kilometrekare", "km²", 1e6),
    Unit("Fitkare", "ft²", 0.09290304),
  ]),
  volume("Hacim", '🧪', [
    Unit("Litre", "L", 1),
    Unit("Mililitre", "mL", 0.001),
    Unit("Metreküp", "m³", 1000),
    Unit("Su bardağı", "bardak", 0.2),
    Unit("Galon (ABD)", "gal", 3.785411784),
  ]),
  speed("Hız", '🏎️', [
    Unit("Metre/saniye", "m/s", 1),
    Unit("Kilometre/saat", "km/sa", 1 / 3.6),
    Unit("Mil/saat", "mph", 0.44704),
    Unit("Knot", "kn", 0.514444),
  ]);

  const Quantity(this.title, this.emoji, this.units);

  final String title;
  final String emoji;
  final List<Unit> units;

  double convert(double value, Unit from, Unit to) =>
      to.fromBase(from.toBase(value));
}
