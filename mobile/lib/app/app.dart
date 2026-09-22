import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class MahjoozApp extends ConsumerWidget {
  const MahjoozApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Mahjooz',
      debugShowCheckedModeBanner: false,
      theme: mahjoozTheme,
      routerConfig: router,
    );
  }
}
