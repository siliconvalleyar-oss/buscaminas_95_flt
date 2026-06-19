import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  final Map<String, Uint8List> _sounds = {};
  final List<AudioPlayer> _players = [];
  bool enabled = true;

  Future<void> init() async {
    _sounds['click'] = _generateClick();
    _sounds['flag'] = _generateFlag();
    _sounds['explosion'] = _generateExplosion();
    _sounds['win'] = _generateWin();
    _sounds['reveal'] = _generateReveal();
  }

  Uint8List _generateWav(Float64List samples) {
    const sampleRate = 22050;
    final dataLength = samples.length;
    const blockAlign = 1;
    final dataSize = dataLength * blockAlign;
    final fileSize = 44 + dataSize;

    final bytes = ByteData(fileSize);

    bytes.setUint8(0, 0x52);
    bytes.setUint8(1, 0x49);
    bytes.setUint8(2, 0x46);
    bytes.setUint8(3, 0x46);
    bytes.setUint32(4, fileSize - 8, Endian.little);
    bytes.setUint8(8, 0x57);
    bytes.setUint8(9, 0x41);
    bytes.setUint8(10, 0x56);
    bytes.setUint8(11, 0x45);

    bytes.setUint8(12, 0x66);
    bytes.setUint8(13, 0x6d);
    bytes.setUint8(14, 0x74);
    bytes.setUint8(15, 0x20);
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate, Endian.little);
    bytes.setUint16(32, blockAlign, Endian.little);
    bytes.setUint16(34, 8, Endian.little);

    bytes.setUint8(36, 0x64);
    bytes.setUint8(37, 0x61);
    bytes.setUint8(38, 0x74);
    bytes.setUint8(39, 0x61);
    bytes.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < dataLength; i++) {
      int sample = (samples[i] * 127 + 128).round().clamp(0, 255);
      bytes.setUint8(44 + i, sample);
    }

    return bytes.buffer.asUint8List();
  }

  Uint8List _generateClick() {
    const sr = 22050;
    const duration = 0.04;
    final n = (sr * duration).toInt();
    final samples = Float64List(n);
    for (int i = 0; i < n; i++) {
      final t = i / sr;
      final envelope = exp(-t * 120);
      samples[i] = sin(2 * pi * 600 * t) * envelope * 0.3;
    }
    return _generateWav(samples);
  }

  Uint8List _generateFlag() {
    const sr = 22050;
    const duration = 0.06;
    final n = (sr * duration).toInt();
    final samples = Float64List(n);
    for (int i = 0; i < n; i++) {
      final t = i / sr;
      final envelope = exp(-t * 90);
      samples[i] = (sin(2 * pi * 800 * t) + sin(2 * pi * 1200 * t) * 0.3) * envelope * 0.25;
    }
    return _generateWav(samples);
  }

  Uint8List _generateExplosion() {
    const sr = 22050;
    const duration = 0.5;
    final n = (sr * duration).toInt();
    final samples = Float64List(n);
    final rng = Random();
    for (int i = 0; i < n; i++) {
      final t = i / sr;
      final envelope = exp(-t * 6) * (1 - exp(-t * 40));
      final noise = (rng.nextDouble() * 2 - 1) * 0.6;
      final rumble = sin(2 * pi * 60 * t) * 0.4;
      final crackle = (rng.nextDouble() * 2 - 1) * exp(-t * 20) * 0.5;
      samples[i] = (noise + rumble + crackle) * envelope * 0.5;
    }
    return _generateWav(samples);
  }

  Uint8List _generateWin() {
    const sr = 22050;
    const notes = [523.25, 659.25, 783.99, 1046.50];
    const noteDuration = 0.15;
    final totalDuration = notes.length * noteDuration + 0.1;
    final n = (sr * totalDuration).toInt();
    final samples = Float64List(n);
    for (int ni = 0; ni < notes.length; ni++) {
      final freq = notes[ni];
      final startSample = (ni * noteDuration * sr).toInt();
      final endSample = ((ni + 1) * noteDuration * sr + (sr * 0.02)).toInt().clamp(0, n);
      for (int i = startSample; i < endSample && i < n; i++) {
        final t = (i - startSample) / sr;
        final noteLen = min(noteDuration + 0.02, totalDuration - ni * noteDuration);
        final envelope = sin(pi * t / noteLen).clamp(0.0, 1.0);
        samples[i] += sin(2 * pi * freq * t) * envelope * 0.3;
      }
    }
    return _generateWav(samples);
  }

  Uint8List _generateReveal() {
    const sr = 22050;
    const duration = 0.06;
    final n = (sr * duration).toInt();
    final samples = Float64List(n);
    for (int i = 0; i < n; i++) {
      final t = i / sr;
      final freq = 300 + 800 * (t / duration);
      final envelope = sin(pi * t / duration).clamp(0.0, 1.0);
      samples[i] = sin(2 * pi * freq * t) * envelope * 0.15;
    }
    return _generateWav(samples);
  }

  Future<void> play(String name) async {
    if (!enabled) return;
    final data = _sounds[name];
    if (data == null) return;

    try {
      final player = AudioPlayer();
      _players.add(player);
      await player.setSource(BytesSource(data));
      await player.resume();
      player.onPlayerComplete.listen((_) {
        player.dispose();
        _players.remove(player);
      });
    } catch (_) {}
  }

  void dispose() {
    for (final p in _players) {
      p.dispose();
    }
    _players.clear();
  }
}
