# Buscaminas 98 - Arcade Edition

Buscaminas estilo Windows 98 hecho en Flutter con modo arcade, sonidos dinámicos y efectos visuales.

## Estructura del proyecto

```
buscaminas/
├── lib/
│   ├── main.dart              # Punto de entrada + UI completa (Win98, tablero, celdas, LED)
│   ├── game/
│   │   ├── cell.dart          # Modelo de celda individual
│   │   └── minefield.dart     # Lógica del juego (minas, revelado, banderas, flood-fill)
│   └── audio/
│       └── sound_manager.dart  # Generación WAV programática + reproducción
├── test/
│   └── widget_test.dart
└── pubspec.yaml
```

## Cómo ejecutar

```bash
cd ~/src/buscaminas
flutter run
```

Para build web:
```bash
flutter build web
```

Para build linux:
```bash
flutter build linux
```

## Controles

| Acción | Desktop | Móvil |
|--------|---------|-------|
| Revelar celda | Click izquierdo | Tap |
| Marcar bandera | Click derecho | Long press |
| Reiniciar | Click en cara 😊 | Tap en cara |
| Cambiar dificultad | Menú > Dificultad | Menú > Dificultad |

## Dificultades

| Nivel | Grid | Minas |
|-------|------|-------|
| Principiante | 9×9 | 10 |
| Intermedio | 16×16 | 40 |
| Experto | 30×16 | 99 |
| Personalizado | 5-50 × 5-50 | 1 a total-1 |

El tablero se ajusta automáticamente para ocupar casi toda la pantalla.

## Características arcade

- **Sonidos dinámicos**: WAV generado programáticamente (click, flag, explosión, win, reveal)
- **Screen shake**: La pantalla tiembla al explotar una mina
- **Partículas**: Explosiones con partículas de fuego
- **Confeti**: Lluvia de colores al ganar
- **Sistema de combos**: +x combo al revelar múltiples celdas (≥3)
- **Timer LED rojo**: Parpadea cuando quedan ≤30 segundos
- **Display LED**: Contador de minas y timer estilo 7-segmentos con glow

## Arquitectura

### `lib/game/minefield.dart`
- `Cell`: estado individual (mina, revelado, bandera, minas adyacentes)
- `Minefield`: grid, lógica de revelado con flood-fill, colocación de minas (evita primera celda), detección de win/lose
- `Difficulty`: enum con beginner/intermediate/expert/custom
- `DifficultyConfig`: configuración de rows/cols/mines con constantes predefinidas y validación

### `lib/audio/sound_manager.dart`
Genera archivos WAV en memoria usando:
- `_generateClick()`: sine 600Hz, 40ms, decay exponencial
- `_generateFlag()`: sine 800Hz+armónico, 60ms
- `_generateExplosion()`: noise + rumble 60Hz + crackle, 500ms
- `_generateWin()`: arpegio ascendente C5-E5-G5-C6, 600ms
- `_generateReveal()`: frequency sweep 300→1100Hz, 60ms

Reproduce con `audioplayers` via `BytesSource`.

### `lib/main.dart`
UI completa en un solo archivo:
- `Win98Colors`: paleta clásica (teal #008080, gray #C0C0C0, LED rojo)
- `_CellPainter`: custom painter para celdas (3D raised/sunken, números, minas, banderas)
- `_LedCharPainter`: display 7-segmentos con efecto glow
- `Particle`/`ConfettiPiece`: sistemas de partículas para explosiones y celebración
- `GameScreen`: estado del juego, animaciones, lógica de input

## Personalización

- Dificultad personalizada desde el menú (Dificultad > Personalizado)
- Ajusta filas (5-50), columnas (5-50) y minas en vivo
- El tablero se redimensiona automáticamente para llenar la pantalla
- Para cambiar sonidos: modificar métodos `_generate*` en `lib/audio/sound_manager.dart`
- Para ajustar sensibilidad de combos: cambiar umbral en `_onCellTap` (>1 revelado = combo)
