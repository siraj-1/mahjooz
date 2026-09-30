# Mahjooz Flutter customer app

The app shows illustrative demo venues and lets you check one-hour desk/office slots, reserve a demo slot, view bookings stored for this device, and cancel a future booking. It uses the ASP.NET Core API in `../backend` (setup in the [project README](../README.md)). There are no real venue listings, payments, or accounts.

## Local setup

Install Flutter (Dart SDK >= 3.3). If platform folders such as `android/` or `ios/` are missing, run `flutter create . --org com.mahjooz --project-name mahjooz` inside `mobile/` first; this adds platform runners without replacing `lib/`. Then:

```sh
cd mobile
flutter pub get
flutter test
flutter run --dart-define=MAHJOOZ_API_URL=http://<device-reachable-host>:<api-port>/api/v1/demo
```

For an Android emulator, the host machine is typically `10.0.2.2`, not `localhost`. On a physical device, use an address reachable over its network. Use HTTPS outside local development. Booking operations do not work with an empty `MAHJOOZ_API_URL`.

Flutter web uses `/booking-demo` for booking requests and therefore needs the same-origin proxy supplied by the Replit preview; `flutter run -d chrome` alone will not proxy the API. Demo booking references are saved on the current device only.
