import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/cell.dart';
import 'game/minefield.dart';
import 'game/score_manager.dart';
import 'game/face_style.dart';
import 'audio/sound_manager.dart';
import 'styles/win98_colors.dart';
import 'effects/particles.dart';
import 'painters/cell_painter.dart';
import 'painters/led_painter.dart';
import 'ui/win98_widgets.dart';
import 'ui/win98_dialogs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const BuscaminasApp());
}

class BuscaminasApp extends StatelessWidget {
  const BuscaminasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaminas 98',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008080)),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Minefield _minefield;
  late SoundManager _soundManager;
  Difficulty _difficulty = Difficulty.custom;
  int _customRows = 10;
  int _customCols = 10;
  int _customMines = 15;
  double _cellSizePref = 0;
  bool _firstClick = true;
  bool _pressingFace = false;

  late AnimationController _shakeController;
  final List<Particle> _particles = [];
  final List<ConfettiPiece> _confetti = [];
  late AnimationController _particleController;
  int _comboCount = 0;
  bool _timerWarning = false;
  bool _newRecord = false;
  int _faceIndex = 0;

  Timer? _gameTimer;

  DifficultyConfig get _currentConfig {
    switch (_difficulty) {
      case Difficulty.beginner:
        return DifficultyConfig.beginner;
      case Difficulty.intermediate:
        return DifficultyConfig.intermediate;
      case Difficulty.expert:
        return DifficultyConfig.expert;
      case Difficulty.custom:
        return DifficultyConfig(_customRows, _customCols, _customMines);
    }
  }

  @override
  void initState() {
    super.initState();
    _soundManager = SoundManager();
    _soundManager.init();
    _loadFaceStyle();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles);

