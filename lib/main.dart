import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/routes/app_router.dart';
import 'core/services/remote_error_logger_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/tournament/presentation/controller/tournament_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter UI & Render Error Catching -> Sends to Laravel Backend API
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}\n${details.stack}');
    RemoteErrorLoggerService.instance.sendErrorLog(
      exception: details.exception,
      stackTrace: details.stack,
    );
  };

  // Global Uncaught Async Dart Error Catching -> Sends to Laravel Backend API
  PlatformDispatcher.instance.onError = (Object exception, StackTrace stackTrace) {
    debugPrint('PLATFORM ASYNC ERROR: $exception\n$stackTrace');
    RemoteErrorLoggerService.instance.sendErrorLog(
      exception: exception,
      stackTrace: stackTrace,
    );
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF1E1E2E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
                const SizedBox(height: 8),
                const Text(
                  'Render Error',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  '${details.exception}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

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
