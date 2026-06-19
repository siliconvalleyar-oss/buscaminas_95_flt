import 'package:flutter/material.dart';
import '../styles/win98_colors.dart';

class LedCharPainter extends CustomPainter {
  final String char;
  final bool warning;

  LedCharPainter({required this.char, required this.warning});

  static const _segments = {
    '0': [true, true, true, true, true, true, false],
    '1': [false, true, true, false, false, false, false],
    '2': [true, true, false, true, true, false, true],
    '3': [true, true, true, true, false, false, true],
    '4': [false, true, true, false, false, true, true],
    '5': [true, false, true, true, false, true, true],
    '6': [true, false, true, true, true, true, true],
    '7': [true, true, true, false, false, false, false],
    '8': [true, true, true, true, true, true, true],
    '9': [true, true, true, true, false, true, true],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final segThick = 3.0;
    final gap = 2.0;
    final vertLen = (h / 2) - gap - segThick - 1.0;
    final segs = _segments[char] ?? [false, false, false, false, false, false, false];
    final onColor = warning ? const Color(0xFFFF4400) : Win98Colors.ledOn;
    final offColor = warning ? const Color(0xFF441100) : Win98Colors.ledOff;

    _drawSeg(canvas, Offset(gap, 1.0), w - gap * 2, segThick, segs[0] ? onColor : offColor);
    _drawSeg(canvas, Offset(w - segThick - 1, gap), segThick, vertLen, segs[1] ? onColor : offColor);
    _drawSeg(canvas, Offset(w - segThick - 1, h / 2 + 1), segThick, vertLen, segs[2] ? onColor : offColor);
    _drawSeg(canvas, Offset(gap, h - segThick - 1), w - gap * 2, segThick, segs[3] ? onColor : offColor);
    _drawSeg(canvas, Offset(1, h / 2 + 1), segThick, vertLen, segs[4] ? onColor : offColor);
    _drawSeg(canvas, Offset(1, gap), segThick, vertLen, segs[5] ? onColor : offColor);
    _drawSeg(canvas, Offset(gap, h / 2 - segThick / 2), w - gap * 2, segThick, segs[6] ? onColor : offColor);
  }

  void _drawSeg(Canvas canvas, Offset pos, double w, double h, Color color) {
    final rect = Rect.fromLTWH(pos.dx, pos.dy, w, h);
    canvas.drawRect(rect, Paint()..color = color);
    if (color != Win98Colors.ledOff && color != const Color(0xFF441100)) {
      canvas.drawRect(rect, Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
    }
  }

  @override
  bool shouldRepaint(LedCharPainter old) => char != old.char || warning != old.warning;
}
