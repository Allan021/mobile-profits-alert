// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'ProfitAlerts';

  @override
  String get marketFeed => 'Feed de Mercado';

  @override
  String get latestSentiment => 'Último análisis de sentimiento';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión en tu cuenta';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get signUp => 'Regístrate';

  @override
  String get demoHint => '';

  @override
  String get invalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Empieza a seguir tus acciones';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get passwordsNoMatch => 'Las contraseñas no coinciden';

  @override
  String get choosePlan => 'Elige tu plan';

  @override
  String get choosePlanSubtitle =>
      'Empieza gratis con 50 análisis IA/mes. Mejora a Pro para acceso ilimitado.';

  @override
  String get startFree => 'Empezar gratis';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get paymentComingSoon => 'Integración de pagos próximamente';

  @override
  String get mostPopular => 'Más popular';

  @override
  String get perMonth => '/mes';

  @override
  String get freeFeature1 => '50 análisis IA por mes';

  @override
  String get freeFeature2 => 'Noticias financieras con retraso';

  @override
  String get freeFeature3 => 'Máx. 5 tickers en watchlist';

  @override
  String get freeFeature4 => 'Análisis básico de sentimiento';

  @override
  String get freeFeature5 => 'Sin push notifications';

  @override
  String get freeFeature6 => 'Sin alertas en tiempo real';

  @override
  String get proFeature1 => 'Análisis IA ilimitados';

  @override
  String get proFeature2 => 'Push notifications';

  @override
  String get proFeature3 => 'Watchlist ilimitada';

  @override
  String get proFeature4 => 'Alertas en tiempo real por ticker';

  @override
  String get proFeature5 => 'Filtros avanzados';

  @override
  String get proFeature6 => 'Historial de análisis completo';

  @override
  String get proFeature7 => 'Acceso prioritario a funciones beta';

  @override
  String get feed => 'Feed';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get alerts => 'Alertas';

  @override
  String get settings => 'Ajustes';

  @override
  String get positive => 'Positivo';

  @override
  String get negative => 'Negativo';

  @override
  String get neutral => 'Neutral';

  @override
  String get aiConfidence => 'Confianza IA';

  @override
  String get readFullArticle => 'Leer artículo completo';

  @override
  String get affectedTickers => 'Acciones afectadas';

  @override
  String get analysis => 'Análisis';

  @override
  String get source => 'Fuente';

  @override
  String get addTicker => 'Agregar ticker';

  @override
  String get searchTickers => 'Buscar tickers...';

  @override
  String get watchlistEmpty => 'Tu watchlist está vacía.';

  @override
  String get watchlistEmptySubtitle => '¡Toca para agregar tu primera acción!';

  @override
  String get removeTicker => 'Eliminar';

  @override
  String get tickerAdded => 'Agregado a watchlist';

  @override
  String get tickerRemoved => 'Eliminado de watchlist';

  @override
  String get allAlerts => 'Todas';

  @override
  String get today => 'HOY';

  @override
  String get yesterday => 'AYER';

  @override
  String get monthlyQuota => 'Cuota mensual de alertas';

  @override
  String alertsUsed(int used, int total) {
    return '$used de $total alertas usadas este mes';
  }

  @override
  String get upgradeToProTitle => 'Mejora a Pro';

  @override
  String get upgradeToProSubtitle =>
      'Obtén alertas ilimitadas en tiempo real con ProfitAlerts Pro.';

  @override
  String get learnMore => 'Más información';

  @override
  String get alertHistory => 'Historial de alertas';

  @override
  String get preferences => 'PREFERENCIAS';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get pushNotificationsSubtitle => 'Alertas del mercado en tiempo real';

  @override
  String get emailSummaries => 'Resúmenes por email';

  @override
  String get emailSummariesSubtitle => 'Actualizaciones diarias del portafolio';

  @override
  String get appearance => 'Apariencia';

  @override
  String get account => 'CUENTA';

  @override
  String get security => 'Seguridad';

  @override
  String get billingSubscriptions => 'Facturación y suscripciones';

  @override
  String get helpSupport => 'Ayuda y soporte';

  @override
  String get language => 'IDIOMA';

  @override
  String get about => 'ACERCA DE';

  @override
  String get version => 'Versión';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get edit => 'Editar';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get lightMode => 'Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get earnings => 'Resultados';

  @override
  String get highNegative => 'Muy negativo';

  @override
  String get moderateNegative => 'Negativo moderado';

  @override
  String get strongBuy => 'Compra fuerte';

  @override
  String get event => 'Evento';

  @override
  String agoMinutes(int n) {
    return 'hace ${n}m';
  }

  @override
  String agoHours(int n) {
    return 'hace ${n}h';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get upgradeToPro => 'Mejorar a Pro';

  @override
  String get seePlans => 'Ver Planes';

  @override
  String watchlistLimitReached(int limit) {
    return 'El plan gratuito está limitado a $limit tickers. Mejora a Pro para una lista de seguimiento ilimitada.';
  }
}
