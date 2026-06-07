# F1 Stats App 🏎️

App de estadísticas de Fórmula 1 para Android construida con Flutter.
Datos en tiempo real de la [Ergast F1 API](https://ergast.com/mrd/) (gratuita, sin API key).

---

## Pantallas

| Pantalla | Descripción |
|---|---|
| **Inicio** | Próxima carrera, últimos resultados y top clasificación |
| **Clasificación** | Pilotos y Constructores — con selector de temporada (1950–2024) |
| **Calendario** | Todas las carreras de la temporada seleccionada |
| **Comparador** | Compara trayectorias de pilotos y equipos, temporada a temporada |
| **Historia** | Campeones del mundo desde 2005 |
| **Detalle carrera** | Podio visual + clasificación completa con tiempos |

---

## Novedades v2

- ✅ **Selector de temporada** en Clasificación y Calendario — cubre 1950 a 2024
- ✅ **Comparador de pilotos** — elige dos pilotos, ve campeonatos, victorias, puntos y tabla año a año
- ✅ **Comparador de equipos** — mismo sistema para constructores
- ✅ **Buscador de pilotos** en el comparador con campo de texto
- ✅ Barra de navegación ampliada a 5 pestañas

---

## Instalación paso a paso

### 1. Instalar Flutter
1. Ve a [flutter.dev/get-started](https://flutter.dev/get-started)
2. Descarga Flutter para tu sistema operativo
3. Añade `flutter/bin` al PATH
4. Abre terminal y ejecuta:
   ```
   flutter doctor
   ```

### 2. Instalar Android Studio
1. Descarga desde [developer.android.com/studio](https://developer.android.com/studio)
2. SDK Manager → instala **Android SDK 33+**
3. Acepta licencias:
   ```
   flutter doctor --android-licenses
   ```

### 3. Crear emulador
- Android Studio → Device Manager → Create Virtual Device
- Elige **Pixel 7**, sistema **API 33** → Start

### 4. Ejecutar la app
```bash
# Dentro de la carpeta f1stats_app:
flutter pub get
flutter run
```

### 5. Generar APK para tu móvil
```bash
flutter build apk --release
# El APK queda en: build/app/outputs/flutter-apk/app-release.apk
```

---

## Estructura del proyecto

```
lib/
├── main.dart
├── models/
│   └── models.dart              ← Driver, Constructor, Race, Stats para comparador
├── services/
│   ├── api_service.dart         ← Ergast API (temporadas, carrera, trayectorias)
│   └── f1_provider.dart         ← Estado global + selector de temporada
├── screens/
│   ├── main_screen.dart         ← Navegación (5 pestañas)
│   ├── home_screen.dart         ← Inicio
│   ├── standings_screen.dart    ← Clasificación con selector de año
│   ├── schedule_screen.dart     ← Calendario con selector de año
│   ├── compare_screen.dart      ← Comparador pilotos / equipos ← NUEVO
│   ├── race_detail_screen.dart  ← Detalle de carrera con podio
│   └── history_screen.dart      ← Campeones históricos
└── widgets/
    ├── driver_standing_tile.dart
    ├── section_title.dart
    └── shimmer_box.dart
```

---

## API utilizada

**Ergast Motor Racing Developer API** — `https://ergast.com/api/f1`

Totalmente gratuita, sin registro ni API key. Datos desde 1950.

Endpoints principales:
- `/{season}/driverStandings.json` — Clasificación por temporada
- `/{season}/constructorStandings.json` — Constructores por temporada
- `/{season}.json` — Calendario de la temporada
- `/drivers/{driverId}/driverStandings.json` — Toda la carrera de un piloto
- `/constructors/{id}/constructorStandings.json` — Toda la historia de un equipo

---

## Dependencias

| Paquete | Uso |
|---|---|
| `provider` | Estado global |
| `http` | Llamadas API |
| `google_fonts` | Fuente Inter |
| `shimmer` | Placeholder de carga |
| `intl` | Formateo de fechas |
| `fl_chart` | Gráficos (disponible para futuras versiones) |
