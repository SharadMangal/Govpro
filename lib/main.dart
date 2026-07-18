import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme.dart';
import 'app/router.dart';
import 'providers/providers.dart';

void main() {
  // Ensure widget binding is initialized before SharedPreferences or Cache
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: GovProApp(),
    ),
  );
}

class GovProApp extends ConsumerWidget {
  const GovProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'GovPro Monitoring Console',
      debugShowCheckedModeBanner: false,
      
      // Theme settings
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Routing settings
      routerConfig: goRouter,
    );
  }
}
