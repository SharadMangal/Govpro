import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

import 'app/theme.dart';
import 'app/router.dart';
import 'providers/providers.dart';

void main() {
  // Ensure widget binding is initialized before SharedPreferences or Cache
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => const ProviderScope(
        child: GovProApp(),
      ),
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
      
      // Device preview settings
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
      
      // Theme settings
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Routing settings
      routerConfig: goRouter,
    );
  }
}
