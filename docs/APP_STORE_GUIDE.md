# Profit Alerts — Guía de publicación en App Store

> Última actualización: 2026-06-12 · Bundle ID: `com.profitalerts.profitalerts` · Versión actual: `1.0.0+1` (pubspec.yaml)

---

## 0. Requisitos previos

| Requisito | Estado |
|---|---|
| Cuenta Apple Developer Program ($99/año) | ✅ Ya la tienes |
| Mac con Xcode 16+ (compilar iOS exige macOS) | ⬜ Verificar |
| Bundle ID registrado en developer.apple.com | ⬜ Paso 2 |
| APNs Auth Key subida a Firebase | ⬜ Paso 3 (crítico para push) |
| Cuenta demo funcional para el revisor | ⬜ Paso 7 |

---

## 1. Info.plist — qué tiene y por qué (ya configurado)

El archivo `ios/Runner/Info.plist` ya quedó listo. Qué hay y por qué importa:

| Clave | Valor | Por qué |
|---|---|---|
| `CFBundleDisplayName` | `Profit Alerts` | Nombre bajo el icono (antes decía "Profitalerts" sin espacio) |
| `CFBundleLocalizations` | `en`, `es` | Declara los idiomas; App Store muestra "Idiomas: EN, ES" |
| `CFBundleURLTypes` | `com.googleusercontent.apps.187703…` | **URL scheme de Google Sign-In** (REVERSED_CLIENT_ID de GoogleService-Info.plist). Sin esto el login con Google no puede volver a la app — faltaba y era un bug de release |
| `UIBackgroundModes` | `remote-notification` | FCM puede entregar push con la app en segundo plano |
| `ITSAppUsesNonExemptEncryption` | `false` | Solo usas HTTPS estándar → te salta el cuestionario de export compliance en **cada** subida |
| `UISupportedInterfaceOrientations` | solo Portrait (iPhone) | Coincide con el lock de `main.dart`; declarar landscape sin soportarlo es motivo de nota en review |

### Textos de permisos (NSUsageDescription)

**No necesitas ninguno.** La app no usa cámara, fotos, micrófono, ubicación ni tracking:

- **Push notifications**: el prompt del sistema no requiere texto en Info.plist.
- **Google Sign-In / Firebase Auth**: no requieren usage description.
- **ATT (App Tracking Transparency)**: NO agregues `NSUserTrackingUsageDescription` — no haces tracking publicitario. En App Privacy declararás "Data Not Used for Tracking".

Si algún día agregas widgets de cámara/galería (ej. avatar), ahí sí: `NSCameraUsageDescription` y `NSPhotoLibraryUsageDescription` con texto específico del caso de uso (Apple rechaza textos genéricos).

### ATS (App Transport Security)

**Configuración: ninguna — y eso es lo correcto.** ATS viene activo por defecto y la app solo habla con `https://www.profitalerts.app` (TLS 1.2+). No agregues `NSAllowsArbitraryLoads` jamás: es bandera roja en review y un agujero de seguridad. Si un día necesitas un dominio HTTP legacy, usa una excepción por dominio (`NSExceptionDomains`), nunca la global.

---

## 2. Registro del App ID y capabilities

