import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/enhanced_theme.dart';

class CustomCrystalLogo extends StatefulWidget {
  final double size;
  final bool animate;
  
  const CustomCrystalLogo({
    Key? key,
    this.size = 120,
    this.animate = true,
  }) : super(key: key);

  @override
  State<CustomCrystalLogo> createState() => _CustomCrystalLogoState();
}

class _CustomCrystalLogoState extends State<CustomCrystalLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _colorController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();
    
    if (widget.animate) {
      // Gentle rotation - slower for performance
      _rotationController = AnimationController(
        duration: const Duration(seconds: 15),
        vsync: this,
      )..repeat();
      
      // Pulse animation - gentler
      _pulseController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(reverse: true);
      
      _pulseAnimation = Tween<double>(
        begin: 0.98,
        end: 1.02,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ));
      
      // Color cycling animation - slower
      _colorController = AnimationController(
        duration: const Duration(seconds: 6),
        vsync: this,
      )..repeat(reverse: true);
      
      _colorAnimation1 = ColorTween(
        begin: const Color(0xFF20B2AA), // Teal
        end: const Color(0xFFFF4500),   // Red-Orange
      ).animate(CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ));
      
      _colorAnimation2 = ColorTween(
        begin: const Color(0xFFFF8C00), // Orange  
        end: const Color(0xFF20B2AA),   // Teal
      ).animate(CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _rotationController.dispose();
      _pulseController.dispose();
      _colorController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return _buildStaticLogo();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _pulseAnimation,
        _colorAnimation1,
        _colorAnimation2,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationController.value * 2 * math.pi * 0.1,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _colorAnimation1.value!.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: _colorAnimation2.value!.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CrystalLogoPainter(
                  tealColor: _colorAnimation1.value!,
                  orangeColor: _colorAnimation2.value!,
                  redColor: const Color(0xFFDC143C), // Crimson
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStaticLogo() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20B2AA).withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFFF8C00).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: CrystalLogoPainter(
          tealColor: const Color(0xFF20B2AA),
          orangeColor: const Color(0xFFFF8C00),
          redColor: const Color(0xFFDC143C),
        ),
      ),
    );
  }
}

class CrystalLogoPainter extends CustomPainter {
  final Color tealColor;
  final Color orangeColor;
  final Color redColor;

  CrystalLogoPainter({
    required this.tealColor,
    required this.orangeColor,
    required this.redColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create the faceted diamond shape matching the original logo
    final paint = Paint()..style = PaintingStyle.fill;

    // Top triangular facets (teal color)
    final topLeftFacet = Path();
    topLeftFacet.moveTo(center.dx - radius * 0.6, center.dy - radius * 0.3);
    topLeftFacet.lineTo(center.dx - radius * 0.2, center.dy - radius * 0.8);
    topLeftFacet.lineTo(center.dx, center.dy - radius * 0.3);
    topLeftFacet.close();
    
    paint.color = tealColor;
    canvas.drawPath(topLeftFacet, paint);

    // Top center facet (lighter teal)
    final topCenterFacet = Path();
    topCenterFacet.moveTo(center.dx - radius * 0.2, center.dy - radius * 0.8);
    topCenterFacet.lineTo(center.dx + radius * 0.2, center.dy - radius * 0.8);
    topCenterFacet.lineTo(center.dx, center.dy - radius * 0.3);
    topCenterFacet.close();
    
    paint.color = tealColor.withOpacity(0.8);
    canvas.drawPath(topCenterFacet, paint);

    // Top right facet (teal)
    final topRightFacet = Path();
    topRightFacet.moveTo(center.dx + radius * 0.2, center.dy - radius * 0.8);
    topRightFacet.lineTo(center.dx + radius * 0.6, center.dy - radius * 0.3);
    topRightFacet.lineTo(center.dx, center.dy - radius * 0.3);
    topRightFacet.close();
    
    paint.color = tealColor;
    canvas.drawPath(topRightFacet, paint);

    // Left side facet (orange to red gradient)
    final leftFacet = Path();
    leftFacet.moveTo(center.dx - radius * 0.6, center.dy - radius * 0.3);
    leftFacet.lineTo(center.dx, center.dy - radius * 0.3);
    leftFacet.lineTo(center.dx, center.dy + radius * 0.8);
    leftFacet.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [orangeColor, redColor],
    ).createShader(leftFacet.getBounds());
    canvas.drawPath(leftFacet, paint);

    // Right side facet (orange to red gradient)
    final rightFacet = Path();
    rightFacet.moveTo(center.dx + radius * 0.6, center.dy - radius * 0.3);
    rightFacet.lineTo(center.dx, center.dy - radius * 0.3);
    rightFacet.lineTo(center.dx, center.dy + radius * 0.8);
    rightFacet.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [orangeColor, redColor],
    ).createShader(rightFacet.getBounds());
    canvas.drawPath(rightFacet, paint);

    // Center highlight (bright orange/white)
    final centerHighlight = Path();
    centerHighlight.moveTo(center.dx - radius * 0.15, center.dy - radius * 0.2);
    centerHighlight.lineTo(center.dx + radius * 0.15, center.dy - radius * 0.2);
    centerHighlight.lineTo(center.dx, center.dy + radius * 0.3);
    centerHighlight.close();
    
    paint.shader = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.9),
        orangeColor.withOpacity(0.7),
        redColor.withOpacity(0.5),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(centerHighlight.getBounds());
    canvas.drawPath(centerHighlight, paint);

    // Add facet lines for definition
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.color = Colors.white.withOpacity(0.3);

    // Draw facet separation lines
    canvas.drawLine(
      Offset(center.dx - radius * 0.6, center.dy - radius * 0.3),
      Offset(center.dx, center.dy - radius * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.6, center.dy - radius * 0.3),
      Offset(center.dx, center.dy - radius * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.3),
      Offset(center.dx, center.dy + radius * 0.8),
      paint,
    );

    // Outer glow effect
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.color = tealColor.withOpacity(0.6);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    
    // Draw outer diamond outline
    final outerPath = Path();
    outerPath.moveTo(center.dx - radius * 0.6, center.dy - radius * 0.3);
    outerPath.lineTo(center.dx - radius * 0.2, center.dy - radius * 0.8);
    outerPath.lineTo(center.dx + radius * 0.2, center.dy - radius * 0.8);
    outerPath.lineTo(center.dx + radius * 0.6, center.dy - radius * 0.3);
    outerPath.lineTo(center.dx, center.dy + radius * 0.8);
    outerPath.close();
    
    canvas.drawPath(outerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}