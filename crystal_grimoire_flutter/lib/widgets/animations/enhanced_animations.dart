import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/enhanced_theme.dart';

/// Enhanced mystical animations for Crystal Grimoire
class MysticalAnimations {
  
  /// Fade and scale in animation
  static Widget fadeScaleIn({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Slide in from direction
  static Widget slideIn({
    required Widget child,
    SlideDirection direction = SlideDirection.bottom,
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: curve,
      builder: (context, value, child) {
        Offset offset;
        switch (direction) {
          case SlideDirection.left:
            offset = Offset(-1.0 + value, 0.0);
            break;
          case SlideDirection.right:
            offset = Offset(1.0 - value, 0.0);
            break;
          case SlideDirection.top:
            offset = Offset(0.0, -1.0 + value);
            break;
          case SlideDirection.bottom:
            offset = Offset(0.0, 1.0 - value);
            break;
        }
        
        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration itemDelay = const Duration(milliseconds: 100),
    Duration itemDuration = const Duration(milliseconds: 500),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return fadeScaleIn(
          delay: itemDelay * index,
          duration: itemDuration,
          child: child,
        );
      }).toList(),
    );
  }
}

enum SlideDirection { left, right, top, bottom }

/// Pulsing glow effect widget
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final Duration duration;

  const PulsingGlow({
    Key? key,
    required this.child,
    this.glowColor = CrystalGrimoireTheme.mysticPurple,
    this.glowRadius = 20.0,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value * 0.4),
                blurRadius: widget.glowRadius * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Floating particles background
class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double minSize;
  final double maxSize;

  const FloatingParticles({
    Key? key,
    this.particleCount = 20,
    this.particleColor = CrystalGrimoireTheme.stardustSilver,
    this.minSize = 2.0,
    this.maxSize = 6.0,
  }) : super(key: key);

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    particles = List.generate(widget.particleCount, (index) => Particle(
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      size: widget.minSize + 
             math.Random().nextDouble() * (widget.maxSize - widget.minSize),
      speed: 0.1 + math.Random().nextDouble() * 0.3,
      opacity: 0.3 + math.Random().nextDouble() * 0.7,
    ));

    _controller.repeat();
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
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animationValue: _controller.value,
            color: widget.particleColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position
      particle.y -= particle.speed * 0.01;
      if (particle.y < 0) {
        particle.y = 1.0;
        particle.x = math.Random().nextDouble();
      }

      // Draw particle
      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFF2D1B69),
    this.highlightColor = const Color(0xFF6B21A8),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Bouncing scale animation
class BouncingScale extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleFactor;

  const BouncingScale({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.scaleFactor = 1.1,
  }) : super(key: key);

  @override
  State<BouncingScale> createState() => _BouncingScaleState();
}

class _BouncingScaleState extends State<BouncingScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Ripple effect widget
class RippleEffect extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final Duration duration;
  final VoidCallback? onTap;

  const RippleEffect({
    Key? key,
    required this.child,
    this.rippleColor = CrystalGrimoireTheme.mysticPurple,
    this.duration = const Duration(milliseconds: 600),
    this.onTap,
  }) : super(key: key);

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.onTap?.call();
    _controller.forward().then((_) {
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: RipplePainter(
                    animationValue: _animation.value,
                    color: widget.rippleColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  RipplePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0.0) return;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - animationValue)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * animationValue;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}