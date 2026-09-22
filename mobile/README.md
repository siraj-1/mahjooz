# Mahjooz — Customer App (Flutter)

Customer-facing mobile app: discover coworking/study spaces, see live availability, book a seat/desk/room, manage bookings.

This is a **UI skeleton** — navigation, screens, and models are wired up against mock data. No network calls hit a real backend yet; that comes once the Availability & Booking Engine (NestJS + Prisma + PostgreSQL, per the plan) exists.

## One-time setup (do this first)

This skeleton was hand-written (`lib/`, `pubspec.yaml`, ...) without running the Flutter CLI, so the native platform folders (`android/`, `ios/`, `web/`, ...) don't exist yet. Generate them locally:

```bash
cd mobile
flutter create . --org com.mahjooz --project-name mahjooz
flutter pub get
flutter run
```

`flutter create .` fills in the platform folders around the existing `lib/` and `pubspec.yaml` without overwriting them. Commit the generated `android/`, `ios/`, etc. folders normally afterward — they aren't gitignored.

## Structure

- `lib/app/` — app shell: theme, go_router config, root widget, shared bottom-nav widget
- `lib/core/` — cross-cutting: Dio client (placeholder base URL + auth header interceptor), secure token storage
- `lib/features/<feature>/presentation/` — one folder per screen area: splash, auth, discover, venue, booking, profile
- `lib/shared/models/` — Venue/Branch/Resource, mirroring the field names already used in `lib/db/src/schema/` in this repo, so wiring the real API later is a rename, not a redesign
- `lib/shared/mock/` — placeholder data (a "WorkHub" venue with the branches/resources from the original idea doc) so screens render something real before the backend exists

## Screens included (skeleton only — no real logic yet)

Splash → Phone entry → OTP verify → Discover (venue list, tab) → Venue detail → Booking flow (placeholder date/time picker, reserve button disabled) → My Bookings (tab), Profile (tab, has logout).

Bottom nav is a plain three-tab `BottomNavigationBar` repeated per tab-root screen, not a `StatefulShellRoute` — simpler to read while go_router basics are still new. Worth upgrading later once that's comfortable.

## Next steps

1. Run the setup above, confirm `flutter run` shows Discover with the WorkHub mock venue.
2. Once Identity/Catalog are real on the backend, replace `core/network/dio_client.dart`'s placeholder `kApiBaseUrl` and wire real login + venue fetching.
3. Leave the booking flow screen disabled until the Availability & Booking Engine (the concurrency-safe core) actually exists — don't fake "available" slots even for a demo.
