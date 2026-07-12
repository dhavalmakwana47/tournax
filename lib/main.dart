import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/routes/app_router.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/tournament/presentation/controller/tournament_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = SecureStorageService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  final initialToken = await storage.getToken();

  runApp(
    ProviderScope(
      overrides: [initialTokenProvider.overrideWithValue(initialToken)],
      child: const TournaxApp(),
    ),
  );
}

class TournaxApp extends ConsumerWidget {
  const TournaxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tournamentControllerProvider.notifier).fetchTournamentMeta();
    });

    return MaterialApp.router(
      title: 'Tournax',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
