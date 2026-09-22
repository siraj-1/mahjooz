import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';
import '../../../core/storage/secure_storage_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await ref.read(secureStorageProvider).clear();
            if (context.mounted) context.go('/login');
          },
          child: const Text('Log out'),
        ),
      ),
      bottomNavigationBar: const MahjoozBottomNav(currentIndex: 2),
    );
  }
}
