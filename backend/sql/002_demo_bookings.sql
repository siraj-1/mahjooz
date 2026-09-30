-- Isolated preview reservations; does not seed or modify the real catalog.
-- Apply to the development database before enabling the preview API.
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE TABLE IF NOT EXISTS mahjooz.demo_bookings (
    id uuid PRIMARY KEY,
    resource_id text NOT NULL,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT demo_booking_window CHECK (ends_at > starts_at),
    CONSTRAINT demo_booking_no_overlap EXCLUDE USING gist
        (resource_id WITH =, tstzrange(starts_at, ends_at, '[)') WITH &&)
);