import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/utils/theme_controller.dart';

/// 3D Liquid Glass Pebble Painter
/// Replicates the raytraced 3D convex glass dome seen in Apple Vision & Liquid Glass Studio:
/// - Curved top specular meniscus cap (silver-to-dark gradient)
/// - Electric-cyan chromatic dispersion fringe along the upper & lower rims
/// - Razor-sharp white specular highlight edges
/// - Bottom caustic crescent reflection
/// - Deep obsidian convex glass body
/// - 3D floating ambient drop shadow
class LiquidGlassPebblePainter extends CustomPainter {
  final Color chromaticColor;
  final double highlightIntensity;
  final BorderRadius borderRadius;
  final bool hasDropShadow;

  LiquidGlassPebblePainter({
    this.chromaticColor = const Color(0xFF4FA5FF),
    this.highlightIntensity = 1.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.hasDropShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    // 1. Ambient Depth Shadow (gives physical 3D elevation above the dock)
    if (hasDropShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawRRect(rrect.shift(const Offset(0, 6)), shadowPaint);
    }

    // 2. Base Obsidian Glass Body (deep convex crystal core)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x351A202A),
          Color(0x700C0E14),
          Color(0x9507080B),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bodyPaint);

    canvas.save();
    canvas.clipRRect(rrect);

    // 3. Top Specular Meniscus Cap (The 3D Glass Dome Highlight)
    final topCapHeight = size.height * 0.38;
    final topRect = Rect.fromLTWH(0, 0, size.width, topCapHeight);

    final topCapPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, topCapHeight * 0.55)
      ..quadraticBezierTo(
        size.width * 0.5,
        topCapHeight * 1.15,
        0,
        topCapHeight * 0.55,
      )
      ..close();

    final topCapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFCAD4DE).withValues(alpha: 0.85 * highlightIntensity),
          const Color(0xFF8A98A6).withValues(alpha: 0.55 * highlightIntensity),
          const Color(0xFF323B45).withValues(alpha: 0.15 * highlightIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.32, 0.72, 1.0],
      ).createShader(topRect);
    canvas.drawPath(topCapPath, topCapPaint);

    // Top Chromatic Dispersion Arc (Electric Cyan / Blue Fringe)
    final topFringePath = Path()
      ..moveTo(size.width * 0.10, 1.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        0.5,
        size.width * 0.90,
        1.5,
      );
    final topFringePaint = Paint()
      ..color = chromaticColor.withValues(alpha: 0.80 * highlightIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawPath(topFringePath, topFringePaint);

    // Razor-Sharp White Top Specular Edge
    final topEdgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.95 * highlightIntensity),
          Colors.white.withValues(alpha: 0.95 * highlightIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.22, 0.78, 1.0],
      ).createShader(topRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(topFringePath, topEdgePaint);

    // 4. Bottom Caustic Crescent Reflection
    final botCapHeight = size.height * 0.26;
    final botRect = Rect.fromLTWH(0, size.height - botCapHeight, size.width, botCapHeight);

    final botCapPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - botCapHeight * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height - botCapHeight * 1.15,
        0,
        size.height - botCapHeight * 0.5,
      )
      ..close();

    final botCapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFC4D2DF).withValues(alpha: 0.75 * highlightIntensity),
          const Color(0xFF6B7B8E).withValues(alpha: 0.35 * highlightIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(botRect);
    canvas.drawPath(botCapPath, botCapPaint);

    // Bottom Chromatic Dispersion Arc (Electric Cyan / Blue Fringe)
    final botFringePath = Path()
      ..moveTo(size.width * 0.12, size.height - 1.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height - 0.5,
        size.width * 0.88,
        size.height - 1.5,
      );
    final botFringePaint = Paint()
      ..color = chromaticColor.withValues(alpha: 0.75 * highlightIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawPath(botFringePath, botFringePaint);

    // Razor-Sharp White Bottom Specular Edge
    final botEdgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.90 * highlightIntensity),
          Colors.white.withValues(alpha: 0.90 * highlightIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.22, 0.78, 1.0],
      ).createShader(botRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(botFringePath, botEdgePaint);

    canvas.restore();

    // 5. Outer Fresnel Rim Border (Lateral Wet Edges)
    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.40),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.38),
        ],
        stops: const [0.0, 0.2, 0.8, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidGlassPebblePainter oldDelegate) {
    return oldDelegate.chromaticColor != chromaticColor ||
        oldDelegate.highlightIntensity != highlightIntensity ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.hasDropShadow != hasDropShadow;
  }
}

