import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/enhanced_theme.dart';

class GemSymbolLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final List<Color> colors;
  
  const GemSymbolLogo({
    Key? key,
    this.size = 100,
    this.animate = true,
    this.colors = const [
      Color(0xFF20B2AA), // Teal
      Color(0xFFFF4500), // Red-Orange
      Color(0xFFFF8C00), // Orange
    ],
  }) : super(key: key);

  @override
  State<GemSymbolLogo> createState() => _GemSymbolLogoState();
}

class _GemSymbolLogoState extends State<GemSymbolLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animate) {
      // Gentle rotation
      _rotationController = AnimationController(
        duration: const Duration(seconds: 20),
        vsync: this,
      )..repeat();
      
      // Glow animation
      _glowController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(reverse: true);
      
      _glowAnimation = Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _rotationController.dispose();
      _glowController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget logo = CustomPaint(
      size: Size(widget.size, widget.size),
      painter: GemSymbolPainter(colors: widget.colors),
    );

    if (!widget.animate) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: logo,
      );
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _glowAnimation]),
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi * 0.05,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.colors[0].withOpacity(0.6 * _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: widget.colors[1].withOpacity(0.4 * _glowAnimation.value),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: logo,
          ),
        );
      },
    );
  }
}

class GemSymbolPainter extends CustomPainter {
  final List<Color> colors;

  GemSymbolPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create the geometric diamond shape from the Crystal Encyclopedia
    final paint = Paint()..style = PaintingStyle.fill;

    // Top triangle
    final topPath = Path();
    topPath.moveTo(center.dx - radius * 0.5, center.dy);
    topPath.lineTo(center.dx, center.dy - radius * 0.7);
    topPath.lineTo(center.dx + radius * 0.5, center.dy);
    topPath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors[0].withOpacity(0.9),
        colors[0].withOpacity(0.7),
      ],
    ).createShader(topPath.getBounds());
    canvas.drawPath(topPath, paint);

    // Bottom left triangle
    final bottomLeftPath = Path();
    bottomLeftPath.moveTo(center.dx - radius * 0.5, center.dy);
    bottomLeftPath.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.7);
    bottomLeftPath.lineTo(center.dx, center.dy);
    bottomLeftPath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors[1].withOpacity(0.8),
        colors[2].withOpacity(0.9),
      ],
    ).createShader(bottomLeftPath.getBounds());
    canvas.drawPath(bottomLeftPath, paint);

    // Bottom right triangle
    final bottomRightPath = Path();
    bottomRightPath.moveTo(center.dx + radius * 0.5, center.dy);
    bottomRightPath.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.7);
    bottomRightPath.lineTo(center.dx, center.dy);
    bottomRightPath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        colors[1].withOpacity(0.8),
        colors[2].withOpacity(0.9),
      ],
    ).createShader(bottomRightPath.getBounds());
    canvas.drawPath(bottomRightPath, paint);

    // Center facet
    final centerPath = Path();
    centerPath.moveTo(center.dx, center.dy);
    centerPath.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.7);
    centerPath.lineTo(center.dx, center.dy + radius * 0.5);
    centerPath.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.7);
    centerPath.close();
    
    paint.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.5),
        colors[2].withOpacity(0.7),
      ],
    ).createShader(centerPath.getBounds());
    canvas.drawPath(centerPath, paint);

    // Add white edges for definition
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = Colors.white.withOpacity(0.3);

    // Draw all edges
    canvas.drawPath(topPath, paint);
    canvas.drawPath(bottomLeftPath, paint);
    canvas.drawPath(bottomRightPath, paint);
    canvas.drawPath(centerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}