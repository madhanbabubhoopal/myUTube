import 'package:flutter/material.dart';

/// KidsTube logo widget — red rounded rectangle with a white play triangle.
/// Built entirely with CustomPainter; no image files used.
class KidsTubeLogo extends StatelessWidget {
  final double size;

  const KidsTubeLogo({super.key, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.42,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Red rounded rectangle
    final bgPaint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height * 0.22),
    );
    canvas.drawRRect(rrect, bgPaint);

    // White play triangle
    final triPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final tw = size.width * 0.35;
    final th = size.height * 0.55;

    final path = Path()
      ..moveTo(cx - tw * 0.38, cy - th / 2)
      ..lineTo(cx + tw * 0.62, cy)
      ..lineTo(cx - tw * 0.38, cy + th / 2)
      ..close();

    canvas.drawPath(path, triPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
