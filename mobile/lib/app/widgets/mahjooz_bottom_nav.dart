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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9ECE8))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF187E58),
        unselectedItemColor: const Color(0xFF808981),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == currentIndex) return;
          context.go(_routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'حجوزاتي',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }
}
