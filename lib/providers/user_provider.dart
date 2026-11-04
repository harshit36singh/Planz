import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// The user's display name, captured during onboarding and stored only on
/// this device in the Hive "user_data" box (opened in `main()`).
class UserNotifier extends StateNotifier<String> {
  static const String boxName = 'user_data';
  static const String nameKey = 'user_name';
  static const String onboardingKey = 'onboarding_complete';
  static const String defaultName = 'User';

  final Box? _box;

  UserNotifier([this._box])
    : super((_box?.get(nameKey) as String?) ?? defaultName);

  /// Saves [name] and marks onboarding as done.
  Future<void> completeOnboarding(String name) async {
    final trimmed = name.trim();
    state = trimmed.isEmpty ? defaultName : trimmed;
    await _box?.put(nameKey, state);
    await _box?.put(onboardingKey, true);
  }

  Future<void> rename(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = trimmed;
    await _box?.put(nameKey, state);
  }

  /// Forgets the user so the app starts from onboarding again.
  Future<void> reset() async {
    state = defaultName;
    await _box?.clear();
  }

  static bool isOnboardingComplete() {
    if (!Hive.isBoxOpen(boxName)) return false;
    return Hive.box(boxName).get(onboardingKey, defaultValue: false) as bool;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, String>((ref) {
  final box = Hive.isBoxOpen(UserNotifier.boxName)
      ? Hive.box(UserNotifier.boxName)
      : null;
  return UserNotifier(box);
});
