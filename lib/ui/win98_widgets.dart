import 'package:flutter/material.dart';
import '../styles/win98_colors.dart';
import '../painters/led_painter.dart';

// ============================================================
// Win98 Title Bar
// ============================================================
class Win98TitleBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const Win98TitleBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
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
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class Win98TitleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const Win98TitleButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
}

// ============================================================
// Win98 Menu Bar
// ============================================================
class Win98MenuBar extends StatelessWidget {
  final List<Win98MenuItem> items;

  const Win98MenuBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: const BoxDecoration(
        color: Win98Colors.gray,
        border: Border(bottom: BorderSide(color: Win98Colors.darkGray)),
      ),
      child: Row(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildMenuItem(item.label, item.onPressed),
        )).toList(),
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
                fontSize: 12, color: Colors.black, decoration: TextDecoration.none)),
      ),
    );
  }
}

class Win98MenuItem {
  final String label;
  final VoidCallback onPressed;
  const Win98MenuItem(this.label, this.onPressed);
}

// ============================================================
// Win98 LED Display
// ============================================================
class Win98LedDisplay extends StatelessWidget {
  final String text;
  final bool warning;

  const Win98LedDisplay({super.key, required this.text, this.warning = false});

  @override
  Widget build(BuildContext context) {
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
            child: CustomPaint(
              size: const Size(16, 28),
              painter: LedCharPainter(char: c, warning: warning),
            ),
          );
        }).toList(),
      ),
    );
  }
}



// ============================================================
// Win98 Face Button
// ============================================================
class Win98FaceButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool pressed;
  final VoidCallback onTap;

  const Win98FaceButton({
    super.key,
    required this.icon,
    required this.color,
    required this.pressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: pressed ? Win98Colors.darkGray : Win98Colors.white, width: 2),
            left: BorderSide(color: pressed ? Win98Colors.darkGray : Win98Colors.white, width: 2),
            right: BorderSide(color: pressed ? Win98Colors.white : Win98Colors.darkGray, width: 2),
            bottom: BorderSide(color: pressed ? Win98Colors.white : Win98Colors.darkGray, width: 2),
          ),
          color: Win98Colors.gray,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// ============================================================
// Win98 Mute Button
// ============================================================
class Win98MuteButton extends StatelessWidget {
  final bool isMuted;
  final VoidCallback onToggle;

  const Win98MuteButton({super.key, required this.isMuted, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
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
}

// ============================================================
// Win98 Window Frame
// ============================================================
class Win98Window extends StatelessWidget {
  final Widget child;

  const Win98Window({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Win98Colors.white, width: 3),
        color: Win98Colors.gray,
      ),
      child: child,
    );
  }
}

// ============================================================
// Win98 Status Bar
// ============================================================
class Win98StatusBar extends StatelessWidget {
  final Widget left;
  final Widget center;
  final Widget right;

  const Win98StatusBar({
    super.key,
    required this.left,
    required this.center,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Win98Colors.darkGray, width: 2)),
        color: Win98Colors.gray,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [left, Row(mainAxisSize: MainAxisSize.min, children: [center, const SizedBox(width: 4), right])],
      ),
    );
  }
}
