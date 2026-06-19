# 🏗️ Buscaminas 98 — Arquitectura

> **Versión:** 1.0.0  
> **Última actualización:** Junio 2026  
> **Stack:** Flutter 3.44+ / Dart 3.12+

---

## 📐 Visión General

Buscaminas 98 es un clon del clásico Buscaminas de Windows 98 con estética retro, efectos visuales modernos y sonidos generados proceduralmente. Desarrollado en Flutter para Android (y potencialmente iOS/web).

```
┌──────────────────────────────────────────────────────┐
│                  Buscaminas 98 App                     │
├──────────────────────────────────────────────────────┤
│  UI Layer (Win98 Aesthetic)                           │
│  ┌───────────────────────────────────────────────┐   │
│  │  Title Bar   │  Menu Bar   │  Status Bar      │   │
│  │  (Win98 est.)│  (Juego,    │  (LED display,   │   │
│  │              │   Dificultad,│   face button,   │   │
│  │              │   Ayuda)    │   timer)          │   │
│  └──────────────┴─────────────┴──────────────────┘   │
│  ┌───────────────────────────────────────────────┐   │
│  │           Game Board (GridView)                │   │
│  │     ┌───┬───┬───┬───┬───┬───┬───┬───┬───┐    │   │
│  │     │■  │■  │ 1 │   │   │   │   │   │   │    │   │
│  │     ├───┼───┼───┼───┼───┼───┼───┼───┼───┤    │   │
│  │     │■  │ 2 │ 2 │   │   │   │   │   │   │    │   │
│  │     ├───┼───┼───┼───┼───┼───┼───┼───┼───┤    │   │
│  │     │ 1 │ 2 │■  │ 1 │   │   │   │   │   │    │   │
│  │     └───┴───┴───┴───┴───┴───┴───┴───┴───┘    │   │
│  └───────────────────────────────────────────────┘   │
│  ┌───────────────────────────────────────────────┐   │
│  │           Combo Display (efecto arcade)        │   │
│  └───────────────────────────────────────────────┘   │
├──────────────────────────────────────────────────────┤
│  Game Logic Layer                                    │
│  ┌────────────┐  ┌──────────────┐  ┌────────────┐   │
│  │  Minefield │  │  Cell        │  │  Difficulty│   │
│  │  - Grid    │  │  - state     │  │  - Beginner│   │
│  │  - reveal  │  │  - mine flag │  │  - Interm. │   │
│  │  - flood   │  │  - adjacent  │  │  - Expert  │   │
│  │  - win/lose│  │              │  │  - Custom  │   │
│  └────────────┘  └──────────────┘  └────────────┘   │
├──────────────────────────────────────────────────────┤
│  Audio & Effects Layer                               │
│  ┌──────────────────┐  ┌────────────────────────┐   │
│  │  SoundManager    │  │  Particle System       │   │
│  │  - WAV generator │  │  - Explosion particles │   │
│  │  - Procedural    │  │  - Confetti            │   │
│  │  - 5 sound FX    │  │  - Screen shake        │   │
│  └──────────────────┘  └────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

---

## 🧩 Componentes Principales

### 1. Entry Point (`lib/main.dart`)

| Elemento | Propósito |
|----------|-----------|
| `BuscaminasApp` | Widget raíz MaterialApp con tema teal |
| `GameScreen` | StatefulWidget principal del juego |
| `_GameScreenState` | Lógica de UI, estado del juego, efectos |

**Clases de soporte en main.dart:**

| Clase | Propósito |
|-------|-----------|
| `Win98Colors` | Paleta de colores exacta de Windows 98 |
| `Particle` | Partícula individual para explosiones |
| `ConfettiPiece` | Pieza de confeti para animación de victoria |
| `_CellPainter` | CustomPainter para renderizar celdas del tablero |
| `_LedCharPainter` | CustomPainter para display LED de 7 segmentos |

### 2. Game Logic (`lib/game/`)

#### `cell.dart`
```dart
class Cell {
  int row, col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;
}
```
Modelo de celda individual. Contiene posición, estado y número de minas adyacentes.

#### `minefield.dart`

| Clase/Enum | Propósito |
|------------|-----------|
| `GameState` | Enum: `playing`, `won`, `lost` |
| `Difficulty` | Enum: `beginner`, `intermediate`, `expert`, `custom` |
| `DifficultyConfig` | Configuración de dimensiones y minas para cada dificultad |
| `Minefield` | Lógica principal del campo minado |

**Algoritmos clave en `Minefield`:**

| Método | Descripción |
|--------|-------------|
| `placeMines()` | Coloca minas aleatoriamente evitando el primer click (zona 3×3) |
| `reveal()` | Revela celda, con flood fill si adjacentMines == 0 |
| `_floodFill()` | Algoritmo BFS recursivo que revela celdas vacías |
| `toggleFlag()` | Marca/desmarca bandera |

### 3. Audio (`lib/audio/sound_manager.dart`)

| Componente | Descripción |
|------------|-------------|
| `SoundManager` | Genera y reproduce sonidos WAV proceduralmente |

**Sonidos generados:**

| Sonido | Frecuencia/Duración | Técnica |
|--------|---------------------|---------|
| `click` | 600Hz, 40ms | Seno con decaimiento exponencial |
| `flag` | 800+1200Hz, 60ms | Dual tone con decaimiento |
| `explosion` | 60Hz+noise, 500ms | Ruido blanco + subgraves + crackle |
| `win` | C4-E5-G5-C6, ~700ms | Arpegio de 4 notas ascendentes |
| `reveal` | 300→1100Hz sweep, 60ms | Barrido de frecuencia ascendente |

### 4. Assets (`assets/`)

| Archivo | Propósito |
|---------|-----------|
| `logo.png` | Logo personalizado de la app (1024×1024) |
| `generate_logo.py` | Script Python para regenerar el logo |
| `generate_icons.py` | Script Python para generar iconos Android desde el logo |

---

## 🔄 Flujo de Datos

```
Usuario                          GameScreen                   Minefield
  │                                 │                            │
  │──Tap celda─────────────────────►│                            │
  │                                 │──reveal(row, col)─────────►│
  │                                 │                            │──¿Primer click?
  │                                 │                            │   └── placeMines()
  │                                 │                            │──¿Es mina?
  │                                 │◄──return hitMine───────────│   ├── sí → state=lost
  │                                 │                            │   └── no → floodFill()
  │                                 │                            │          └── checkWin()
  │                                 │                            │
  │                                 │──setState()────────────────│
  │◄──UI actualizada────────────────│                            │
  │                                 │                            │
  │──Tap bandera───────────────────►│                            │
  │                                 │──toggleFlag()─────────────►│
  │                                 │    └── checkWin()          │
  │                                 │                            │
  │──Tap botón cara────────────────►│                            │
  │                                 │──_initGame()──────────────►│
  │◄──Reset completo────────────────│                            │
