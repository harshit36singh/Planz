import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:planz/providers/task_notifier.dart';
import 'package:planz/providers/theme_provider.dart';
import 'package:planz/providers/user_provider.dart';
import 'package:planz/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Planz is fully offline: everything lives in local Hive boxes.
  await Hive.initFlutter();
  await Hive.openBox(TaskNotifier.boxName);
  await Hive.openBox(ThemeNotifier.boxName);
  await Hive.openBox(UserNotifier.boxName);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Planz',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      // Returning users skip the intro and onboarding.
      initialRoute: UserNotifier.isOnboardingComplete()
          ? Approuter.home
          : Approuter.landing,
      onGenerateRoute: Approuter.generateRoute,
    );
  }
}
