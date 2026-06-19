class Cell {
  final int row;
  final int col;
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int adjacentMines = 0;

  Cell(this.row, this.col);

  void reset() {
    isMine = false;
    isRevealed = false;
    isFlagged = false;
    adjacentMines = 0;
  }
}