```

---

## 🧪 Gestión de Estado

El estado del juego se maneja de forma **centralizada** en `_GameScreenState`:

| Variable | Tipo | Propósito |
|----------|------|-----------|
| `_minefield` | `Minefield` | Estado completo del campo minado |
| `_difficulty` | `Difficulty` | Dificultad seleccionada |
| `_customRows/Cols/Mines` | `int` | Config personalizada |
| `_cellSizePref` | `double` | Tamaño de celda preferido |
| `_firstClick` | `bool` | Control para timer y colocación de minas |
| `_pressingFace` | `bool` | Estado visual del botón de cara |
| `_comboCount` | `int` | Contador de combo arcade |
| `_timerWarning` | `bool` | Alarma de tiempo (>30s) |

---

## 🎨 Diseño Visual (Win98)

| Elemento | Descripción |
|----------|-------------|
| **Colores** | Teal `#008080`, Gris `#C0C0C0`, Azul título `#000080` |
| **Bordes** | Efecto 3D raised/sunken con bordes blancos y gris oscuro |
| **Display LED** | 7 segmentos con segmentos rojos brillantes y apagados |
| **Celdas** | CustomPainter con efecto raised (no reveladas) y sunken (reveladas) |
| **Iconos** | Números coloreados (1=azul, 2=verde, 3=rojo, etc.) |

---

## 📦 Dependencias

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `flutter` | SDK | Framework UI |
| `cupertino_icons` | ^1.0.8 | Iconos adicionales |
| `audioplayers` | ^6.0.0 | Reproducción de audio |
| `flutter_lints` | ^6.0.0 | Linting (dev) |
| `flutter_test` | SDK | Testing (dev) |

---

## 🗄️ Estructura de Directorios

```
buscaminas/
├── lib/
│   ├── main.dart              → UI principal, painter, efectos
│   ├── game/
│   │   ├── cell.dart          → Modelo de celda
│   │   └── minefield.dart     → Lógica del juego
│   └── audio/
│       └── sound_manager.dart → Sonidos procedurales
├── assets/
│   ├── logo.png               → Logo de la aplicación
│   ├── generate_logo.py       → Script regeneración logo
│   └── generate_icons.py      → Script generación iconos
├── android/
│   ├── app/
│   │   ├── build.gradle.kts   → Config Gradle (R8, signing)
│   │   ├── proguard-rules.pro → Reglas ProGuard
│   │   ├── buscaminas-keystore.jks → Keystore release
│   │   └── src/main/res/      → Recursos Android
│   └── key.properties         → Credenciales de firma
├── web/                       → Configuración web
├── ios/                       → Configuración iOS
├── test/
│   └── widget_test.dart       → Smoke test
├── APK/                       → APKs compilados
├── pubspec.yaml               → Dependencias y configuración
└── install_via_qr.sh          → Script instalación móvil vía QR
```

---

## 🛡️ Configuración de Build

### Release Build
```bash
flutter build apk --release --split-per-abi
```

| ABI | Tamaño | Dispositivos |
|-----|--------|-------------|
| `arm64-v8a` | ~16.5 MB | Android modernos (64 bits) |
| `armeabi-v7a` | ~13.7 MB | Android antiguos (32 bits) |
| `x86_64` | ~17.9 MB | Emuladores |

### Optimizaciones
- **R8/ProGuard:** Minificación y ofuscación de código Java/Kotlin
- **Shrink resources:** Eliminación de recursos no utilizados
- **Split-per-abi:** APK separado por arquitectura (evita fat APK de ~44MB)

---

## 🔐 Firma (Play Store)

- **Keystore:** `android/app/buscaminas-keystore.jks`
- **Alias:** `buscaminas`
- **Validez:** 25 años (9125 días)
- **Config:** `android/key.properties` + `signingConfigs.release` en build.gradle.kts

---

## 🚀 Próximas Mejoras Potenciales

- Port a iOS (iconos AppIcon.appiconset pendientes)
- Personas personalizables
- Guardar récords (SharedPreferences)
- Soporte Web (Firebase Hosting)
- Temas adicionales (modo oscuro, colores alternativos)
