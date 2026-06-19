# Changelog

> **Proyecto:** Buscaminas 98  
> **Repo:** https://github.com/siliconvalleyar-oss/buscaminas_95_flt.git

---

## [v1.1.0] - Junio 2026

### 🎨 Logo e Iconos
- Agregado logo personalizado (mina + bandera + texto "98") como `assets/logo.png`
- Android: iconos mipmap personalizados en todas las densidades (mdpi a xxxhdpi)
- iOS: 15 iconos AppIcon.appiconset personalizados (20×20 a 1024×1024)
- Web: favicon (32×32) y PWA icons (192, 512, maskable) personalizados
- Scripts Python generadores para logo, Android icons, iOS icons y web icons

### 📝 Documentación
- `ARCHITECTURE.md` — Arquitectura completa del proyecto (componentes, flujo de datos, dependencias)
- `TODO.md` — Plan de trabajo, tareas pendientes, roadmap, issues conocidos, deuda técnica
- `DEPLOY.md` — Guía de despliegue (build, signing QR, Play Store, troubleshooting)
- `SKILL.md` — Conocimiento del proyecto para agentes/desarrolladores

### 🕹️ Mejoras de Juego
- **Fix:** Botón de cara ahora reinicia desde cualquier estado (perdido/ganado)
- **Fix:** Display LED con proporciones correctas de 7 segmentos (segmentos verticales de 8px, grosor 3px)
- **Add:** Guardar mejores tiempos por dificultad con SharedPreferences
- **Add:** Indicador "🏆 ¡Nuevo récord!" al establecer una marca personal
- **Add:** Diálogo de puntuaciones con acceso desde el menú "Puntos"
- **Add:** Botón "Reset" para borrar todas las puntuaciones guardadas
- **Add:** Botón de mute para activar/desactivar sonidos en la barra de estado

### 🔧 Build y Configuración
- **Fix:** `build.gradle.kts` — corregido error de sintaxis (llave faltante + import java.util.Properties)
- **Add:** `proguard-rules.pro` para release builds con R8
- **Add:** Firma Play Store configurada (keystore + key.properties + signingConfigs.release)
- **Add:** `--split-per-abi` para APKs separados por arquitectura (~16.5MB arm64-v8a)
- **Add:** R8/ProGuard con minification y shrink resources

### 🌐 Web
- `index.html` — título y descripción actualizados ("Buscaminas 98")
- `manifest.json` — colores teal (#008080), nombre y descripción correctos

### 🧰 General
- Dependencia `shared_preferences` agregada
- `audioplayers` mantenido en ^6.0.0

---

## [v1.0.0] - Junio 2026

### Juego
- Tablero de juego con lógica completa de Buscaminas
- 4 dificultades: Principiante (9×9), Intermedio (16×16), Experto (30×16), Personalizada
- Dificultad personalizada con sliders (filas, columnas, minas, tamaño de celda)
- Colocación de minas evitando primer click (zona 3×3 segura)
- Flood fill BFS para revelar celdas vacías
- Marcado de banderas (tap secundario / long press)
- Detección de victoria/derrota con revelación total de minas

### UI/Estética
- Estética Windows 98 completa (bordes raised/sunken, colores, tipografía)
- Barra de título con gradiente azul marino y botones (minimizar, maximizar, cerrar)
- Barra de menú (Juego, Dificultad, Ayuda)
- Display LED de 7 segmentos para minas restantes y tiempo
- Botón de cara (smiley) para reiniciar
- Diálogos de dificultad, personalizado y "Acerca de"

### Efectos Visuales
- Partículas de explosión al pisar una mina
- Confetti al ganar la partida
- Animación de vibración (screen shake) al perder
- Display de combo arcade (≥3 revelaciones seguidas)
- Alarma visual en el timer (>30s se vuelve naranja)

### Sonido (Procedural)
- Click (600Hz, 40ms, seno con decaimiento)
- Bandera (800+1200Hz, 60ms, dual tone)
- Explosión (ruido + subgraves + crackle, 500ms)
- Victoria (arpegio ascendente C4-E5-G5-C6, ~700ms)
- Revelación (barrido 300→1100Hz, 60ms)
- Todos generados como WAV en memoria (8-bit, 22050Hz, mono)

### Build
- Flutter 3.44+ / Dart 3.12+
- APK release funcional
- Script `install_via_qr.sh` para instalación móvil vía QR
- Tag v1.0.0 pusheado a GitHub
