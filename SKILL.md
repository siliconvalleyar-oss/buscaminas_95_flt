# 🎯 Buscaminas 98 — SKILL

> **Dominio:** Flutter / Dart / Juego Arcade  
> **Versión:** 1.0.0  
> **Tags:** `flutter`, `game`, `minesweeper`, `win98`, `arcade`, `android`

---

## 📋 Descripción del Proyecto

Clon del clásico Buscaminas de Windows 98 con estética retro, efectos visuales modernos (partículas, confeti, screen shake) y sonidos generados proceduralmente. Desarrollado en Flutter para Android.

**Namespace:** `com.arcade.buscaminas`

---

## 🧠 Stack y Dependencias

| Paquete | Propósito |
|---------|-----------|
| `flutter` 3.44+ / `dart` 3.12+ | Framework base |
| `audioplayers: ^6.0.0` | Reproducción de sonidos WAV |
| `cupertino_icons: ^1.0.8` | Iconos complementarios |
| `flutter_lints: ^6.0.0` | Linting (dev) |

---

## 🏗️ Arquitectura

**Patrón:** StatefulWidget centralizado (`_GameScreenState` mantiene todo el estado)

```
lib/
├── main.dart              → UI + State + Painters + Efectos (~900 líneas)
├── game/
│   ├── cell.dart          → Modelo de celda (~20 líneas)
│   └── minefield.dart     → Lógica del juego (~180 líneas)
└── audio/
    └── sound_manager.dart → Sonidos procedurales (~200 líneas)
```

### Flujo básico:
1. Usuario toca celda → `_onCellTap(row, col)`
2. → `_minefield.reveal(row, col)` (o `toggleFlag`)
3. → `Minefield` coloca minas en primer click, hace flood fill, checkea win/lose
4. → `setState()` actualiza UI
5. → `_CellPainter` renderiza cada celda vía `CustomPaint`

---

## 🎨 Convenciones de Código

### Estilo

- **Lenguaje:** Dart (sin JS/TS)
- **Indentación:** 2 espacios
- **Nombres:** `camelCase` para variables/métodos, `PascalCase` para clases
- **Privacidad:** Prefijo `_` para miembros privados
- **Inmutabilidad:** `final` siempre que sea posible, `const` para widgets estáticos
- **Nulos:** Usar `?` para nullable, evitar `late` cuando sea posible

### Importaciones

```dart
import 'dart:async';       // primero: dart core
import 'dart:math';
import 'package:flutter/...';  // segundo: flutter
import 'game/cell.dart';       // tercero: locales
import 'audio/...';
```

### Colores

Usar `Win98Colors.*` en lugar de valores literales:

```dart
Win98Colors.tealBg       // #008080
Win98Colors.gray         // #C0C0C0
Win98Colors.darkGray     // #808080
Win98Colors.titleBlue    // #000080
Win98Colors.ledOn        // #FF0000 (rojo brillante)
Win98Colors.ledOff       // #600000 (rojo oscuro)
```

### Números de celdas

```dart
Win98Colors.numColors[adjacentMines]
// 1=azul, 2=verde, 3=rojo, 4=azul oscuro, 5=granate...
```

---

## 🎮 Lógica del Juego

### Dificultades predefinidas

| Dificultad | Grid | Minas | Label |
|-----------|------|-------|-------|
| `beginner` | 9×9 | 10 | Principiante |
| `intermediate` | 16×16 | 40 | Intermedio |
| `expert` | 30×16 | 99 | Experto |
| `custom` | Variable | Variable | Personalizado |

### Reglas de negocio

1. **Primer click siempre seguro**: las minas se colocan DESPUÉS del primer tap, evitando zona 3×3
2. **Flood fill**: al revelar una celda con `adjacentMines == 0`, se revelan recursivamente todas las adyacentes
3. **Victoria**: cuando `cellsRevealed == totalCells - mineCount`
4. **Derrota**: todas las minas se revelan, banderas incorrectas se marcan con X roja
5. **Timer**: comienza con el primer click, cuenta segundos, se vuelve naranja a los 30s

---

## 🔊 Sonidos (Procedurales)

Todos los sonidos se generan como WAV en memoria (sin archivos externos).

| Método | Sonido | Técnica |
|--------|--------|---------|
| `_generateClick()` | Click | Seno 600Hz + exponencial |
| `_generateFlag()` | Bandera | Dual tone 800+1200Hz |
| `_generateExplosion()` | Explosión | Ruido blanco + 60Hz + crackle |
| `_generateWin()` | Victoria | Arpegio ascendente 4 notas |
| `_generateReveal()` | Revelar | Barrido 300→1100Hz |

Formato WAV: 8-bit, 22050Hz, mono.

---

## 🛠️ Comandos Útiles

```bash
# Build release (recomendado)
flutter build apk --release --split-per-abi

# Build AAB (Play Store)
flutter build appbundle --release

# Tests
flutter test
flutter test --coverage

# Regenerar logo e iconos
python3 assets/generate_logo.py
python3 assets/generate_icons.py

# Instalar en móvil vía QR
bash install_via_qr.sh
```

---

## 🚨 Áreas de Mejora (Deuda Técnica)

- **Refactor**: `main.dart` (~900 líneas) debería dividirse en:
  - `lib/ui/` — widgets reutilizables con estética Win98
  - `lib/effects/` — sistema de partículas y confeti
  - `lib/dialogs/` — diálogos de dificultad
- **Audio Pool**: actualmente crea un `AudioPlayer` por sonido, debería reutilizar
- **Tests**: solo hay smoke test, faltan tests unitarios para `Minefield`
- **Internacionalización**: mezcla de español en UI con código en inglés

---

## 🔐 Seguridad

- `android/key.properties` contiene contraseñas en texto plano — **nunca subir a Git**
- `android/app/buscaminas-keystore.jks` — **nunca subir a Git**
- Ambos están en `.gitignore`

---

## 🌐 Recursos

- [Flutter Documentation](https://docs.flutter.dev/)
- [Original Windows 98 Minesweeper](https://en.wikipedia.org/wiki/Microsoft_Minesweeper)
- [audioplayers package](https://pub.dev/packages/audioplayers)
