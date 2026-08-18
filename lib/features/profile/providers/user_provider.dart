import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_profile.dart';

/// Mocked profile fetch.
///
/// Kept as a `FutureProvider` (not hard-coded synchronously) to still expose
/// an `AsyncValue` — the profile page can then demonstrate the same
/// loading/error handling pattern as the real async providers.
final userProvider = FutureProvider<UserProfile>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return UserProfile(
    id: 'u001',
    name: 'Wilbrown D@rkness',
    email: 'takoubrown@gmail.com',
    avatarUrl: 'https://picsum.photos/seed/u001/200/200',
    memberSince: DateTime(2025, 10, 15),
  );
});
