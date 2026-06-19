# 🚀 Buscaminas 98 — Guía de Despliegue

> **Versión:** 1.0.0  
> **Última actualización:** Junio 2026  
> **Plataforma:** Android 5.0+ (API 21+)

---

## 📋 Requisitos

### Desarrollo

| Herramienta | Versión Mínima |
|-------------|---------------|
| Flutter | 3.44.1+ |
| Dart | 3.12.1+ |
| Java | 17+ (JDK) |
| Android SDK | 34+ |
| Python | 3.9+ (para scripts de assets) |

### Dispositivo

- **SO:** Android 5.0+ (API 21)
- **RAM:** 1 GB mínimo
- **Almacenamiento:** 50 MB libres
- **Arquitectura:** arm64-v8a, armeabi-v7a, o x86_64

---

## ⚡ Instalación Rápida

### 1. Clonar

```bash
git clone <repo-url> buscaminas
cd buscaminas
```

### 2. Obtener dependencias

```bash
flutter pub get
```

### 3. Ejecutar en desarrollo

```bash
# Conecta tu dispositivo o inicia un emulador
flutter run

# O para web
flutter run -d chrome
```

### 4. Build release

```bash
flutter build apk --release --split-per-abi
```

Los APKs se generan en:
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk   (~16.5 MB) ← recomendado
├── app-armeabi-v7a-release.apk (~13.7 MB)
└── app-x86_64-release.apk      (~17.9 MB)
```

---

## 📲 Instalación en Móvil (QR)

El proyecto incluye un script para instalar el APK en el móvil vía QR:

```bash
# 1. Compilar el APK (si no lo hiciste)
flutter build apk --release --split-per-abi

# 2. Copiar el APK de tu arquitectura
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk APK/buscaminas-98.apk

# 3. Ejecutar el script
bash install_via_qr.sh
```

Esto inicia un servidor HTTP y genera un código QR. Escanea el QR desde tu móvil para descargar e instalar el APK.

**Requisitos del script:** `python3`, `qrencode` (opcional)

---

## 🔐 Firma para Play Store

### 1. Prerrequisitos

El keystore ya está configurado en:
- `android/key.properties` — credenciales de firma (⚠️ no subir a Git)
- `android/app/buscaminas-keystore.jks` — keystore (⚠️ no subir a Git)
- `android/app/build.gradle.kts` — configurado con `signingConfigs.release`

### 2. Credenciales

El keystore fue generado con:
- **Archivo:** `android/app/buscaminas-keystore.jks`
- **Alias:** `buscaminas`
- **Validez:** 25 años (9125 días)
- **Contraseña:** (guardada en `key.properties` — consultar al desarrollador)

⚠️ **IMPORTANTE:** Guarda la contraseña del keystore de forma segura. Sin ella no podrás firmar actualizaciones de la app en Play Store.

### 3. Build firmado

```bash
flutter build apk --release --split-per-abi
```

El build usa automáticamente la configuración de `key.properties` si existe.

### 4. Verificar firma

```bash
# Verificar que el APK está firmado
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Verificar información del keystore
keytool -list -v -keystore android/app/buscaminas-keystore.jks -storepass <password>
```

---

## 📤 Publicación en Play Store

### 1. Generar App Bundle (recomendado)

```bash
flutter build appbundle --release
```

El AAB se genera en:
```
build/app/outputs/bundle/release/app-release.aab
```

### 2. Subir a Play Console

1. Ve a [Google Play Console](https://play.google.com/console/)
2. Crea una nueva aplicación
3. Ve a **Producción > Explorador de versiones**
4. Sube el AAB o APK
5. Completa la información de la ficha (descripciones, capturas de pantalla, etc.)
6. Revisa y lanza

### 3. Versionado

El versionado se configura en `pubspec.yaml`:

```yaml
version: 1.0.0+1
#         ^    ^
#         |    └── build number (versionCode)
#         └────── version name (versionName)
```

Para actualizar:
```bash
# Ejemplo: subir a v1.1.0 con build 2
# Editar pubspec.yaml: version: 1.1.0+2
flutter build appbundle --release --build-name=1.1.0 --build-number=2
```

---

## 🧪 Tests

```bash
# Ejecutar tests
flutter test

# Con coverage
flutter test --coverage

# Test específico
flutter test test/widget_test.dart
```

---

## 🔧 Mantenimiento

### Regenerar logo

```bash
python3 assets/generate_logo.py
```

### Regenerar iconos Android

```bash
python3 assets/generate_icons.py
```

### Limpiar build

```bash
flutter clean
flutter pub get
```

---

## 🐛 Solución de Problemas

### Build falla por R8

```bash
# Ver reglas faltantes
cat build/app/outputs/mapping/release/missing_rules.txt

# Agregar reglas a android/app/proguard-rules.pro
```

### Puerto 8888 ocupado (QR install)

```bash
kill $(lsof -t -i:8888)
bash install_via_qr.sh
```

### APK muy grande

```bash
# Verificar que usas --split-per-abi
# El fat APK (sin split) pesa ~44MB
flutter build apk --release --split-per-abi
# → arm64-v8a: ~16.5MB ✓
```

### Error de firma

```bash
# Verificar que key.properties existe y es correcto
cat android/key.properties

# Verificar que el keystore existe
ls -la android/app/buscaminas-keystore.jks

# Probar build de nuevo
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

---

## 📦 Estructura de Build

```
buscaminas/
├── android/
│   ├── key.properties              → Credenciales de firma (gitignored)
│   └── app/
│       ├── buscaminas-keystore.jks → Keystore release (gitignored)
│       ├── build.gradle.kts        → Config Gradle con signing + R8
│       ├── proguard-rules.pro      → Reglas ProGuard
│       └── src/main/res/           → Recursos Android (iconos mipmap)
├── assets/
│   ├── logo.png                    → Logo de la aplicación
│   ├── generate_logo.py            → Script regeneración logo
│   └── generate_icons.py           → Script generación iconos
├── APK/
│   └── buscaminas-98.apk           → Último APK compilado (gitignored)
├── build/                          → Output de compilación (gitignored)
├── install_via_qr.sh              → Script instalación vía QR
└── pubspec.yaml                    → Config del proyecto
```
