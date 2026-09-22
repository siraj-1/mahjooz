import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple, explicit bottom nav. Each tab-root screen builds its own
/// Scaffold and includes this widget with its own index — a
/// StatefulShellRoute (go_router) is a reasonable upgrade later once
/// the basics feel comfortable, but adds branch-navigation concepts
/// that aren't worth the complexity for this skeleton stage.
class MahjoozBottomNav extends StatelessWidget {
  const MahjoozBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _routes = ['/home', '/bookings', '/profile'];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        context.go(_routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
