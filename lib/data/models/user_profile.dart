import 'package:equatable/equatable.dart';

/// Mocked user profile.
///
/// Named `UserProfile` (not `User`) to avoid collisions with common package
/// classes (Firebase, google_sign_in, etc.) if the project grows.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.memberSince,
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime memberSince;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, memberSince];
}