    _initGame();
  }

  void _loadFaceStyle() async {
    final index = await FaceStyle.getIndex();
    if (mounted) setState(() => _faceIndex = index);
  }

  void _initGame() {
    final config = _currentConfig;
    _minefield = Minefield(
      rows: config.rows,
      cols: config.cols,
      mineCount: config.mines,
    );
    _firstClick = true;
    _comboCount = 0;
    _particles.clear();
    _confetti.clear();
    _timerWarning = false;
    _newRecord = false;
    _gameTimer?.cancel();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_minefield.startTime != null && _minefield.state == GameState.playing) {
        setState(() {
          _minefield.elapsed = DateTime.now().difference(_minefield.startTime!);
          _timerWarning = _minefield.elapsed.inSeconds >= 30;
        });
      }
    });
  }

  void _onCellTap(int row, int col) {
    if (_minefield.state == GameState.lost || _minefield.state == GameState.won) {
      _initGame();
      setState(() {});
      return;
    }

    final prevRevealed = _minefield.cellsRevealed;
    final hitMine = !_minefield.reveal(row, col);
    final newRevealed = _minefield.cellsRevealed - prevRevealed;

    if (_firstClick && _minefield.startTime != null) {
      _firstClick = false;
      _startTimer();
    }

    if (hitMine) {
      _comboCount = 0;
      _particles.addAll(createExplosionParticles(
        Offset(col * 30 + 15, row * 30 + 95),
      ));
      _soundManager.play('explosion');
      _shakeController.forward(from: 0);
      _particleController.repeat(period: const Duration(milliseconds: 16));
    } else {
      if (newRevealed > 1) {
        _comboCount += newRevealed;
        _soundManager.play('reveal');
      } else {
        _comboCount = max(0, _comboCount - 1);
        _soundManager.play('click');
      }

      if (_minefield.state == GameState.won) {
        _confetti.addAll(createConfettiPieces());
        _soundManager.play('win');
        _gameTimer?.cancel();
        _particleController.repeat(period: const Duration(milliseconds: 16));
        _checkNewRecord();
      }
    }
    setState(() {});
  }

  void _onCellSecondaryTap(int row, int col) {
    if (_minefield.state == GameState.lost || _minefield.state == GameState.won) return;
    _minefield.toggleFlag(row, col);
    _soundManager.play('flag');
    if (_minefield.state == GameState.won) {
      _confetti.addAll(createConfettiPieces());
      _soundManager.play('win');
      _gameTimer?.cancel();
      _particleController.repeat(period: const Duration(milliseconds: 16));
      _checkNewRecord();
    }
    setState(() {});
  }

  void _checkNewRecord() async {
    final elapsed = _minefield.elapsed.inSeconds;
    final config = _currentConfig;
    final isRecord = await ScoreManager.saveIfBest(
      difficulty: _difficulty,
      seconds: elapsed,
      rows: config.rows,
      cols: config.cols,
      mines: config.mines,
    );
    if (isRecord && mounted) setState(() => _newRecord = true);
  }

  void _updateParticles() {
    const dt = 0.016;
    setState(() {
      for (final p in _particles) p.update(dt);
      _particles.removeWhere((p) => !p.isAlive);
      for (final c in _confetti) c.update(dt);
      _confetti.removeWhere((c) => !c.isAlive);
      if (_particles.isEmpty && _confetti.isEmpty) _particleController.stop();
    });
  }

  void _changeDifficulty(Difficulty d) {
    if (d == Difficulty.custom) {
      _showCustomDialog();
      return;
    }
    setState(() {
      _difficulty = d;
      _initGame();
    });
  }

  Future<void> _showCustomDialog() async {
    final config = await showCustomDialog(
      context,
      initialRows: _customRows,
      initialCols: _customCols,
      initialMines: _customMines,
      initialCellSize: _cellSizePref,
    );
    if (config != null && mounted) {
      setState(() {
        _difficulty = Difficulty.custom;
        _customRows = config.rows;
        _customCols = config.cols;
        _customMines = config.mines;
        _cellSizePref = config.cellSize;
        _initGame();
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _particleController.dispose();
    _gameTimer?.cancel();
    _soundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Win98Colors.tealBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shakeOffset = _shakeController.isAnimating
                    ? Offset(
                        sin(_shakeController.value * 50) * 4,
                        cos(_shakeController.value * 37) * 3,
                      )
                    : Offset.zero;
                return Transform.translate(offset: shakeOffset, child: child);
              },
              child: _buildGameWindow(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameWindow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Win98Window(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleBar(),
              _buildMenuBar(),
              _buildStatusBar(),
              _buildGameBoard(constraints),
              _buildComboDisplay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleBar() {
    return Win98TitleBar(
      title: ' Buscaminas 98 — ${_currentConfig.rows}×${_currentConfig.cols} (${_currentConfig.mines} minas)',
      actions: [
        Win98TitleButton(label: '_', onPressed: () {}),
        Win98TitleButton(label: '□', onPressed: () {}),
        Win98TitleButton(label: 'X', onPressed: () {}),
      ],
    );
  }

  Widget _buildMenuBar() {
    return Win98MenuBar(items: [
      Win98MenuItem('Juego', () => showDifficultyDialog(context, currentDifficulty: _difficulty, onSelect: _changeDifficulty)),
      Win98MenuItem('Dificultad', () => showDifficultyDialog(context, currentDifficulty: _difficulty, onSelect: _changeDifficulty)),
      Win98MenuItem('Puntos', () => showScoresDialog(context)),
      Win98MenuItem('Caras', () => _showFaceDialog()),
      Win98MenuItem('Ayuda', () => showAboutDialogStandard(context)),
    ]);
  }

  void _showFaceDialog() {
    showFaceDialog(
      context,
      currentIndex: _faceIndex,
      onSelect: (i) {
        _faceIndex = i;
        FaceStyle.setIndex(i);
        setState(() {});
      },
    );
  }

  Widget _buildStatusBar() {
    final remaining = _minefield.mineCount - _minefield.flagsPlaced;
    final elapsed = _minefield.elapsed.inSeconds;
    return Win98StatusBar(
      left: Win98LedDisplay(text: remaining.clamp(0, 999).toString().padLeft(3, '0')),
      center: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Win98MuteButton(
            isMuted: !_soundManager.enabled,
            onToggle: () {
              setState(() {
                _soundManager.enabled = !_soundManager.enabled;
                if (_soundManager.enabled) _soundManager.play('click');
              });
            },
          ),
          const SizedBox(width: 4),
          _buildFaceButton(),
        ],
      ),
      right: Win98LedDisplay(
        text: min(elapsed, 999).toString().padLeft(3, '0'),
        warning: _timerWarning && _minefield.state == GameState.playing,
      ),
    );
  }

  Widget _buildFaceButton() {
    final faceConfig = FaceStyle.getFace(_faceIndex);
    IconData faceIcon;
    Color faceColor;

    switch (_minefield.state) {
      case GameState.won:
        faceIcon = faceConfig.wonIcon;
        faceColor = const Color(0xFFFFD700);
      case GameState.lost:
        faceIcon = faceConfig.lostIcon;
        faceColor = Colors.black;
      default:
        faceIcon = _pressingFace ? faceConfig.pressedIcon : faceConfig.playingIcon;
        faceColor = faceConfig.playingColor;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressingFace = true),
      onTapUp: (_) {
        setState(() => _pressingFace = false);
        _initGame();
      },
      onTapCancel: () => setState(() => _pressingFace = false),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: _pressingFace ? Win98Colors.darkGray : Win98Colors.white, width: 2),
            left: BorderSide(color: _pressingFace ? Win98Colors.darkGray : Win98Colors.white, width: 2),
            right: BorderSide(color: _pressingFace ? Win98Colors.white : Win98Colors.darkGray, width: 2),
            bottom: BorderSide(color: _pressingFace ? Win98Colors.white : Win98Colors.darkGray, width: 2),
          ),
          color: Win98Colors.gray,
        ),
        child: Icon(faceIcon, color: faceColor, size: 24),
      ),
    );
  }

  Widget _buildGameBoard(BoxConstraints parentConstraints) {
    final config = _currentConfig;
    const headerHeight = 28 + 22 + 50 + 6;
    const comboHeight = 20;
    final availableW = parentConstraints.maxWidth - 20;
    final availableH = parentConstraints.maxHeight - headerHeight - comboHeight - 20;
    final cellW = availableW / config.cols;
    final cellH = availableH / config.rows;
    final autoSize = min(cellW, cellH);
    final cellSize = _cellSizePref > 0
        ? min(_cellSizePref, autoSize).clamp(4.0, autoSize)
        : autoSize.clamp(4.0, 60.0);

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: Win98Colors.darkGray, width: 2),
          left: const BorderSide(color: Win98Colors.darkGray, width: 2),
          right: const BorderSide(color: Win98Colors.white, width: 2),
          bottom: const BorderSide(color: Win98Colors.white, width: 2),
        ),
        color: Win98Colors.gray,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(config.rows, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(config.cols, (c) => _buildCell(r, c, cellSize)),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int row, int col, double size) {
    final cell = _minefield.grid[row][col];
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _onCellTap(row, col),
        onSecondaryTap: () => _onCellSecondaryTap(row, col),
        onLongPress: () => _onCellSecondaryTap(row, col),
        child: CustomPaint(
          painter: CellPainter(cell: cell, state: _minefield.state, cellSize: size),
        ),
      ),
    );
  }

  Widget _buildComboDisplay() {
    final showCombo = _comboCount >= 3;
    final showRecord = _newRecord;
    if (!showCombo && !showRecord) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCombo)
            Text(
              '🔥 Combo x$_comboCount',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2)],
              ),
            ),
          if (showRecord)
            Text(
              '🏆 ¡Nuevo récord!',
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 3)],
              ),
            ),
        ],
      ),
    );
  }
}
