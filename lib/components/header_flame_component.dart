import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HeaderFlameComponent extends Component with HasGameReference {
  final Random random = Random();
  double lightPercent = 100.0;
  final List<FlameParticle> flames = [];
  double time = 0.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _initializeFlames();
  }

  void _initializeFlames() {
    // Create flame particles that will animate in the header area
    for (int i = 0; i < 15; i++) {
      flames.add(FlameParticle(
        baseX: random.nextDouble() * 200 - 100, // Center around 0
        baseY: random.nextDouble() * 40 - 20,
        speed: 0.3 + random.nextDouble() * 0.4,
        size: 2 + random.nextDouble() * 4,
        phase: random.nextDouble() * 2 * pi,
      ));
    }
  }

  void updateLightPercent(double percent) {
    lightPercent = percent;
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    
    for (final flame in flames) {
      flame.update(dt, time);
    }
  }

  @override
  void render(Canvas canvas) {
    final intensity = (lightPercent / 100).clamp(0.0, 1.0);
    if (intensity < 0.1) return; // Don't render if light is too low
    
    // Render flames with pulsing effect
    for (final flame in flames) {
      final opacity = intensity * (0.4 + sin(time * 2 + flame.phase) * 0.2);
      final color = Color.lerp(
        Colors.orange.shade600,
        Colors.yellow.shade300,
        (sin(time * 3 + flame.phase) + 1) / 2,
      )?.withValues(alpha: opacity) ?? Colors.orange.shade600;
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, flame.size * 0.5);
      
      canvas.drawCircle(
        Offset(flame.x, flame.y),
        flame.size,
        paint,
      );
    }
  }
}

class FlameParticle {
  final double baseX;
  final double baseY;
  final double speed;
  final double size;
  final double phase;
  double x = 0;
  double y = 0;

  FlameParticle({
    required this.baseX,
    required this.baseY,
    required this.speed,
    required this.size,
    required this.phase,
  });

  void update(double dt, double time) {
    // Gentle floating motion
    x = baseX + sin(time * speed + phase) * 10;
    y = baseY + cos(time * speed * 0.7 + phase) * 8;
  }
}

