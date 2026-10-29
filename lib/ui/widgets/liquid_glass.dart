import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/ui/utils/theme_controller.dart';

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
