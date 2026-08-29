import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/platform/contacts_platform.dart';
import 'core/presentation/splash_page.dart';
import 'core/theme/app_theme.dart';
import 'features/restricted_calls/presentation/bloc/restricted_calls_bloc.dart';
import 'features/restricted_calls/presentation/bloc/restricted_calls_event.dart';
import 'features/restricted_calls/presentation/pages/restricted_calls_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoicemailApp());
}

class VoicemailApp extends StatefulWidget {
  const VoicemailApp({super.key});

  @override
  State<VoicemailApp> createState() => _VoicemailAppState();
}

class _VoicemailAppState extends State<VoicemailApp> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize({bool reset = false}) async {
    if (reset) {
      await getIt.reset();
    }
    await configureDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poplar',
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashPage();
          }

          if (snapshot.hasError) {
            return _InitializationError(
              onRetry: () => setState(() {
                _initialization = _initialize(reset: true);
              }),
            );
          }

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider<ContactsPlatform>(
                create: (_) => getIt<ContactsPlatform>(),
              ),
            ],
            child: BlocProvider(
              create: (_) =>
                  getIt<RestrictedCallsBloc>()
                    ..add(const RestrictedCallsEvent.load()),
              child: const RestrictedCallsPage(),
            ),
          );
        },
      ),
    );
  }
}

class _InitializationError extends StatelessWidget {
  const _InitializationError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('Poplar could not start.'),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    ),
  );
}
