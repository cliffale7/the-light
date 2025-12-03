import 'package:flutter/material.dart';
import 'dart:math';

class RebirthSequence extends StatefulWidget {
  final int rebornCount;
  final int sacrifices;
  final double darkness;
  final Function() onComplete;

  const RebirthSequence({
    super.key,
    required this.rebornCount,
    required this.sacrifices,
    required this.darkness,
    required this.onComplete,
  });

  @override
  State<RebirthSequence> createState() => _RebirthSequenceState();
}

class _RebirthSequenceState extends State<RebirthSequence>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  late AnimationController _textController;

  int _currentStage = 0;
  final List<String> _stages = [
    "Everything fades...",
    "The void consumes all...",
    "But something remains...",
    "A spark in the darkness...",
    "The accumulated strength of every struggle...",
    "Every sacrifice...",
    "Every moment you chose to continue...",
    "It all matters.",
    "It all feeds forward.",
    "You are reborn.",
    "Not erased.",
    "Transformed.",
    "The light returns.",
    "And you carry it forward.",
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _startSequence();
  }

  void _startSequence() {
    _fadeController.forward();
    _scaleController.forward();
    _rotateController.repeat();

    // Progress through stages
    Future.delayed(const Duration(milliseconds: 500), () {
      _nextStage();
    });
  }

  void _nextStage() {
    if (_currentStage < _stages.length - 1) {
      setState(() {
        _currentStage++;
      });
      _textController.reset();
      _textController.forward();

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _nextStage();
        }
      });
    } else {
      // Final stage - hold for a moment, then complete
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          widget.onComplete();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeController,
        _scaleController,
        _rotateController,
        _particleController,
      ]),
      builder: (context, child) {
        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Particle effects
              _buildParticles(),

              // Central sun/flame
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rotating sun with pulsing glow
                    Transform.scale(
                      scale: _scaleController.value * 0.8 + 0.2,
                      child: Transform.rotate(
                        angle: _rotateController.value * 2 * pi,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.yellow.shade300,
                                Colors.orange.shade600,
                                Colors.red.shade900,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.shade300
                                    .withValues(alpha: 0.8),
                                blurRadius: 100 * _scaleController.value,
                                spreadRadius: 20 * _scaleController.value,
                              ),
                              BoxShadow(
                                color: Colors.orange.shade600
                                    .withValues(alpha: 0.6),
                                blurRadius: 150 * _scaleController.value,
                                spreadRadius: 30 * _scaleController.value,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.wb_sunny,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Stage text
                    FadeTransition(
                      opacity: _textController,
                      child: Text(
                        _stages[_currentStage],
                        style: TextStyle(
                          fontSize: _getFontSize(),
                          color: _getTextColor(),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.yellow.shade300
                                  .withValues(alpha: 0.8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Cycle count
                    if (_currentStage >= _stages.length - 3)
                      FadeTransition(
                        opacity: _textController,
                        child: Text(
                          'Cycle ${widget.rebornCount}',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.yellow.shade200,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Radial light rays
              _buildLightRays(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return CustomPaint(
      painter: ParticlePainter(
        animation: _particleController.value,
        count: 100,
        rebornCount: widget.rebornCount,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildLightRays() {
    return CustomPaint(
      painter: LightRayPainter(
        animation: _rotateController.value,
        intensity: _scaleController.value,
      ),
      size: Size.infinite,
    );
  }

  double _getFontSize() {
    if (_currentStage >= _stages.length - 3) {
      return 32;
    }
    return 28;
  }

  Color _getTextColor() {
    if (_currentStage < 3) {
      return Colors.grey.shade400;
    } else if (_currentStage < 7) {
      return Colors.orange.shade300;
    } else {
      return Colors.yellow.shade200;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double animation;
  final int count;
  final int rebornCount;

  ParticlePainter({
    required this.animation,
    required this.count,
    required this.rebornCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42);

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi + animation * 2 * pi;
      final distance = 100 + (random.nextDouble() * 300);
      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      final opacity = (0.3 + random.nextDouble() * 0.7) *
          (0.5 + sin(animation * 2 * pi + i) * 0.5);
      final color = Colors.yellow.shade300.withValues(alpha: opacity);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final radius = 2 + (rebornCount * 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

class LightRayPainter extends CustomPainter {
  final double animation;
  final double intensity;

  LightRayPainter({
    required this.animation,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rayCount = 12;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * pi + animation * 2 * pi;
      final rayLength = 400 * intensity;

      final paint = Paint()
        ..color = Colors.yellow.shade300.withValues(
          alpha: (0.2 * intensity) * (0.7 + sin(animation * 4 * pi + i) * 0.3),
        )
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final endX = center.dx + cos(angle) * rayLength;
      final endY = center.dy + sin(angle) * rayLength;

      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LightRayPainter oldDelegate) {
    return animation != oldDelegate.animation || intensity != oldDelegate.intensity;
  }
}


