import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    this.size = 3,
  });

  bool get isAlive => life > 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 200) * dt;
    life -= dt;
  }
}

class ConfettiPiece {
  Offset position;
  Offset velocity;
  double rotation;
  double rotVelocity;
  double life;
  double maxLife;
  Color color;
  double size;

  ConfettiPiece({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotVelocity,
    required this.life,
    required this.maxLife,
    required this.color,
    this.size = 6,
  });

  bool get isAlive => life > 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 150) * dt;
    velocity = Offset(velocity.dx * 0.98, velocity.dy);
    rotation += rotVelocity * dt;
    life -= dt;
  }
}

List<Particle> createExplosionParticles(Offset center, {int count = 30}) {
  final rng = Random();
  return List.generate(count, (i) {
    final angle = rng.nextDouble() * 2 * pi;
    final speed = 50 + rng.nextDouble() * 200;
    return Particle(
      position: center,
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      life: 0.3 + rng.nextDouble() * 0.5,
      maxLife: 0.8,
      color: Color.fromARGB(255, 200 + rng.nextInt(56), rng.nextInt(100), 0),
      size: 2 + rng.nextDouble() * 3,
    );
  });
}

List<ConfettiPiece> createConfettiPieces({int count = 60}) {
  final rng = Random();
  const colors = [
    Colors.red, Colors.blue, Colors.yellow, Colors.green,
    Colors.purple, Colors.orange, Colors.pink, Colors.cyan,
  ];
  return List.generate(count, (i) {
    return ConfettiPiece(
      position: Offset(
        rng.nextDouble() * 400,
        -20 - rng.nextDouble() * 100,
      ),
      velocity: Offset(
        (rng.nextDouble() - 0.5) * 200,
        rng.nextDouble() * 200 + 50,
      ),
      rotation: rng.nextDouble() * 2 * pi,
      rotVelocity: (rng.nextDouble() - 0.5) * 10,
      life: 1.5 + rng.nextDouble() * 2,
      maxLife: 3.5,
      color: colors[rng.nextInt(colors.length)],
      size: 4 + rng.nextDouble() * 4,
    );
  });
}
