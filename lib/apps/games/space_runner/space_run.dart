import 'dart:math';

/// Something falling towards the rocket: an asteroid to dodge or a fuel
/// can to catch.
class SpaceObject {
  SpaceObject({
    required this.x,
    required this.y,
    required this.radius,
    this.isFuel = false,
    this.spin = 0,
  });

  double x;
  double y;
  final double radius;
  final bool isFuel;

  /// Rotation speed in turns per second, for drawing.
  final double spin;
}

enum SpaceRunEnd { crashed, outOfFuel }

/// One run of Uzay Kaçağı. The field is 1 wide and [height] tall, with y
/// growing downwards; the rocket flies near the bottom and everything else
/// falls past it, faster the longer the run lasts.
class SpaceRun {
  SpaceRun({Random? random}) : _random = random ?? Random();

  static const height = 1.6;
  static const rocketY = height - 0.22;
  static const rocketRadius = 0.045;

  /// Seconds of fuel in a full tank.
  static const tankSeconds = 14.0;

  /// Distance shown to the player per unit of field flown.
  static const metresPerUnit = 25.0;

  final Random _random;
  final List<SpaceObject> objects = [];

  double rocketX = 0.5;

  /// -1 to fly left, 1 to fly right, 0 to hold, for keyboard steering.
  int steer = 0;

  /// Fuel left, from 0 to 1.
  double fuel = 1;
  double time = 0;
  double distance = 0;
  int fuelCollected = 0;
  SpaceRunEnd? end;

  double _untilAsteroid = 0.6;
  double _untilFuel = 3;

  bool get isOver => end != null;

  /// Field units per second everything falls at.
  double get speed => 0.55 + min(time, 120) * 0.012;

  int get metres => (distance * metresPerUnit).floor();

  /// Moves the rocket to [x], as a dragging finger does.
  void moveTo(double x) {
    if (!isOver) rocketX = x.clamp(rocketRadius, 1 - rocketRadius);
  }

  /// Advances the run by [dt] seconds.
  void update(double dt) {
    if (isOver) return;
    time += dt;
    distance += speed * dt;
    fuel = max(0, fuel - dt / tankSeconds);
    if (steer != 0) moveTo(rocketX + steer * 1.1 * dt);

    for (final object in objects) {
      object.y += speed * dt * (object.isFuel ? 0.8 : 1);
    }
    objects.removeWhere((o) => o.y - o.radius > height);

    _untilAsteroid -= dt;
    if (_untilAsteroid <= 0) {
      _spawnAsteroid();
      // Asteroids come closer together as the run goes on.
      _untilAsteroid = max(0.28, 0.75 - time * 0.006) * _jitter();
    }
    _untilFuel -= dt;
    if (_untilFuel <= 0) {
      _spawnFuel();
      _untilFuel = (3.2 + time * 0.03) * _jitter();
    }

    for (final object in [...objects]) {
      final dx = object.x - rocketX;
      final dy = object.y - rocketY;
      final reach = object.radius + rocketRadius * 0.8;
      if (dx * dx + dy * dy > reach * reach) continue;
      if (object.isFuel) {
        objects.remove(object);
        fuel = min(1, fuel + 0.35);
        fuelCollected++;
      } else {
        end = SpaceRunEnd.crashed;
        return;
      }
    }
    if (fuel == 0) end = SpaceRunEnd.outOfFuel;
  }

  double _jitter() => 0.7 + _random.nextDouble() * 0.6;

  void _spawnAsteroid() {
    final radius = 0.035 + _random.nextDouble() * 0.05;
    objects.add(
      SpaceObject(
        x: radius + _random.nextDouble() * (1 - 2 * radius),
        y: -radius,
        radius: radius,
        spin: (_random.nextDouble() - 0.5) * 0.6,
      ),
    );
  }

  void _spawnFuel() {
    objects.add(
      SpaceObject(
        x: 0.08 + _random.nextDouble() * 0.84,
        y: -0.04,
        radius: 0.035,
        isFuel: true,
      ),
    );
  }
}