/// 3D Liquid Glass Pebble Widget
/// Wraps content in the exact 3D raytraced convex glass lens.
class LiquidGlassPebble extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? chromaticColor;
  final double highlightIntensity;
  final bool hasDropShadow;
  final EdgeInsetsGeometry padding;

  const LiquidGlassPebble({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.chromaticColor,
    this.highlightIntensity = 1.0,
    this.hasDropShadow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(24);
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    final effectiveChromatic = chromaticColor ??
        (themeCtrl?.primaryColor.value ?? const Color(0xFF4FA5FF));

    return RepaintBoundary(
      child: CustomPaint(
        painter: LiquidGlassPebblePainter(
          chromaticColor: effectiveChromatic,
          highlightIntensity: highlightIntensity,
          borderRadius: effectiveRadius,
          hasDropShadow: hasDropShadow,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// Apple iOS 18 style Liquid Glass Container
/// Crystal-clear acrylic transparency with specular highlight reflection
/// and chromatic refraction from the background/music theme.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma = 20.0,
    this.borderWidth = 0.8,
    this.padding,
    this.margin,
    this.glowColor,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          // Soft liquid ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          // Dynamic chromatic aura matching music theme
          if (glowColor != null || themeCtrl != null)
            BoxShadow(
              color: (glowColor ?? themeCtrl?.primaryColor.value ?? Colors.transparent)
                  .withValues(alpha: 0.12),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              // Crystal-clear liquid acrylic base: clear, not milky
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.04),
                  const Color(0x180D1117),
                  Colors.white.withValues(alpha: 0.07),
                ],
                stops: const [0.0, 0.35, 0.70, 1.0],
              ),
              // Specular wet edge highlight
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Flowy, organic button with elastic spring squish feedback
/// Similar to Apple iOS 18 dynamic interactive elements.
class FlowyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  const FlowyButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.94,
    this.duration = const Duration(milliseconds: 130),
  });

  @override
  State<FlowyButton> createState() => _FlowyButtonState();
}

class _FlowyButtonState extends State<FlowyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressDown() {
    _controller.forward();
  }

  void _onPressUp() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _onPressDown(),
        onTapUp: (_) {
          _onPressUp();
          widget.onTap?.call();
        },
        onTapCancel: () => _onPressUp(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      );
    }

    // When onTap is null (e.g. child has its own button/gesture handler),
    // use Listener with translucent behavior so it animates without stealing gestures.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onPressDown(),
      onPointerUp: (_) => _onPressUp(),
      onPointerCancel: (_) => _onPressUp(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Living, breathing ambient mesh glow
/// Hardware accelerated with RepaintBoundary and smooth orbital animation.
class LiquidAmbientGlow extends StatefulWidget {
  final double intensity;

  const LiquidAmbientGlow({
    super.key,
    this.intensity = 0.55,
  });

  @override
  State<LiquidAmbientGlow> createState() => _LiquidAmbientGlowState();
}

class _LiquidAmbientGlowState extends State<LiquidAmbientGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : null;

    return Obx(() {
      final primaryColor = themeCtrl?.primaryColor.value ??
          Theme.of(context).colorScheme.primary;

      return RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final angle1 = t * 2 * math.pi;
            final angle2 = (t + 0.5) * 2 * math.pi;

            return CustomPaint(
              size: Size.infinite,
              painter: _LiquidGlowPainter(
                primaryColor: primaryColor,
                intensity: widget.intensity,
                offset1: Offset(
                  0.35 + 0.25 * math.cos(angle1),
                  0.40 + 0.20 * math.sin(angle1),
                ),
                offset2: Offset(
                  0.65 + 0.20 * math.cos(angle2),
                  0.60 + 0.25 * math.sin(angle2),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _LiquidGlowPainter extends CustomPainter {
  final Color primaryColor;
  final double intensity;
  final Offset offset1;
  final Offset offset2;

  _LiquidGlowPainter({
    required this.primaryColor,
    required this.intensity,
    required this.offset1,
    required this.offset2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Orb 1: Primary chromatic swell
    final center1 = Offset(size.width * offset1.dx, size.height * offset1.dy);
    final radius1 = size.width * 0.75;
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.40 * intensity),
          primaryColor.withValues(alpha: 0.15 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center1, radius: radius1));

    canvas.drawCircle(center1, radius1, paint1);

    // Orb 2: Dynamic ambient refraction
    final center2 = Offset(size.width * offset2.dx, size.height * offset2.dy);
    final radius2 = size.width * 0.85;
    final secondaryColor = HSLColor.fromColor(primaryColor)
        .withHue((HSLColor.fromColor(primaryColor).hue + 40) % 360)
        .toColor();

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor.withValues(alpha: 0.30 * intensity),
          secondaryColor.withValues(alpha: 0.08 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: center2, radius: radius2));

    canvas.drawCircle(center2, radius2, paint2);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlowPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.intensity != intensity ||
        oldDelegate.offset1 != offset1 ||
        oldDelegate.offset2 != offset2;
  }
}
