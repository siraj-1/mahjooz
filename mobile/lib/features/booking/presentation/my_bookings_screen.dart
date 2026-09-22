import 'package:flutter/material.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: replace with GET /bookings/mine once Identity + Booking exist.
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: const Center(child: Text('No bookings yet.')),
      bottomNavigationBar: const MahjoozBottomNav(currentIndex: 1),
    );
  }
}
