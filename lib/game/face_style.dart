import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceConfig {
  final IconData playingIcon;
  final IconData pressedIcon;
  final IconData wonIcon;
  final IconData lostIcon;
  final Color playingColor;
  final String name;

  const FaceConfig({
    required this.playingIcon,
    required this.pressedIcon,
    required this.wonIcon,
    required this.lostIcon,
    required this.playingColor,
    required this.name,
  });
}

class FaceStyle {
  static const _key = 'buscaminas_face_index';

  static final List<FaceConfig> faces = [
    FaceConfig(
      name: 'Clásica 😊',
      playingIcon: Icons.sentiment_satisfied,
      pressedIcon: Icons.mood,
      wonIcon: Icons.emoji_events,
      lostIcon: Icons.mood_bad,
      playingColor: Color(0xFFFFCC00),
    ),
    FaceConfig(
      name: 'Cool 😎',
      playingIcon: Icons.mood,
      pressedIcon: Icons.sentiment_very_satisfied,
      wonIcon: Icons.emoji_events,
      lostIcon: Icons.sentiment_dissatisfied,
      playingColor: Color(0xFF00BFFF),
    ),
    FaceConfig(
      name: 'Amor 😍',
      playingIcon: Icons.favorite,
      pressedIcon: Icons.favorite_border,
      wonIcon: Icons.auto_awesome,
      lostIcon: Icons.hourglass_empty,
      playingColor: Color(0xFFFF69B4),
    ),
    FaceConfig(
      name: 'Fuego 🔥',
      playingIcon: Icons.local_fire_department,
      pressedIcon: Icons.whatshot,
      wonIcon: Icons.emoji_events,
      lostIcon: Icons.ac_unit,
      playingColor: Color(0xFFFF4500),
    ),
    FaceConfig(
      name: 'Retro 🕹️',
      playingIcon: Icons.videogame_asset,
      pressedIcon: Icons.gamepad,
      wonIcon: Icons.star,
      lostIcon: Icons.dangerous,
      playingColor: Color(0xFF808080),
    ),
    FaceConfig(
      name: 'Animal 🐱',
      playingIcon: Icons.pets,
      pressedIcon: Icons.cruelty_free,
      wonIcon: Icons.emoji_events,
      lostIcon: Icons.bug_report,
      playingColor: Color(0xFF8B4513),
    ),
    FaceConfig(
      name: 'Risa 🤣',
      playingIcon: Icons.emoji_emotions,
      pressedIcon: Icons.sentiment_very_satisfied,
      wonIcon: Icons.celebration,
      lostIcon: Icons.sentiment_very_dissatisfied,
      playingColor: Color(0xFFFF6347),
    ),
  ];

  static Future<int> getIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  static Future<void> setIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index.clamp(0, faces.length - 1));
  }

  static FaceConfig getFace(int index) {
    return faces[index.clamp(0, faces.length - 1)];
  }
}
