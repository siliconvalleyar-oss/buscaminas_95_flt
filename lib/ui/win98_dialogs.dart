import 'package:flutter/material.dart';
import '../game/minefield.dart';
import '../game/score_manager.dart';
import '../game/face_style.dart';
import '../styles/win98_colors.dart';

// ============================================================
// Difficulty Dialog
// ============================================================
void showDifficultyDialog(
  BuildContext context, {
  required Difficulty currentDifficulty,
  required void Function(Difficulty) onSelect,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Win98Colors.gray,
      surfaceTintColor: Colors.transparent,
      shape: BeveledRectangleBorder(
        side: const BorderSide(color: Win98Colors.white, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      title: const Text('Seleccionar Dificultad',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: Difficulty.values.map((d) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onSelect(d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Win98Colors.darkGray),
                    color: currentDifficulty == d
                        ? const Color(0xFF000080)
                        : Win98Colors.gray,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        currentDifficulty == d
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 16,
                        color: currentDifficulty == d ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: currentDifficulty == d ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        _win98Button('Cancelar', () => Navigator.pop(ctx)),
      ],
    ),
  );
}

// ============================================================
// Custom Difficulty Dialog
// ============================================================
class CustomConfigResult {
  final int rows;
  final int cols;
  final int mines;
  final double cellSize;
  CustomConfigResult(this.rows, this.cols, this.mines, this.cellSize);
}

Future<CustomConfigResult?> showCustomDialog(
  BuildContext context, {
  required int initialRows,
  required int initialCols,
  required int initialMines,
  required double initialCellSize,
}) {
  return showDialog<CustomConfigResult>(
    context: context,
    builder: (ctx) {
      int rows = initialRows;
      int cols = initialCols;
      int mines = initialMines;
      double cellSize = initialCellSize;
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: Win98Colors.gray,
            surfaceTintColor: Colors.transparent,
            shape: BeveledRectangleBorder(
              side: const BorderSide(color: Win98Colors.white, width: 2),
              borderRadius: BorderRadius.zero,
            ),
            title: const Text('Dificultad Personalizada',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSlider(ctx, setDialogState, 'Filas', rows, 5, 50, (v) {
                    rows = v;
                    if (mines > rows * cols - 1) mines = rows * cols - 1;
                  }),
                  const SizedBox(height: 8),
                  _buildSlider(ctx, setDialogState, 'Columnas', cols, 5, 50, (v) {
                    cols = v;
                    if (mines > rows * cols - 1) mines = rows * cols - 1;
                  }),
                  const SizedBox(height: 8),
                  _buildSlider(ctx, setDialogState, 'Minas', mines, 1, rows * cols - 1, (v) {
                    mines = v;
                  }),
                  const SizedBox(height: 8),
                  _buildSliderDouble(ctx, setDialogState, 'Celda (px)', cellSize, 6, 40, (v) {
                    cellSize = v;
                  }),
                  const SizedBox(height: 12),
                  Text(
                    'Total: ${rows * cols} | Vacías: ${rows * cols - mines} | Celda: ${cellSize > 0 ? "${cellSize.toInt()}px" : "Auto"}',
                    style: const TextStyle(fontSize: 11, color: Win98Colors.darkGray),
                  ),
                ],
              ),
            ),
            actions: [
              _win98Button('Cancelar', () => Navigator.pop(ctx)),
              _win98Button('Aplicar', () {
                if (mines >= rows * cols) mines = rows * cols - 1;
                Navigator.pop(ctx, CustomConfigResult(rows, cols, mines, cellSize));
              }),
            ],
          );
        },
      );
    },
  );
}

Widget _buildSlider(
  BuildContext ctx,
  StateSetter setDialogState,
  String label,
  int value,
  int min,
  int max,
  void Function(int) onChange,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label: $value',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Row(
        children: [
          SizedBox(width: 30, child: Text('$min', style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray))),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTrackColor: Win98Colors.darkGray,
                inactiveTrackColor: Win98Colors.lightGray,
                thumbColor: Win98Colors.gray,
                overlayColor: Colors.transparent,
              ),
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                onChanged: (v) => setDialogState(() => onChange(v.round())),
              ),
            ),
          ),
          SizedBox(width: 30, child: Text('$max', style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray))),
        ],
      ),
    ],
  );
}

Widget _buildSliderDouble(
  BuildContext ctx,
  StateSetter setDialogState,
  String label,
  double value,
  double min,
  double max,
  void Function(double) onChange,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label: ${value > 0 ? value.toInt().toString() : "Auto"}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Row(
        children: [
          SizedBox(width: 30, child: Text('${min.toInt()}', style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray))),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTrackColor: Win98Colors.darkGray,
                inactiveTrackColor: Win98Colors.lightGray,
                thumbColor: Win98Colors.gray,
                overlayColor: Colors.transparent,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) / 2).round(),
                onChanged: (v) => setDialogState(() => onChange(v)),
              ),
            ),
          ),
          SizedBox(width: 30, child: Text('${max.toInt()}', style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray))),
        ],
      ),
    ],
  );
}

