import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/cell.dart';
import 'game/minefield.dart';
import 'game/score_manager.dart';
import 'audio/sound_manager.dart';

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

class Win98Colors {
  static const tealBg = Color(0xFF008080);
  static const gray = Color(0xFFC0C0C0);
  static const darkGray = Color(0xFF808080);
  static const lightGray = Color(0xFFE0E0E0);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const titleBlue = Color(0xFF000080);
  static const ledBg = Color(0xFF1A0000);
  static const ledOn = Color(0xFFFF0000);
  static const ledOff = Color(0xFF600000);

  static const numColors = [
    Colors.transparent,
    Color(0xFF0000FF),
    Color(0xFF008000),
    Color(0xFFFF0000),
    Color(0xFF000080),
    Color(0xFF800000),
    Color(0xFF008080),
    Color(0xFF000000),
    Color(0xFF808080),
  ];
}

class Particle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  Color color;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    this.size = 3,
  });

  bool get isAlive => life > 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 200) * dt;
    life -= dt;
  }
}

class ConfettiPiece {
  Offset position;
  Offset velocity;
  double rotation;
  double rotVelocity;
  double life;
  double maxLife;
  Color color;
  double size;

  ConfettiPiece({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotVelocity,
    required this.life,
    required this.maxLife,
    required this.color,
    this.size = 6,
  });

  bool get isAlive => life > 0;

  void update(double dt) {
    position += velocity * dt;
    velocity += const Offset(0, 150) * dt;
    velocity = Offset(velocity.dx * 0.98, velocity.dy);
    rotation += rotVelocity * dt;
    life -= dt;
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
      _triggerExplosion(row, col);
      _soundManager.play('explosion');
      _shakeController.forward(from: 0);
    } else {
      if (newRevealed > 1) {
        _comboCount += newRevealed;
        _soundManager.play('reveal');
      } else {
        _comboCount = max(0, _comboCount - 1);
        _soundManager.play('click');
      }

      if (_minefield.state == GameState.won) {
        _triggerConfetti();
        _soundManager.play('win');
        _gameTimer?.cancel();
        _checkNewRecord();
      }
    }

