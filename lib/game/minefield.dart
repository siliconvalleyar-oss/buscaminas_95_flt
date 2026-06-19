import 'dart:math';
import 'cell.dart';

enum GameState { playing, won, lost }

enum Difficulty {
  beginner,
  intermediate,
  expert,
  custom;

  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'Principiante (9×9, 10 minas)';
      case Difficulty.intermediate:
        return 'Intermedio (16×16, 40 minas)';
      case Difficulty.expert:
        return 'Experto (30×16, 99 minas)';
      case Difficulty.custom:
        return 'Personalizado';
    }
  }
}

class DifficultyConfig {
  final int rows;
  final int cols;
  final int mines;

  const DifficultyConfig(this.rows, this.cols, this.mines);

  int get totalCells => rows * cols;

  bool get isValid =>
      rows >= 5 && rows <= 50 &&
      cols >= 5 && cols <= 50 &&
      mines >= 1 && mines < totalCells;

  static const beginner = DifficultyConfig(9, 9, 10);
  static const intermediate = DifficultyConfig(16, 16, 40);
  static const expert = DifficultyConfig(30, 16, 99);
  static const defaultCustom = DifficultyConfig(10, 10, 15);

  static DifficultyConfig fromDifficulty(Difficulty d) {
    switch (d) {
      case Difficulty.beginner:
        return beginner;
      case Difficulty.intermediate:
        return intermediate;
      case Difficulty.expert:
        return expert;
      case Difficulty.custom:
        return defaultCustom;
    }
  }
}

class Minefield {
  final int rows;
  final int cols;
  final int mineCount;
  late List<List<Cell>> grid;
  GameState state = GameState.playing;
  int flagsPlaced = 0;
  int cellsRevealed = 0;
  DateTime? startTime;
  Duration elapsed = Duration.zero;

  Minefield({required this.rows, required this.cols, required this.mineCount}) {
    _initGrid();
  }

  void _initGrid() {
    grid = List.generate(rows, (r) => List.generate(cols, (c) => Cell(r, c)));
    flagsPlaced = 0;
    cellsRevealed = 0;
    state = GameState.playing;
    startTime = null;
    elapsed = Duration.zero;
  }

  void placeMines({required int avoidRow, required int avoidCol}) {
    final random = Random();
    int placed = 0;
    while (placed < mineCount) {
      final r = random.nextInt(rows);
      final c = random.nextInt(cols);
      if ((r - avoidRow).abs() <= 1 && (c - avoidCol).abs() <= 1) continue;
      if (!grid[r][c].isMine) {
        grid[r][c].isMine = true;
        placed++;
      }
    }
    _calculateAdjacent();
  }

  void _calculateAdjacent() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c].isMine) continue;
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = r + dr;
            final nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc].isMine) {
              count++;
            }
          }
        }
        grid[r][c].adjacentMines = count;
      }
    }
  }

  bool reveal(int row, int col) {
    if (state != GameState.playing) return false;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return false;
    final cell = grid[row][col];
    if (cell.isRevealed || cell.isFlagged) return false;

    if (startTime == null) {
      startTime = DateTime.now();
      placeMines(avoidRow: row, avoidCol: col);
    }

    if (cell.isMine) {
      cell.isRevealed = true;
      state = GameState.lost;
      _revealAllMines();
      return false;
    }

    _floodFill(row, col);
    _checkWin();
    return true;
  }

  void _floodFill(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return;
    final cell = grid[row][col];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) return;

    cell.isRevealed = true;
    cellsRevealed++;

    if (cell.adjacentMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _floodFill(row + dr, col + dc);
        }
      }
    }
  }

  void toggleFlag(int row, int col) {
    if (state != GameState.playing) return;
    if (row < 0 || row >= rows || col < 0 || col >= cols) return;
    final cell = grid[row][col];
    if (cell.isRevealed) return;

    cell.isFlagged = !cell.isFlagged;
    flagsPlaced += cell.isFlagged ? 1 : -1;
    _checkWin();
  }

  void _revealAllMines() {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isMine) cell.isRevealed = true;
      }
    }
  }

  void _checkWin() {
    if (cellsRevealed == rows * cols - mineCount) {
      state = GameState.won;
    }
  }

  void reset() {
    _initGrid();
  }

  Set<Cell> getWrongFlags() {
    final wrong = <Cell>{};
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isFlagged && !cell.isMine) {
          wrong.add(cell);
        }
      }
    }
    return wrong;
  }
}
