# Mahjooz

Marketplace + booking platform for coworking spaces, study spaces, meeting rooms, desks, and private offices — starting in Aleppo.

## What's in this repo

- `mobile/` — Flutter customer app: discover venues, check availability, book, manage bookings. Currently a UI skeleton wired to mock data — see `mobile/README.md` for setup and status.
- `attached_assets/` — the original product idea document this project is built from.

## Planned architecture

- **Backend:** NestJS (TypeScript) + Prisma + PostgreSQL, as a modular monolith (Identity, Catalog, Availability & Booking, Payments, Commission, Reviews, Notifications, Admin). Not started yet — an earlier Express/Drizzle scaffold and a React web mockup were removed to keep this repo aligned with that plan.
- **Mobile:** Flutter — see `mobile/`.

## Status

- [x] Flutter UI skeleton (navigation + screens against mock data, no real backend calls yet)
- [ ] Backend (NestJS + Prisma + PostgreSQL) — not started
- [ ] Availability & Booking Engine — not started
