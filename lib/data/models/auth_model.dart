import '../../domain/entities/user.dart';

class AuthResponseModel {
  final bool ok;
  final String? token;
  final UserModel? user;
  final String? error;
  final String? message;

  const AuthResponseModel({
    required this.ok,
    this.token,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      ok: json['ok'] == true,
      token: json['token']?.toString(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      error: json['error']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class UserModel {
  final int id;
  final String email;
  final String displayName;
  final String planTier;
  final bool isSubscribed;
  final bool emailVerified;
  final List<String> watchlistTickers;
  final bool autoAnalysisEnabled;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.planTier,
    required this.isSubscribed,
    required this.emailVerified,
    required this.watchlistTickers,
    required this.autoAnalysisEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      planTier: json['plan_tier']?.toString() ?? 'free',
      isSubscribed: json['is_subscribed'] == true,
      emailVerified: json['email_verified'] == true,
      watchlistTickers: (json['watchlist_tickers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      autoAnalysisEnabled: json['auto_analysis_enabled'] == true,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id.toString(),
      email: email,
      displayName:
          displayName.isNotEmpty ? displayName : email.split('@').first,
      tier: _mapTier(planTier),
      alertsUsedThisMonth: 0,
    );
  }

  static UserTier _mapTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'pro':
      case 'elite': // legacy — maps to pro
        return UserTier.pro;
      default:
        return UserTier.free;
    }
  }
}
