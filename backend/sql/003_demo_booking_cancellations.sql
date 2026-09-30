-- Development migration. Preserve demo booking history while allowing a
-- cancelled resource/time slot to be reserved again.
BEGIN;
ALTER TABLE mahjooz.demo_bookings
    ADD COLUMN IF NOT EXISTS cancelled_at timestamptz;
ALTER TABLE mahjooz.demo_bookings
    DROP CONSTRAINT IF EXISTS demo_booking_no_overlap;
ALTER TABLE mahjooz.demo_bookings
    ADD CONSTRAINT demo_booking_no_overlap EXCLUDE USING gist
        (resource_id WITH =, tstzrange(starts_at, ends_at, '[)') WITH &&)
        WHERE (cancelled_at IS NULL);
COMMIT;