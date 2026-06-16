import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ProfitAlerts'**
  String get appName;

  /// No description provided for @marketFeed.
  ///
  /// In en, this message translates to:
  /// **'Market Feed'**
  String get marketFeed;

  /// No description provided for @latestSentiment.
  ///
  /// In en, this message translates to:
  /// **'Latest sentiment analysis'**
  String get latestSentiment;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @demoHint.
  ///
  /// In en, this message translates to:
  /// **''**
  String get demoHint;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your stocks'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNoMatch;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get choosePlan;

  /// No description provided for @choosePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start free with 50 AI analyses/month. Upgrade to Pro for unlimited access.'**
  String get choosePlanSubtitle;

  /// No description provided for @startFree.
  ///
  /// In en, this message translates to:
  /// **'Start Free'**
  String get startFree;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @paymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment integration coming soon'**
  String get paymentComingSoon;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @freeFeature1.
  ///
  /// In en, this message translates to:
  /// **'50 AI analyses per month'**
  String get freeFeature1;

  /// No description provided for @freeFeature2.
  ///
  /// In en, this message translates to:
  /// **'Delayed financial news'**
  String get freeFeature2;

  /// No description provided for @freeFeature3.
  ///
  /// In en, this message translates to:
  /// **'Max 5 tickers in watchlist'**
  String get freeFeature3;

  /// No description provided for @freeFeature4.
  ///
  /// In en, this message translates to:
  /// **'Basic sentiment analysis'**
  String get freeFeature4;

  /// No description provided for @freeFeature5.
  ///
  /// In en, this message translates to:
  /// **'No push notifications'**
  String get freeFeature5;

  /// No description provided for @freeFeature6.
  ///
  /// In en, this message translates to:
  /// **'No real-time alerts'**
  String get freeFeature6;

  /// No description provided for @proFeature1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI analyses'**
  String get proFeature1;

  /// No description provided for @proFeature2.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get proFeature2;

  /// No description provided for @proFeature3.
  ///
  /// In en, this message translates to:
  /// **'Unlimited watchlist'**
  String get proFeature3;

  /// No description provided for @proFeature4.
  ///
  /// In en, this message translates to:
  /// **'Real-time ticker alerts'**
  String get proFeature4;

  /// No description provided for @proFeature5.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get proFeature5;

  /// No description provided for @proFeature6.
  ///
  /// In en, this message translates to:
  /// **'Full analysis history'**
  String get proFeature6;

  /// No description provided for @proFeature7.
  ///
  /// In en, this message translates to:
  /// **'Priority beta access'**
  String get proFeature7;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @positive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get positive;

  /// No description provided for @negative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get negative;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @aiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Confidence'**
  String get aiConfidence;

  /// No description provided for @readFullArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Full Article'**
  String get readFullArticle;

  /// No description provided for @affectedTickers.
  ///
  /// In en, this message translates to:
  /// **'Affected Tickers'**
  String get affectedTickers;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @addTicker.
  ///
  /// In en, this message translates to:
  /// **'Add Ticker'**
  String get addTicker;

  /// No description provided for @searchTickers.
  ///
  /// In en, this message translates to:
  /// **'Search tickers to add...'**
  String get searchTickers;

  /// No description provided for @watchlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your watchlist is empty.'**
  String get watchlistEmpty;

  /// No description provided for @watchlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to add your first stock!'**
  String get watchlistEmptySubtitle;

  /// No description provided for @removeTicker.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTicker;

  /// No description provided for @tickerAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to watchlist'**
  String get tickerAdded;

  /// No description provided for @tickerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from watchlist'**
  String get tickerRemoved;

  /// No description provided for @allAlerts.
  ///
  /// In en, this message translates to:
  /// **'All Alerts'**
  String get allAlerts;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterday;

  /// No description provided for @monthlyQuota.
  ///
  /// In en, this message translates to:
  /// **'Monthly Alerts Quota'**
  String get monthlyQuota;

  /// No description provided for @alertsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total} alerts used this month'**
  String alertsUsed(int used, int total);

  /// No description provided for @upgradeToProTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToProTitle;

  /// No description provided for @upgradeToProSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited AI analyses, push notifications, real-time alerts and unlimited watchlist with Profit Alerts Pro — \$29.99/month.'**
  String get upgradeToProSubtitle;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @alertHistory.
  ///
  /// In en, this message translates to:
  /// **'Alert History'**
  String get alertHistory;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time market alerts'**
  String get pushNotificationsSubtitle;

  /// No description provided for @emailSummaries.
  ///
  /// In en, this message translates to:
  /// **'Email Summaries'**
  String get emailSummaries;

  /// No description provided for @emailSummariesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily portfolio updates'**
  String get emailSummariesSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @billingSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Billing & Subscriptions'**
  String get billingSubscriptions;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemMode;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @highNegative.
  ///
  /// In en, this message translates to:
  /// **'High Negative'**
  String get highNegative;

  /// No description provided for @moderateNegative.
  ///
  /// In en, this message translates to:
  /// **'Moderate Negative'**
  String get moderateNegative;

  /// No description provided for @strongBuy.
  ///
  /// In en, this message translates to:
  /// **'Strong Buy'**
  String get strongBuy;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @agoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String agoMinutes(int n);

  /// No description provided for @agoHours.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String agoHours(int n);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @seePlans.
  ///
  /// In en, this message translates to:
  /// **'See Plans'**
  String get seePlans;

  /// No description provided for @watchlistLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Free plan is limited to {limit} tickers. Upgrade to Pro for an unlimited watchlist.'**
  String watchlistLimitReached(int limit);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
