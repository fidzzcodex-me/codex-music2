import 'dart:math';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key, this.particleCount = 18});

  final int particleCount;

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random(42);
    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(random),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double startX;
  final double startY;
  final double radius;
  final double speed;
  final double phase;

  const _Particle({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.speed,
    required this.phase,
  });

  factory _Particle.random(Random random) {
    return _Particle(
      startX: random.nextDouble(),
      startY: random.nextDouble(),
      radius: 4 + random.nextDouble() * 10,
      speed: 0.3 + random.nextDouble() * 0.7,
      phase: random.nextDouble() * 2 * pi,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t);

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final dy = sin((t * 2 * pi * p.speed) + p.phase) * 24;
      final dx = cos((t * 2 * pi * p.speed * 0.6) + p.phase) * 16;

      final dx0 = p.startX * size.width + dx;
      final dy0 = p.startY * size.height + dy;

      paint.color = AppColors.primaryLight.withOpacity(0.08);
      canvas.drawCircle(Offset(dx0, dy0), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