// ============================================================
// Scores Dialog
// ============================================================
void showScoresDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => FutureBuilder<Map<Difficulty, ScoreRecord>>(
      future: ScoreManager.getAll(),
      builder: (ctx, snapshot) {
        final scores = snapshot.data ?? {};
        return AlertDialog(
          backgroundColor: Win98Colors.gray,
          surfaceTintColor: Colors.transparent,
          shape: BeveledRectangleBorder(
            side: const BorderSide(color: Win98Colors.white, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, size: 18, color: Color(0xFFFFD700)),
              SizedBox(width: 6),
              Text('Mejores Puntos',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: scores.isEmpty
              ? const Text('Aún no hay puntuaciones.\n¡Juega y establece un récord!',
                  style: TextStyle(fontSize: 12))
              : SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: Difficulty.values.where((d) => scores.containsKey(d)).map((d) {
                      final s = scores[d]!;
                      final mins = s.seconds ~/ 60;
                      final secs = s.seconds % 60;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Win98Colors.darkGray),
                            color: Win98Colors.lightGray,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                d == Difficulty.beginner
                                    ? Icons.looks_one
                                    : d == Difficulty.intermediate
                                        ? Icons.looks_two
                                        : d == Difficulty.expert ? Icons.looks_3 : Icons.tune,
                                size: 16, color: Win98Colors.titleBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(d.label.split(' (')[0],
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Win98Colors.ledOn,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            _win98Button('Reset', () async {
              await ScoreManager.resetAll();
              if (ctx.mounted) Navigator.pop(ctx);
            }),
            _win98Button('Cerrar', () => Navigator.pop(ctx)),
          ],
        );
      },
    ),
  );
}

// ============================================================
// About Dialog
// ============================================================
void showAboutDialogStandard(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Win98Colors.gray,
      surfaceTintColor: Colors.transparent,
      shape: BeveledRectangleBorder(
        side: const BorderSide(color: Win98Colors.white, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      title: const Text('Acerca de Buscaminas 98',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content: const Text(
        'Buscaminas 98 - Arcade Edition\n\n'
        'Click izquierdo: Revelar celda\n'
        'Click derecho: Marcar bandera\n'
        '¡Recuerda los números!\n\n'
        'Dificultad personalizada con\n'
        'tamaño de grid ajustable.\n\n'
        'Modo arcade con sonidos,\n'
        'combos y efectos visuales.',
        style: TextStyle(fontSize: 12),
      ),
      actions: [
        _win98Button('OK', () => Navigator.pop(ctx)),
      ],
    ),
  );
}

// ============================================================
// Face Selection Dialog
// ============================================================
void showFaceDialog(
  BuildContext context, {
  required int currentIndex,
  required void Function(int) onSelect,
}) {
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          backgroundColor: Win98Colors.gray,
          surfaceTintColor: Colors.transparent,
          shape: BeveledRectangleBorder(
            side: const BorderSide(color: Win98Colors.white, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          title: const Row(
            children: [
              Icon(Icons.face, size: 18, color: Color(0xFFFFCC00)),
              SizedBox(width: 6),
              Text('Seleccionar Cara',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                (FaceStyle.faces.length / 2).ceil(),
                (rowIdx) {
                  final i0 = rowIdx * 2;
                  final i1 = rowIdx * 2 + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        _buildFaceOption(i0, currentIndex, (i) {
                          setDialogState(() => currentIndex = i);
                          onSelect(i);
                        }),
                        if (i1 < FaceStyle.faces.length) ...[const SizedBox(width: 4),
                          _buildFaceOption(i1, currentIndex, (i) {
                            setDialogState(() => currentIndex = i);
                            onSelect(i);
                          }),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            _win98Button('Cerrar', () => Navigator.pop(ctx)),
          ],
        );
      },
    ),
  );
}

Widget _buildFaceOption(int index, int selectedIndex, void Function(int) onSelect) {
  final face = FaceStyle.getFace(index);
  final isSelected = index == selectedIndex;
  return Expanded(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Win98Colors.titleBlue : Win98Colors.darkGray,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Win98Colors.titleBlue.withValues(alpha: 0.1)
                : Win98Colors.gray,
          ),
          child: Row(
            children: [
              Icon(face.playingIcon, size: 22, color: face.playingColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  face.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Win98Colors.titleBlue : Colors.black,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 14, color: Win98Colors.titleBlue),
            ],
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// Win98 Button helper
// ============================================================
Widget _win98Button(String label, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Win98Colors.darkGray),
        color: Win98Colors.gray,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    ),
  );
}
