# Mahjooz

Demo marketplace for coworking and study spaces. The Flutter customer app is in `mobile/`; the ASP.NET Core booking API and PostgreSQL schema are in `backend/`.

Venues shown in the app are illustrative, not verified real listings. Reservations are demo-only, stored on the server, and referenced on the device that made them. A future reservation can be cancelled: it stays in history and its slot becomes available again. There are no user accounts or cross-device booking history yet.

## Run the API

Install .NET SDK 10 and PostgreSQL. Create a development database, then apply `backend/sql/001_mahjooz_foundation.sql`, `002_demo_bookings.sql`, and `003_demo_booking_cancellations.sql` **in that order** with `psql -v ON_ERROR_STOP=1 -f <file>`.

Provide a PostgreSQL connection through `DATABASE_URL`, the `PGHOST`/`PGPORT`/`PGDATABASE`/`PGUSER`/`PGPASSWORD` variables, or ASP.NET Core `ConnectionStrings:Mahjooz`. Keep credentials out of Git. Then run:

```sh
dotnet run --project backend/src/Mahjooz.Api
dotnet test backend/Mahjooz.sln
```

The default API URL is printed by `dotnet run`; demo routes begin at `/api/v1/demo`.

## Run Flutter

See [mobile/README.md](mobile/README.md) for setup. Native development builds need an API URL reachable from the device, supplied with `--dart-define=MAHJOOZ_API_URL=http://<reachable-host>:<port>/api/v1/demo`. Use HTTPS for non-local hosts. Flutter web booking requests require the Replit preview’s same-origin `/booking-demo` proxy; a plain Flutter web server alone does not supply this bridge.