    setState(() {});
  }

  void _onCellSecondaryTap(int row, int col) {
    if (_minefield.state == GameState.lost || _minefield.state == GameState.won) {
      return;
    }
    _minefield.toggleFlag(row, col);
    _soundManager.play('flag');

    if (_minefield.state == GameState.won) {
      _triggerConfetti();
      _soundManager.play('win');
      _gameTimer?.cancel();
      _checkNewRecord();
    }

    setState(() {});
  }

  void _triggerExplosion(int row, int col) {
    final rng = Random();
    final cellSize = 30.0;
    for (int i = 0; i < 30; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 50 + rng.nextDouble() * 200;
      _particles.add(Particle(
        position: Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2 + 80),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        life: 0.3 + rng.nextDouble() * 0.5,
        maxLife: 0.8,
        color: Color.fromARGB(255, 200 + rng.nextInt(56), rng.nextInt(100), 0),
        size: 2 + rng.nextDouble() * 3,
      ));
    }
    _particleController.repeat(period: const Duration(milliseconds: 16));
  }

  void _triggerConfetti() {
    final rng = Random();
    final colors = [
      Colors.red, Colors.blue, Colors.yellow, Colors.green,
      Colors.purple, Colors.orange, Colors.pink, Colors.cyan,
    ];
    for (int i = 0; i < 60; i++) {
      _confetti.add(ConfettiPiece(
        position: Offset(
          rng.nextDouble() * 400,
          -20 - rng.nextDouble() * 100,
        ),
        velocity: Offset(
          (rng.nextDouble() - 0.5) * 200,
          rng.nextDouble() * 200 + 50,
        ),
        rotation: rng.nextDouble() * 2 * pi,
        rotVelocity: (rng.nextDouble() - 0.5) * 10,
        life: 1.5 + rng.nextDouble() * 2,
        maxLife: 3.5,
        color: colors[rng.nextInt(colors.length)],
        size: 4 + rng.nextDouble() * 4,
      ));
    }
    _particleController.repeat(period: const Duration(milliseconds: 16));
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
    if (isRecord && mounted) {
      setState(() => _newRecord = true);
    }
  }

  void _updateParticles() {
    const dt = 0.016;
    setState(() {
      for (final p in _particles) {
        p.update(dt);
      }
      _particles.removeWhere((p) => !p.isAlive);

      for (final c in _confetti) {
        c.update(dt);
      }
      _confetti.removeWhere((c) => !c.isAlive);

      if (_particles.isEmpty && _confetti.isEmpty) {
        _particleController.stop();
      }
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

  void _applyCustom(int rows, int cols, int mines, double cellSize) {
    setState(() {
      _difficulty = Difficulty.custom;
      _customRows = rows;
      _customCols = cols;
      _customMines = mines;
      _cellSizePref = cellSize;
      _initGame();
    });
  }

  void _showDifficultyDialog() {
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
                    _changeDifficulty(d);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Win98Colors.darkGray),
                      color: _difficulty == d
                          ? const Color(0xFF000080)
                          : Win98Colors.gray,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _difficulty == d ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: _difficulty == d ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: _difficulty == d ? Colors.white : Colors.black,
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Win98Colors.darkGray),
                color: Win98Colors.gray,
              ),
              child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDialog() {
    int rows = _customRows;
    int cols = _customCols;
    int mines = _customMines;
    double cellSize = _cellSizePref;

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
                    final maxMines = rows * cols - 1;
                    if (mines > maxMines) mines = maxMines;
                  }),
                  const SizedBox(height: 8),
                  _buildSlider(ctx, setDialogState, 'Columnas', cols, 5, 50, (v) {
                    cols = v;
                    final maxMines = rows * cols - 1;
                    if (mines > maxMines) mines = maxMines;
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
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Win98Colors.darkGray),
                    color: Win98Colors.gray,
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (mines >= rows * cols) mines = rows * cols - 1;
                  Navigator.pop(ctx);
                  _applyCustom(rows, cols, mines, cellSize);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Win98Colors.darkGray),
                    color: Win98Colors.gray,
                  ),
                  child: const Text('Aplicar', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          );
        },
      ),
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
            SizedBox(
              width: 30,
              child: Text('$min',
                  style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray)),
            ),
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
                  onChanged: (v) {
                    setDialogState(() {
                      onChange(v.round());
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text('$max',
                  style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray)),
            ),
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
            SizedBox(
              width: 30,
              child: Text('${min.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray)),
            ),
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
                  onChanged: (v) {
                    setDialogState(() {
                      onChange(v);
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text('${max.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Win98Colors.darkGray)),
            ),
          ],
        ),
      ],
    );
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
                return Transform.translate(
                  offset: shakeOffset,
                  child: child,
                );
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
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Win98Colors.white, width: 3),
            color: Win98Colors.gray,
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: const BoxDecoration(
        color: Win98Colors.titleBlue,
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A8A), Win98Colors.titleBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report, size: 16, color: Colors.yellow),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              ' Buscaminas 98 — ${_currentConfig.rows}×${_currentConfig.cols} (${_currentConfig.mines} minas)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildTitleButton('_', Icons.horizontal_rule, () {}),
          _buildTitleButton('□', Icons.crop_square, () {}),
          _buildTitleButton('X', Icons.close, () {}),
        ],
      ),
    );
  }

  Widget _buildTitleButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 20,
      height: 18,
      margin: const EdgeInsets.only(left: 2),
      child: Material(
        color: Win98Colors.gray,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: const BorderSide(color: Win98Colors.white, width: 1.5),
                left: const BorderSide(color: Win98Colors.white, width: 1.5),
                right: const BorderSide(color: Win98Colors.black, width: 1.5),
                bottom: const BorderSide(color: Win98Colors.black, width: 1.5),
              ),
              color: Win98Colors.gray,
            ),
            child: FittedBox(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: const BoxDecoration(
        color: Win98Colors.gray,
        border: Border(
          bottom: BorderSide(color: Win98Colors.darkGray),
        ),
      ),
      child: Row(
        children: [
          _buildMenuItem('Juego', _showDifficultyDialog),
          const SizedBox(width: 4),
          _buildMenuItem('Dificultad', _showDifficultyDialog),
          const SizedBox(width: 4),
          _buildMenuItem('Puntos', _showScoresDialog),
          const SizedBox(width: 4),
          _buildMenuItem('Ayuda', _showAboutDialog),
        ],
      ),
    );
  }

  void _showScoresDialog() {
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
                                          : d == Difficulty.expert
                                              ? Icons.looks_3
                                              : Icons.tune,
                                  size: 16,
                                  color: Win98Colors.titleBlue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    d.label.split(' (')[0],
                                    style: const TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
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
              TextButton(
                onPressed: () async {
                  await ScoreManager.resetAll();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Win98Colors.darkGray),
                    color: Win98Colors.gray,
                  ),
                  child: const Text('Reset', style: TextStyle(fontSize: 11)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Win98Colors.darkGray),
                    color: Win98Colors.gray,
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Win98Colors.darkGray),
                color: Win98Colors.gray,
              ),
              child: const Text('OK', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                decoration: TextDecoration.none)),
      ),
    );
  }

  Widget _buildStatusBar() {
    final remaining = _minefield.mineCount - _minefield.flagsPlaced;
    final elapsed = _minefield.elapsed.inSeconds;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Win98Colors.darkGray, width: 2),
        ),
        color: Win98Colors.gray,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLedDisplay(remaining.clamp(0, 999).toString().padLeft(3, '0')),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMuteButton(),
              const SizedBox(width: 4),
              _buildFaceButton(),
            ],
          ),
          _buildLedDisplay(
              min(elapsed, 999).toString().padLeft(3, '0'),
              warning: _timerWarning && _minefield.state == GameState.playing),
        ],
      ),
    );
  }

  Widget _buildLedDisplay(String text, {bool warning = false}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Win98Colors.ledBg,
        border: Border(
          top: const BorderSide(color: Win98Colors.black, width: 1),
          left: const BorderSide(color: Win98Colors.black, width: 1),
          right: const BorderSide(color: Win98Colors.darkGray, width: 1),
          bottom: const BorderSide(color: Win98Colors.darkGray, width: 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: text.split('').map((c) {
          return Container(
            width: 18,
            height: 28,
            alignment: Alignment.center,
            child: _buildLedChar(c, warning),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLedChar(String char, bool warning) {
    return CustomPaint(
      size: const Size(16, 28),
      painter: _LedCharPainter(char: char, warning: warning),
    );
  }

  Widget _buildMuteButton() {
    final isMuted = !_soundManager.enabled;
    return GestureDetector(
      onTap: () {
        setState(() {
          _soundManager.enabled = !_soundManager.enabled;
          if (_soundManager.enabled) {
            _soundManager.play('click');
          }
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Win98Colors.darkGray),
          color: Win98Colors.gray,
        ),
        child: Icon(
          isMuted ? Icons.volume_off : Icons.volume_up,
          size: 14,
          color: isMuted ? Win98Colors.darkGray : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFaceButton() {
    IconData faceIcon;
    Color faceColor;

    switch (_minefield.state) {
      case GameState.won:
        faceIcon = Icons.emoji_events;
        faceColor = const Color(0xFFFFD700);
      case GameState.lost:
        faceIcon = Icons.mood_bad;
        faceColor = Colors.black;
      default:
        faceIcon = _pressingFace ? Icons.mood : Icons.sentiment_satisfied;
        faceColor = const Color(0xFFFFCC00);
    }

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressingFace = true);
      },
      onTapUp: (_) {
        setState(() => _pressingFace = false);
        _initGame();
      },
      onTapCancel: () {
        setState(() => _pressingFace = false);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: _pressingFace ? Win98Colors.darkGray : Win98Colors.white,
                width: 2),
            left: BorderSide(
                color: _pressingFace ? Win98Colors.darkGray : Win98Colors.white,
                width: 2),
            right: BorderSide(
                color: _pressingFace ? Win98Colors.white : Win98Colors.darkGray,
                width: 2),
            bottom: BorderSide(
                color: _pressingFace ? Win98Colors.white : Win98Colors.darkGray,
                width: 2),
          ),
          color: Win98Colors.gray,
        ),
        child: Icon(faceIcon, color: faceColor, size: 24),
      ),
    );
  }

  Widget _buildGameBoard(BoxConstraints parentConstraints) {
    final config = _currentConfig;
    final headerHeight = 28 + 22 + 50 + 6;
    final comboHeight = 20;
    final availableW = parentConstraints.maxWidth - 20;
    final availableH = parentConstraints.maxHeight - headerHeight - comboHeight - 20;
    final cellW = availableW / config.cols;
    final cellH = availableH / config.rows;
    final autoSize = min(cellW, cellH);
    final cellSize = _cellSizePref > 0
        ? min(_cellSizePref, autoSize).clamp(4.0, autoSize)
        : autoSize.clamp(4.0, double.infinity);

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
            children: List.generate(config.cols, (c) {
              return _buildCell(r, c, cellSize);
            }),
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
          painter: _CellPainter(
            cell: cell,
            state: _minefield.state,
            cellSize: size,
          ),
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
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          if (showRecord)
            Text(
              '🏆 ¡Nuevo récord!',
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CellPainter extends CustomPainter {
  final Cell cell;
  final GameState state;
  final double cellSize;

  _CellPainter({required this.cell, required this.state, required this.cellSize});

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
  bool shouldRepaint(_CellPainter old) =>
      cell.isRevealed != old.cell.isRevealed ||
      cell.isFlagged != old.cell.isFlagged ||
      state != old.state ||
      cellSize != old.cellSize;
}

class _LedCharPainter extends CustomPainter {
  final String char;
  final bool warning;

  _LedCharPainter({required this.char, required this.warning});

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

    // Proporciones estilo Minesweeper 98 original
    final segThick = 3.0; // grosor de segmento (pixel-art nítido)
    final gap = 2.0;      // espacio desde el borde
    final vertLen = (h / 2) - gap - segThick - 1.0; // largo segmentos verticales

    final segs = _segments[char] ?? [false, false, false, false, false, false, false];
    final onColor = warning ? const Color(0xFFFF4400) : Win98Colors.ledOn;
    final offColor = warning ? const Color(0xFF441100) : Win98Colors.ledOff;

    // seg0: horizontal superior
    _drawSeg(canvas, Offset(gap, 1.0), w - gap * 2, segThick, true, segs[0] ? onColor : offColor);
    // seg1: vertical superior derecha
    _drawSeg(canvas, Offset(w - segThick - 1, gap), segThick, vertLen, false,
        segs[1] ? onColor : offColor);
    // seg2: vertical inferior derecha
    _drawSeg(canvas, Offset(w - segThick - 1, h / 2 + 1), segThick, vertLen, false,
        segs[2] ? onColor : offColor);
    // seg3: horizontal inferior
    _drawSeg(canvas, Offset(gap, h - segThick - 1), w - gap * 2, segThick, true,
        segs[3] ? onColor : offColor);
    // seg4: vertical inferior izquierda
    _drawSeg(canvas, Offset(1, h / 2 + 1), segThick, vertLen, false,
        segs[4] ? onColor : offColor);
    // seg5: vertical superior izquierda
    _drawSeg(canvas, Offset(1, gap), segThick, vertLen, false, segs[5] ? onColor : offColor);
    // seg6: horizontal medio
    _drawSeg(canvas, Offset(gap, h / 2 - segThick / 2), w - gap * 2, segThick, true,
        segs[6] ? onColor : offColor);
  }

  void _drawSeg(Canvas canvas, Offset pos, double w, double h, bool horizontal, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(pos.dx, pos.dy, w, h);
    canvas.drawRect(rect, paint);

    if (color != Win98Colors.ledOff && color != const Color(0xFF441100)) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawRect(rect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_LedCharPainter old) => char != old.char || warning != old.warning;
}
