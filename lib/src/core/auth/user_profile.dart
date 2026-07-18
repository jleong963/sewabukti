/// The authenticated user's SewaBukti profile, returned by the
/// `create-or-update-user` Edge Function. `id` is the internal SewaBukti UUID
/// (mapped from the Google `sub` server-side), never the Google account id.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.preferredLanguage,
    required this.themeMode,
    this.fullName,
  });

  final String id;
  final String email;
  final String? fullName;
  final String preferredLanguage; // en | ms | zh-Hans
  final String themeMode; // light | dark

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: json['full_name'] as String?,
      preferredLanguage: (json['preferred_language'] ?? 'en').toString(),
      themeMode: (json['theme_mode'] ?? 'light').toString(),
    );
  }
}
