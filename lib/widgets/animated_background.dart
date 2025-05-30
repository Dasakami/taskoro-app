import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math' as math;
import 'package:taskoro/theme/app_theme.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                Color.alphaBlend(
                  AppColors.accentPrimary.withOpacity(0.1),
                  AppColors.background,
                ),
                AppColors.background,
              ],
            ),
          ),
        ),

        // Animated particles
        const _ParticleLayer(
          numberOfParticles: 15,
          minSize: 2,
          maxSize: 5,
          color: AppColors.accentPrimary,
          speed: 1,
        ),

        const _ParticleLayer(
          numberOfParticles: 10,
          minSize: 1,
          maxSize: 3,
          color: AppColors.accentSecondary,
          speed: 0.7,
        ),

        // Radial gradients for magical effect
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentPrimary.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentSecondary.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Grid overlay with magical runes
        CustomPaint(
          painter: _GridPainter(),
          size: Size.infinite,
        ),
      ],
    );
  }
}

class _ParticleLayer extends StatelessWidget {
  final int numberOfParticles;
  final double minSize;
  final double maxSize;
  final Color color;
  final double speed;

  const _ParticleLayer({
    required this.numberOfParticles,
    required this.minSize,
    required this.maxSize,
    required this.color,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(
            numberOfParticles,
                (index) => _Particle(
              size: minSize + math.Random().nextDouble() * (maxSize - minSize),
              color: color.withOpacity(0.3 + math.Random().nextDouble() * 0.4),
              speed: speed,
              initialX: math.Random().nextDouble() * constraints.maxWidth,
              initialY: math.Random().nextDouble() * constraints.maxHeight,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
          ),
        );
      },
    );
  }
}

class _Particle extends StatelessWidget {
  final double size;
  final Color color;
  final double speed;
  final double initialX;
  final double initialY;
  final double width;
  final double height;

  _Particle({
    required this.size,
    required this.color,
    required this.speed,
    required this.initialX,
    required this.initialY,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Create a custom animation for the particle
    final tween = MovieTween()
      ..tween(
        'x',
        Tween(begin: initialX, end: initialX + 50),
        duration: Duration(seconds: (10 / speed).round()),
      ).thenTween(
        'x',
        Tween(begin: initialX + 50, end: initialX),
        duration: Duration(seconds: (10 / speed).round()),
      )
      ..tween(
        'y',
        Tween(begin: initialY, end: initialY - 100),
        duration: Duration(seconds: (20 / speed).round()),
      ).thenTween(
        'y',
        Tween(begin: initialY - 100, end: initialY),
        duration: Duration(seconds: (20 / speed).round()),
      )
      ..tween(
        'opacity',
        Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
      ).thenTween(
        'opacity',
        Tween(begin: 1.0, end: 0.0),
        duration: const Duration(seconds: 2),
      ).thenTween(
        'opacity',
        Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
      );

    return LoopAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      builder: (context, value, child) {
        return Positioned(
          left: value.get('x'),
          top: value.get('y'),
          child: Opacity(
            opacity: value.get('opacity'),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: size * 2,
                    spreadRadius: size / 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPrimary.withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}