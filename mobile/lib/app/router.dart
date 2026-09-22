import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/phone_entry_screen.dart';
import '../features/auth/presentation/otp_verify_screen.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/venue/presentation/venue_detail_screen.dart';
import '../features/booking/presentation/booking_flow_screen.dart';
import '../features/booking/presentation/my_bookings_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneEntryScreen(),
      ),
      GoRoute(
        path: '/login/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerifyScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/venue/:venueId',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId']!;
          return VenueDetailScreen(venueId: venueId);
        },
      ),
      GoRoute(
        path: '/venue/:venueId/book/:resourceId',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId']!;
          final resourceId = state.pathParameters['resourceId']!;
          return BookingFlowScreen(venueId: venueId, resourceId: resourceId);
        },
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