1. [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles** → Identifiers → `+`.
2. Tipo **App IDs** → App → Bundle ID **explícito**: `com.profitalerts.profitalerts`.
3. Capabilities: marca **Push Notifications**. (Sign in with Apple: ver nota abajo.)
4. En Xcode: `open ios/Runner.xcworkspace` → target Runner → **Signing & Capabilities**:
   - "Automatically manage signing" + tu Team.
   - `+ Capability` → **Push Notifications**.
   - `+ Capability` → **Background Modes** → marca *Remote notifications*.

> ✅ **Sign in with Apple (guideline 4.8) — YA RESUELTO EN CÓDIGO**: la regla solo aplica si la app ofrece login de terceros en iOS. El flag `kShowGoogleSignIn` (`app_constants.dart`) oculta el botón de Google en login y register **solo en iOS**; ahí queda email/password, así que 4.8 no aplica. Android y web conservan Google. Si más adelante quieres Google en iOS, implementa `sign_in_with_apple` junto a él y pon el flag en true.

---

## 3. Push iOS: APNs Auth Key → Firebase (crítico)

Sin este paso, FCM **no entrega ninguna push en iOS** aunque todo compile.

1. developer.apple.com → Certificates, Identifiers & Profiles → **Keys** → `+`.
2. Nombre: `ProfitAlerts APNs`. Marca **Apple Push Notifications service (APNs)** → Continue → Register.
3. **Descarga el archivo `.p8`** (solo se puede descargar UNA vez, guárdalo en un lugar seguro). Anota el **Key ID** y tu **Team ID** (esquina superior derecha del portal).
4. [Firebase Console](https://console.firebase.google.com) → tu proyecto → ⚙️ Project Settings → **Cloud Messaging** → sección *Apple app configuration* → **Upload** APNs Auth Key: archivo `.p8` + Key ID + Team ID.
5. Prueba en un iPhone físico (el simulador no recibe push de APNs reales): login → Firebase Console → Messaging → enviar test al token del dispositivo.

---

## 4. Crear la app en App Store Connect

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → `+` → **New App**.
2. Plataforma **iOS** · Nombre **Profit Alerts** (si está tomado: "Profit Alerts — AI Market News") · Idioma primario **Spanish (Mexico)** o **English (U.S.)** según tu mercado principal · Bundle ID: selecciona el registrado · SKU: `profitalerts-ios-001`.
3. **App Information**:
   - Categoría primaria: **Finance**. Secundaria: **News**.
   - Content rights: no third-party content propio (las noticias se citan con fuente).
   - Age rating: cuestionario → resultado esperado **4+** (no hay simulated gambling; "información financiera" no sube el rating).

---

## 5. Build y subida

```bash
# en el Mac, desde mobile/
flutter clean
flutter pub get
flutter build ipa --release
# resultado: build/ios/ipa/profitalerts.ipa
```

Subida (elige una):
- **Transporter** (Mac App Store, gratis): arrastra el `.ipa` → Deliver.
- Xcode → Window → Organizer → Distribute App → App Store Connect.

El build aparece en App Store Connect → **TestFlight** tras procesar (15–45 min). Gracias a `ITSAppUsesNonExemptEncryption=false` no te preguntará por encriptación.

> Sube cada build nuevo con `flutter build ipa` después de incrementar `version:` en `pubspec.yaml` (ej. `1.0.0+2`); App Store Connect rechaza números de build repetidos.

### TestFlight primero (recomendado)

Antes de review pública: TestFlight → Internal Testing → agrégate a ti y a tu equipo → valida en dispositivo real: login email, login Google (con el fix del URL scheme), push real, deep link de push → detalle de noticia, idioma ES/EN, borrado de cuenta.

---

## 6. Ficha de la App Store

### Textos sugeridos (ES)

- **Nombre** (30 chars): `Profit Alerts`
- **Subtítulo** (30 chars): `Noticias de bolsa con IA`
- **Promotional text** (170 chars): `Cada titular de tu watchlist, analizado por IA en segundos. Recibe alertas cuando una noticia mueve tus tickers.`
- **Keywords** (100 chars): `acciones,bolsa,noticias,alertas,IA,stocks,watchlist,sentimiento,mercado,trading news,finanzas`
- **Descripción** — estructura obligatoria:
  1. Qué es: portal de noticias bursátiles con análisis de sentimiento por IA.
  2. Cómo funciona: agregas tickers → la IA clasifica cada noticia como positiva/negativa con % de confianza → push/email.
  3. Plan gratis: 50 análisis/mes, 5 tickers.
  4. **Disclaimer al final (textual, no lo omitas):** *"Profit Alerts es una plataforma informativa. No es asesoría financiera ni una recomendación de compra o venta de valores. No ejecuta operaciones bursátiles."*

> ✅ **Guideline 3.1.1 (pagos) — YA RESUELTO EN CÓDIGO**: el upgrade a Pro se cobra vía Stripe externo, así que en iOS no puede haber CTAs de compra ni precios. Está implementado con el flag `kShowExternalBilling` ([app_constants.dart](../lib/core/constants/app_constants.dart)), que es `false` en iOS y oculta:
> - Botón "Upgrade a Pro — $29.99/mes" del onboarding (`onboarding_screen.dart`)
> - Tile "Upgrade a Pro" en Settings (`settings_screen.dart`)
> - Botón "Subscribe" en la pantalla de planes (`plans_screen.dart` muestra solo "Start Free" en iOS)
> - Botón "See Plans" del diálogo de límite de watchlist (`watchlist_screen.dart`)
>
> Android y web conservan el flujo completo. La app iOS solo *lee* el tier ("Plan: Pro" en Billing). No agregues links a profitalerts.app/pricing desde iOS.

- **Support URL**: `https://www.profitalerts.app/contact`
- **Privacy Policy URL**: `https://www.profitalerts.app/privacy`

### App Privacy (cuestionario de datos)

Declara exactamente esto (coincide con tu política):

| Dato | Uso | ¿Vinculado al usuario? | ¿Tracking? |
|---|---|---|---|
| Email address | App functionality (cuenta) | Sí | No |
| Name (si Google lo provee) | App functionality | Sí | No |
| Device ID / push token | App functionality (notificaciones) | Sí | No |
| Product interaction (vistas de noticias) | Analytics interno | Sí | No |

### Borrado de cuenta (guideline 5.1.1(v))

> ✅ **YA RESUELTO EN CÓDIGO (2026-06-12)**:
> - **Backend**: `DELETE /api/mobile/user/account` (`app/routes/mobile.py`, auth Bearer) llama a `delete_user_and_related_data`, que borra usuario, perfil, settings, watchlist, alertas, tokens de verificación/reset, análisis por usuario, visitas **y push tokens** (`user_device_tokens`, agregado al helper).
> - **App**: Settings → sección "Zona de peligro" → "Eliminar cuenta" → diálogo de confirmación con texto de irreversibilidad → llama al endpoint → logout → /login.
>
> Antes de enviar: probar el flujo completo con una cuenta de prueba en producción (crear → borrar → verificar que el login ya no funciona).

---

## 7. Checklist de screenshots (con datos demo)

### Tamaños obligatorios

| Dispositivo | Resolución | Simulador sugerido |
|---|---|---|
| 6.9" (obligatorio) | 1320 × 2868 | iPhone 16 Pro Max |
| 6.5" (obligatorio) | 1284 × 2778 / 1242 × 2688 | iPhone 15 Plus / 11 Pro Max |
| iPad 13" (solo si soportas iPad) | 2064 × 2752 | iPad Pro 13" |

> Si no quieres mantener layout de iPad, en Xcode pon **TARGETED_DEVICE_FAMILY = 1** (solo iPhone) y te ahorras los screenshots de iPad.

Captura: simulador → `Cmd+S`, o `xcrun simctl io booted screenshot shot.png`. Modo oscuro (el look insignia de la app), idioma según la ficha (toma un set ES y otro EN para localizar la ficha).

### Datos demo para las capturas

Sembrar la cuenta demo con esto (los datos fake del repo `lib/data/fake/` ya traen material similar):

- **Watchlist**: NVDA, AAPL, TSLA, MSFT, AMD (reconocibles al instante).
- **Feed**: mezcla visible de señales — NVDA POSITIVE 87%, TSLA NEGATIVE 74%, AAPL NEUTRAL — con fuentes reales (Bloomberg, Reuters, CNBC) y timestamps frescos ("3m ago").
- **Sin estados vacíos, sin spinners, sin texto Lorem.**

### Las 6 capturas (orden = narrativa de venta)

1. **Feed** — lista de señales con badges verdes/rojas y barras de confianza. Caption: *"La señal, antes que el ruido"*.
2. **Detalle de noticia** — análisis IA + "por qué importa" + confianza. Caption: *"La IA te explica cada titular"*.
3. **Notificación push** — pantalla de bloqueo del simulador con una push de Profit Alerts visible. Caption: *"Alertas al instante en tus tickers"*.
4. **Watchlist** — tickers seguidos con sparklines. Caption: *"Tu watchlist, vigilada 24/7"*.
5. **Filtros** — sheet de filtros con Bullish seleccionado. Caption: *"Solo las señales que te importan"*.
6. **Alertas/historial** — historial con cuota visible. Caption: *"Todo tu historial de señales"*.

Reglas: status bar con batería llena y hora 9:41 (`xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100`), nada de datos personales reales, los captions se agregan como marcos de texto (Figma o [screenshots.pro](https://screenshots.pro)) — no van "dentro" de la app.

---

## 8. Enviar a review

1. App Store Connect → tu app → versión 1.0 → selecciona el build de TestFlight.
2. **App Review Information**:
   - Cuenta demo: `demo@profitalerts.app` / contraseña funcional (créala en producción y verifica login antes de enviar).
   - Notas para el revisor (pega esto):
     > "Profit Alerts is a stock-news portal with AI sentiment analysis. It is informational only: it does NOT execute trades, provide financial advice, or sell securities. Pro-tier billing is handled entirely on our website; the iOS app does not offer or link to purchases. Push notifications require a physical device. Demo account above has a seeded watchlist."
3. Release: **Manually release this version** (controlas el momento del lanzamiento).
4. Submit. Primera review: 1–3 días hábiles.

### Motivos de rechazo más probables (y su antídoto)

| Guideline | Riesgo | Antídoto |
|---|---|---|
| 3.1.1 In-App Purchase | Botón/link de upgrade visible en iOS | ✅ Implementado: `kShowExternalBilling` oculta todo en iOS |
| 4.8 Sign in with Apple | Google Sign-In sin opción Apple | ✅ Implementado: `kShowGoogleSignIn` oculta Google en iOS |
| 5.1.1(v) Account deletion | Sin borrado in-app | ✅ Implementado: endpoint + "Eliminar cuenta" en Settings |
| 2.1 App completeness | Cuenta demo rota / push no funciona | Probar la demo el mismo día del submit |
| 3.2.1 Financial apps | Ambigüedad sobre si es asesoría/trading | Disclaimer en descripción + notas al revisor |

---

## 9. Después de la aprobación

- Lanzamiento manual → botón **Release this version**.
- Monitorea crashes en Xcode Organizer y App Store Connect → Analytics.
- Updates: sube `version:` en pubspec (`1.0.1+2`), rebuild, re-submit (reviews de updates suelen tardar menos).
- Responde las primeras reseñas (afecta conversión y Apple lo pondera).

---

*Documento generado el 2026-06-12. El Info.plist referido ya está aplicado en `ios/Runner/Info.plist`.*
