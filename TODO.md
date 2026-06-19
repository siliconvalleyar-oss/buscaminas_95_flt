# 📋 Buscaminas 98 — Plan de Trabajo y Roadmap

> **Última actualización:** Junio 2026  
> **Versión actual:** v1.0.0  
> **Próximo hito:** v1.1.0

---

## ✅ Completado (v1.0.0)

### Juego
- [x] Tablero de juego con lógica completa de Buscaminas
- [x] 4 dificultades: Principiante (9×9), Intermedio (16×16), Experto (30×16), Personalizada
- [x] Dificultad personalizada con sliders (filas, columnas, minas, tamaño de celda)
- [x] Colocación de minas evitando primer click (zona 3×3 segura)
- [x] Flood fill BFS para revelar celdas vacías
- [x] Marcado de banderas (tap secundario / long press)
- [x] Detección de victoria/derrota
- [x] Revelar todas las minas al perder
- [x] Marcado de banderas incorrectas al perder (X roja)

### UI / Estética
- [x] Estética Windows 98 completa (bordes raised/sunken, colores, tipografía)
- [x] Barra de título con gradiente azul marino
- [x] Barra de menú (Juego, Dificultad, Ayuda)
- [x] Display LED de 7 segmentos para minas restantes y tiempo
- [x] Botón de cara que reinicia el juego desde cualquier estado
- [x] Diálogo de dificultad con radio buttons
- [x] Diálogo personalizado con sliders
- [x] Diálogo "Acerca de"

### Efectos Visuales
- [x] Partículas de explosión al pisar una mina
- [x] Confetti al ganar la partida
- [x] Animación de vibración (screen shake) al perder
- [x] Display de combo arcade (se activa con ≥3 revelaciones seguidas)
- [x] Alarma visual en el timer (>30s se vuelve naranja)

### Sonido
- [x] Click (600Hz, 40ms, seno con decaimiento)
- [x] Bandera (800+1200Hz, 60ms)
- [x] Explosión (ruido + subgraves + crackle, 500ms)
- [x] Victoria (arpegio C4-E5-G5-C6)
- [x] Revelación (barrido 300→1100Hz)
- [x] Todos los sonidos generados proceduralmente como WAV

### Build & Distribución
- [x] Compilación APK release (arm64-v8a: ~16.5MB)
- [x] Optimización con --split-per-abi (separado por arquitectura)
- [x] R8/ProGuard para minificación
- [x] Script install_via_qr.sh para instalación móvil
- [x] Firma Play Store configurada (keystore, key.properties)

### Iconos & Assets
- [x] Logo personalizado (mina + bandera + texto "98")
- [x] Iconos Android mipmap reemplazados (mdpi a xxxhdpi)
- [x] Scripts Python para regeneración de logo e iconos

### Git
- [x] Commit y tag v1.0.0
- [x] Push a GitHub

---

## 📝 Tareas Pendientes (Corto Plazo)

### Prioridad Alta

- [x] **Iconos iOS**: Reemplazar AppIcon.appiconset con el logo generado
- [x] **Favicon web**: Actualizar favicon.png con el nuevo logo
- [x] **Guardar scores**: Persistencia de mejores tiempos con SharedPreferences
- [ ] **Personas personalizables**: Opción para cambiar la cara del botón

### Prioridad Media

- [x] **Sonidos toggle**: Botón para activar/desactivar sonidos
- [ ] **Animación de revelación**: Efecto de "descubrimiento" al revelar celdas
- [ ] **Zoom / pan**: En tableros grandes, permitir scroll o zoom
- [ ] **Modo oscuro**: Tema alternativo oscuro
- [ ] **Internacionalización**: Soporte multi-idioma (ES/EN/PT)

### Prioridad Baja

- [ ] **Hint button**: Ayuda que revela una celda segura
- [ ] **Undo**: Deshacer último movimiento
- [ ] **Leaderboard local**: Mejores tiempos por dificultad
- [ ] **Estadísticas**: Partidas jugadas, ganadas, ratio, rachas
- [ ] **Exportar logros**: Compartir resultados

---

## 🐛 Issues Conocidos

### UI
- [ ] El display LED no tiene la separación exacta de píxeles del original (se puede mejorar)
- [ ] Los botones de la barra de título (minimizar, maximizar, cerrar) no tienen funcionalidad real
- [ ] El diálogo Acerca de muestra texto truncado en pantallas pequeñas

### Rendimiento
- [ ] En tableros grandes (ej: 50×50), el renderizado de todas las celdas puede ser lento
- [ ] Los sonidos generan un nuevo AudioPlayer por cada reproducción (sin pool)
- [ ] Las partículas no se limitan en cantidad máxima

### Plataforma
- [ ] iOS: pendiente configuración de iconos y signing
- [ ] Web: no probado, puede tener issues con audioplayers

---

## 🗺️ Roadmap

### v1.1.0 — Mejoras de UX
- [ ] Guardar mejores tiempos (SharedPreferences)
- [ ] Botón de mute para sonidos
- [ ] Animaciones de revelación suaves
- [ ] Zoom en tableros grandes

### v1.2.0 — Multiplataforma
- [ ] Soporte iOS completo (iconos, signing, test)
- [ ] Soporte Web
- [ ] Soporte Linux Desktop

### v2.0.0 — Social & Modos
- [ ] Estadísticas detalladas
- [ ] Modo contrarreloj
- [ ] Tableros generados por semilla (compartir partidas)
- [ ] Logros y badges

---

## 🔧 Deuda Técnica

- [ ] Refactorizar `main.dart` (~900 líneas) en módulos separados
  - `ui/` — widgets Win98 (title bar, menu bar, led display, face button)
  - `effects/` — particle system, confetti, screen shake
  - `dialogs/` — difficulty dialog, custom dialog, about dialog
- [ ] Crear pool de AudioPlayers para evitar crear/destruir constantemente
- [ ] Migrar constantes de colores a un tema escalable
- [ ] Agregar type hints completos
- [ ] Estandarizar nombres (mezcla ES/EN)
- [ ] Tests unitarios para `Minefield` (no solo smoke test)
