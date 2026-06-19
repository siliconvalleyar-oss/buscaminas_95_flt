import 'dart:math';
import 'package:flutter/material.dart';
import '../game/cell.dart';
import '../game/minefield.dart';
import '../styles/win98_colors.dart';

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
    canvas.drawRect(rect, Paint()..color = Win98Colors.gray);
    _stroke(canvas, rect.topLeft, rect.topRight, Win98Colors.white, 1.5);
    _stroke(canvas, rect.topLeft, rect.bottomLeft, Win98Colors.white, 1.5);
    _stroke(canvas, rect.topRight, rect.bottomRight, Win98Colors.darkGray, 1.5);
    _stroke(canvas, rect.bottomLeft, rect.bottomRight, Win98Colors.darkGray, 1.5);
    _stroke(canvas, rect.topRight + const Offset(0, 2), rect.bottomRight - const Offset(0, 1), Win98Colors.black, 0.5);
    _stroke(canvas, rect.bottomLeft + const Offset(2, 0), rect.bottomRight - const Offset(1, 0), Win98Colors.black, 0.5);
  }

  void _drawSunken(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFFD0D0D0));
    _stroke(canvas, rect.topLeft, rect.topRight, Win98Colors.darkGray, 1);
    _stroke(canvas, rect.topLeft, rect.bottomLeft, Win98Colors.darkGray, 1);
    _stroke(canvas, rect.topRight, rect.bottomRight, Win98Colors.white, 1);
    _stroke(canvas, rect.bottomLeft, rect.bottomRight, Win98Colors.white, 1);
  }

  void _stroke(Canvas c, Offset a, Offset b, Color color, double width) {
    c.drawLine(a, b, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = width);
  }

  void _drawNumber(Canvas canvas, Rect rect) {
    final tp = TextPainter(
      text: TextSpan(
        text: '${cell.adjacentMines}',
        style: TextStyle(
          color: Win98Colors.numColors[cell.adjacentMines % Win98Colors.numColors.length],
          fontSize: rect.width * 0.65,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
  }

  void _drawMine(Canvas canvas, Rect rect) {
    final cx = rect.center.dx, cy = rect.center.dy;
    final r = min(rect.width, rect.height) * 0.3;

    if (state == GameState.lost && cell.isMine && cell.isRevealed) {
      canvas.drawRect(rect, Paint()..color = Colors.red.withValues(alpha: 0.4));
    }

    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.black87);
    final spike = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.5;
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2 + pi / 4;
      canvas.drawLine(Offset(cx + cos(a) * r * 0.6, cy + sin(a) * r * 0.6),
          Offset(cx + cos(a) * r * 1.6, cy + sin(a) * r * 1.6), spike);
    }
    canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.25), r * 0.3, Paint()..color = Colors.white70);
  }

  void _drawFlag(Canvas canvas, Rect rect) {
    final cx = rect.center.dx, cy = rect.center.dy;
    final r = min(rect.width, rect.height) * 0.2;
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r),
        Paint()..color = Colors.brown..strokeWidth = 2);
    final flagPath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r * 1.2, cy - r * 0.4)
      ..lineTo(cx, cy + r * 0.1)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = Colors.red);
  }

  void _drawWrongFlag(Canvas canvas, Rect rect) {
    _drawFlag(canvas, rect);
    canvas.drawRect(rect, Paint()..color = Colors.red.withValues(alpha: 0.3));
    final xPaint = Paint()..color = Colors.red..strokeWidth = 2;
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
