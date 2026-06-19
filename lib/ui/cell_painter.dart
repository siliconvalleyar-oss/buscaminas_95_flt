import 'dart:math';
import 'package:flutter/material.dart';
import 'win98_colors.dart';
import '../game/cell.dart';
import '../game/minefield.dart';

class CellPainter extends CustomPainter {
  final Cell cell;
  final GameState state;
  final double cellSize;

  CellPainter({required this.cell, required this.state, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (cell.isRevealed) {
      _drawSunken(canvas, rect);
      if (cell.isMine) {
        _drawMine(canvas, rect);
      } else if (cell.adjacentMines > 0) {
        _drawNumber(canvas, rect);
      }
    } else if (cell.isFlagged) {
      _drawRaised(canvas, rect);
      _drawFlag(canvas, rect);
    } else {
      _drawRaised(canvas, rect);
    }

    if (state == GameState.lost && cell.isMine && !cell.isFlagged) {
      _drawMine(canvas, rect);
    }
    if (state == GameState.lost && cell.isFlagged && !cell.isMine) {
      _drawWrongFlag(canvas, rect);
    }
  }

  void _drawRaised(Canvas canvas, Rect rect) {
    final paint = Paint()..color = Win98Colors.gray;
    canvas.drawRect(rect, paint);

    final light = Paint()
      ..color = Win98Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(rect.topLeft, rect.topRight, light);
    canvas.drawLine(rect.topLeft, rect.bottomLeft, light);

    final dark = Paint()
      ..color = Win98Colors.darkGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(rect.topRight, rect.bottomRight, dark);
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, dark);

    final black = Paint()
      ..color = Win98Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawLine(
        rect.topRight + const Offset(0, 2), rect.bottomRight - const Offset(0, 1), black);
    canvas.drawLine(
        rect.bottomLeft + const Offset(2, 0), rect.bottomRight - const Offset(1, 0), black);
  }

  void _drawSunken(Canvas canvas, Rect rect) {
    final paint = Paint()..color = const Color(0xFFD0D0D0);
    canvas.drawRect(rect, paint);

    final dark = Paint()
      ..color = Win98Colors.darkGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(rect.topLeft, rect.topRight, dark);
    canvas.drawLine(rect.topLeft, rect.bottomLeft, dark);

    final light = Paint()
      ..color = Win98Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(rect.topRight, rect.bottomRight, light);
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, light);
  }

  void _drawNumber(Canvas canvas, Rect rect) {
    final text = '${cell.adjacentMines}';
    final color = Win98Colors.numColors[cell.adjacentMines % Win98Colors.numColors.length];
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: rect.width * 0.65,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawMine(Canvas canvas, Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final r = min(rect.width, rect.height) * 0.3;

    if (state == GameState.lost && cell.isMine && cell.isRevealed) {
      final bgPaint = Paint()..color = Colors.red.withValues(alpha: 0.4);
      canvas.drawRect(rect, bgPaint);
    }

    final bodyPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    final spikePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2 + pi / 4;
      canvas.drawLine(
        Offset(cx + cos(angle) * r * 0.6, cy + sin(angle) * r * 0.6),
        Offset(cx + cos(angle) * r * 1.6, cy + sin(angle) * r * 1.6),
        spikePaint,
      );
    }

    final highlightPaint = Paint()..color = Colors.white70;
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.25), r * 0.3, highlightPaint);
  }

  void _drawFlag(Canvas canvas, Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final r = min(rect.width, rect.height) * 0.2;

    final polePaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), polePaint);

    final flagPaint = Paint()..color = Colors.red;
    final flagPath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 1.2, cy - r * 0.4)
      ..lineTo(cx, cy + r * 0.1)
      ..close();
    canvas.drawPath(flagPath, flagPaint);
  }

  void _drawWrongFlag(Canvas canvas, Rect rect) {
    _drawFlag(canvas, rect);
    final paint = Paint()..color = Colors.red.withValues(alpha: 0.3);
    canvas.drawRect(rect, paint);

    final xPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    canvas.drawLine(rect.topLeft, rect.bottomRight, xPaint);
    canvas.drawLine(rect.topRight, rect.bottomLeft, xPaint);
  }

  @override
  bool shouldRepaint(CellPainter old) =>
      cell.isRevealed != old.cell.isRevealed ||
      cell.isFlagged != old.cell.isFlagged ||
      state != old.state ||
      cellSize != old.cellSize;
}
