import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class Particle {
  double x;
  double y;
  double radius;
  double speedX;
  double speedY;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });
}

class ParticlesBackground extends StatefulWidget {
  final Widget child;
  const ParticlesBackground({super.key, required this.child});

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _particles = [];
  }

  void _initParticles(Size size) {
    if (_size == size) return;
    _size = size;
    _particles = List.generate(30, (_) => _createParticle(size));
  }

  Particle _createParticle(Size size) {
    return Particle(
      x: _random.nextDouble() * size.width,
      y: _random.nextDouble() * size.height,
      radius: _random.nextDouble() * 2 + 1,
      speedX: (_random.nextDouble() - 0.5) * 1.2,
      speedY: (_random.nextDouble() - 0.5) * 1.2,
      opacity: _random.nextDouble() * 0.5 + 0.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initParticles(size);
        return Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                _updateParticles(size);
                return CustomPaint(
                  painter: _ParticlesPainter(
                    particles: _particles,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  size: size,
                );
              },
            ),
            widget.child,
          ],
        );
      },
    );
  }

  void _updateParticles(Size size) {
    for (final p in _particles) {
      p.x += p.speedX;
      p.y += p.speedY;
      if (p.x < 0 || p.x > size.width) p.speedX *= -1;
      if (p.y < 0 || p.y > size.height) p.speedY *= -1;
    }
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final bool isDark;

  _ParticlesPainter({required this.particles, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = (isDark ? Colors.white : AppColors.purple)
            .withValues(alpha: p.opacity * (isDark ? 0.6 : 0.3))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => true;
}
