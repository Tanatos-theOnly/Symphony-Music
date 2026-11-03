import 'package:flutter/material.dart';
import '/models/durationstate.dart';

class MiniPlayerProgressBar extends StatelessWidget {
  const MiniPlayerProgressBar(
      {super.key,
      required this.progressBarStatus,
      required this.progressBarColor});
  final ProgressBarState progressBarStatus;
  final Color progressBarColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 2.5),
      painter: ProgressBarPainter(
          current: progressBarStatus.current,
          total: progressBarStatus.total,
          progressBarColor: progressBarColor),
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  ProgressBarPainter(
      {required this.current,
      required this.total,
      required this.progressBarColor});
  final Duration current;
  final Duration total;
  final Color progressBarColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    const p1 = Offset(0, 1.5);
    final progressWidth = total.inSeconds == 0
        ? 0.0
        : (size.width * (current.inSeconds / total.inSeconds))
            .clamp(0.0, size.width);
    if (progressWidth <= 0) return;

    final p2 = Offset(progressWidth, 1.5);
    final rect = Rect.fromPoints(
        p1, Offset(progressWidth.clamp(1.0, size.width), 3.0));

    // Luminous Liquid Glass Gradient Line (Symphony AGSL Prismal Optics)
    final shader = LinearGradient(
      colors: [
        progressBarColor.withValues(alpha: 0.65),
        progressBarColor,
        const Color(0xFF4FA5FF),
        Colors.white,
      ],
      stops: const [0.0, 0.65, 0.92, 1.0],
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
