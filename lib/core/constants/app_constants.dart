import 'package:flutter/foundation.dart';

const kAppVersion = '1.0.0';
const kFreeAlertQuota = 50;
const kFreeWatchlistMax = 5;

/// Apple App Store guideline 3.1.1: digital subscriptions sold outside
/// In-App Purchase (our Stripe web checkout) cannot be offered, priced,
/// or linked from the iOS app. On iOS we hide every upgrade CTA and price;
/// the app only *reads* the account tier. Android and web keep the flow.
bool get kShowExternalBilling =>
    kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;

/// Apple App Store guideline 4.8: offering a third-party login (Google)
/// on iOS requires also offering Sign in with Apple. Until that ships,
/// Google sign-in is Android/web only; iOS uses email + password.
bool get kShowGoogleSignIn =>
    kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;
