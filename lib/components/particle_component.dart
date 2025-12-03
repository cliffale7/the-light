import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  Vector2 position;
  Vector2 velocity;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
  });

  void update(double dt) {
    position += velocity * dt;
  }
}

class ParticleComponent extends Component with HasGameReference {
  final List<Particle> particles = [];
  final Random random = Random();
  double lightPercent = 100.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _initializeParticles();
  }

  void _initializeParticles() {
    final size = game.size;
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        position: Vector2(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y,
        ),
        velocity: Vector2(
          (random.nextDouble() - 0.5) * 0.5,
          (random.nextDouble() - 0.5) * 0.5,
        ),
        size: random.nextDouble() * 2,
      ));
    }
  }

  void updateLightPercent(double percent) {
    lightPercent = percent;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final size = game.size;

    for (final particle in particles) {
      particle.update(dt);

      // Bounce off walls
      if (particle.position.x < 0 || particle.position.x > size.x) {
        particle.velocity.x *= -1;
      }
      if (particle.position.y < 0 || particle.position.y > size.y) {
        particle.velocity.y *= -1;
      }

      // Keep particles in bounds
      particle.position.x = particle.position.x.clamp(0, size.x);
      particle.position.y = particle.position.y.clamp(0, size.y);
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (lightPercent / 100) * 0.6;
    final color = Color.fromRGBO(255, 200, 100, opacity);

    for (final particle in particles) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size,
        paint,
      );
    }
  }
}

