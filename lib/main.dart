import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'features/restricted_calls/presentation/bloc/restricted_calls_bloc.dart';
import 'features/restricted_calls/presentation/bloc/restricted_calls_event.dart';
import 'features/restricted_calls/presentation/pages/restricted_calls_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const VoicemailApp());
}

class VoicemailApp extends StatelessWidget {
  const VoicemailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poplar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) =>
            getIt<RestrictedCallsBloc>()
              ..add(const RestrictedCallsEvent.load()),
        child: const RestrictedCallsPage(),
      ),
    );
  }
}
