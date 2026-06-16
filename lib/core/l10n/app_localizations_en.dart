// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ProfitAlerts';

  @override
  String get marketFeed => 'Market Feed';

  @override
  String get latestSentiment => 'Latest sentiment analysis';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get demoHint => '';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Start tracking your stocks';

  @override
  String get fullName => 'Full name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get passwordsNoMatch => 'Passwords do not match';

  @override
  String get choosePlan => 'Choose your plan';

  @override
  String get choosePlanSubtitle =>
      'Start free with 50 AI analyses/month. Upgrade to Pro for unlimited access.';

  @override
  String get startFree => 'Start Free';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get paymentComingSoon => 'Payment integration coming soon';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get perMonth => '/month';

  @override
  String get freeFeature1 => '50 AI analyses per month';

  @override
  String get freeFeature2 => 'Delayed financial news';

  @override
  String get freeFeature3 => 'Max 5 tickers in watchlist';

  @override
  String get freeFeature4 => 'Basic sentiment analysis';

  @override
  String get freeFeature5 => 'No push notifications';

  @override
  String get freeFeature6 => 'No real-time alerts';

  @override
  String get proFeature1 => 'Unlimited AI analyses';

  @override
  String get proFeature2 => 'Push notifications';

  @override
  String get proFeature3 => 'Unlimited watchlist';

  @override
  String get proFeature4 => 'Real-time ticker alerts';

  @override
  String get proFeature5 => 'Advanced filters';

  @override
  String get proFeature6 => 'Full analysis history';

  @override
  String get proFeature7 => 'Priority beta access';

  @override
  String get feed => 'Feed';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get alerts => 'Alerts';

  @override
  String get settings => 'Settings';

  @override
  String get positive => 'Positive';

  @override
  String get negative => 'Negative';

  @override
  String get neutral => 'Neutral';

  @override
  String get aiConfidence => 'AI Confidence';

  @override
  String get readFullArticle => 'Read Full Article';

  @override
  String get affectedTickers => 'Affected Tickers';

  @override
  String get analysis => 'Analysis';

  @override
  String get source => 'Source';

  @override
  String get addTicker => 'Add Ticker';

  @override
  String get searchTickers => 'Search tickers to add...';

  @override
  String get watchlistEmpty => 'Your watchlist is empty.';

  @override
  String get watchlistEmptySubtitle => 'Tap to add your first stock!';

  @override
  String get removeTicker => 'Remove';

  @override
  String get tickerAdded => 'Added to watchlist';

  @override
  String get tickerRemoved => 'Removed from watchlist';

  @override
  String get allAlerts => 'All Alerts';

  @override
  String get today => 'TODAY';

  @override
  String get yesterday => 'YESTERDAY';

  @override
  String get monthlyQuota => 'Monthly Alerts Quota';

  @override
  String alertsUsed(int used, int total) {
    return '$used of $total alerts used this month';
  }

  @override
  String get upgradeToProTitle => 'Upgrade to Pro';

  @override
  String get upgradeToProSubtitle =>
      'Get unlimited AI analyses, push notifications, real-time alerts and unlimited watchlist with Profit Alerts Pro — \$29.99/month.';

  @override
  String get learnMore => 'Learn More';

  @override
  String get alertHistory => 'Alert History';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'Real-time market alerts';

  @override
  String get emailSummaries => 'Email Summaries';

  @override
  String get emailSummariesSubtitle => 'Daily portfolio updates';

  @override
  String get appearance => 'Appearance';

  @override
  String get account => 'ACCOUNT';

  @override
  String get security => 'Security';

  @override
  String get billingSubscriptions => 'Billing & Subscriptions';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get language => 'LANGUAGE';

  @override
  String get about => 'ABOUT';

  @override
  String get version => 'Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logOut => 'Log Out';

  @override
  String get edit => 'Edit';

  @override
  String get darkMode => 'Dark';

  @override
  String get lightMode => 'Light';

  @override
  String get systemMode => 'System';

  @override
  String get earnings => 'Earnings';

  @override
  String get highNegative => 'High Negative';

  @override
  String get moderateNegative => 'Moderate Negative';

  @override
  String get strongBuy => 'Strong Buy';

  @override
  String get event => 'Event';

  @override
  String agoMinutes(int n) {
    return '${n}m ago';
  }

  @override
  String agoHours(int n) {
    return '${n}h ago';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get seePlans => 'See Plans';

  @override
  String watchlistLimitReached(int limit) {
    return 'Free plan is limited to $limit tickers. Upgrade to Pro for an unlimited watchlist.';
  }
}
