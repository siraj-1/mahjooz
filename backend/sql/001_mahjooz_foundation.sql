-- Development schema for the new ASP.NET Core product. Apply once to the
-- development database only; do not run this from application startup or
-- against production. It does not modify the legacy public tables.
BEGIN;
CREATE SCHEMA mahjooz;

CREATE TABLE mahjooz.venues (
    "Id" uuid PRIMARY KEY,
    "Name" varchar(160) NOT NULL,
    "Slug" varchar(180) NOT NULL UNIQUE,
    "TimeZoneId" varchar(100) NOT NULL,
    "Description" varchar(4000),
    "IsPublished" boolean NOT NULL,
    "CreatedAt" timestamptz NOT NULL
);

CREATE TABLE mahjooz.branches (
    "Id" uuid PRIMARY KEY,
    "VenueId" uuid NOT NULL REFERENCES mahjooz.venues("Id") ON DELETE CASCADE,
    "Name" varchar(160) NOT NULL,
    "Slug" varchar(180) NOT NULL,
    "CreatedAt" timestamptz NOT NULL,
    UNIQUE ("VenueId", "Slug")
);

CREATE TABLE mahjooz.opening_hours (
    "Id" uuid PRIMARY KEY,
    "BranchId" uuid NOT NULL REFERENCES mahjooz.branches("Id") ON DELETE CASCADE,
    "DayOfWeek" integer NOT NULL CHECK ("DayOfWeek" BETWEEN 0 AND 6),
    "OpensAt" time NOT NULL,
    "ClosesAt" time NOT NULL,
    CONSTRAINT valid_opening_window CHECK ("ClosesAt" > "OpensAt"),
    UNIQUE ("BranchId", "DayOfWeek")
);

CREATE TABLE mahjooz.bookable_resources (
    "Id" uuid PRIMARY KEY,
    "BranchId" uuid NOT NULL REFERENCES mahjooz.branches("Id") ON DELETE CASCADE,
    "Name" varchar(160) NOT NULL,
    "Slug" varchar(180) NOT NULL,
    "Kind" varchar(32) NOT NULL CHECK ("Kind" IN ('Specific', 'Pooled')),
    "Capacity" integer NOT NULL CHECK ("Capacity" >= 1),
    "HourlyPrice" numeric(18, 2) NOT NULL CHECK ("HourlyPrice" > 0),
    "Currency" varchar(3) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAt" timestamptz NOT NULL,
    UNIQUE ("BranchId", "Slug")
);

CREATE TABLE mahjooz.bookings (
    "Id" uuid PRIMARY KEY,
    "ResourceId" uuid NOT NULL REFERENCES mahjooz.bookable_resources("Id") ON DELETE RESTRICT,
    "CustomerId" uuid NOT NULL,
    "StartsAt" timestamptz NOT NULL,
    "EndsAt" timestamptz NOT NULL,
    "Quantity" integer NOT NULL CHECK ("Quantity" >= 1),
    "TotalAmount" numeric(18, 2) NOT NULL CHECK ("TotalAmount" >= 0),
    "Currency" varchar(3) NOT NULL,
    "Status" varchar(32) NOT NULL CHECK ("Status" IN ('Confirmed', 'CheckedIn', 'Completed', 'Cancelled', 'NoShow')),
    "CreatedAt" timestamptz NOT NULL,
    CONSTRAINT valid_booking_window CHECK ("EndsAt" > "StartsAt")
);
CREATE INDEX bookings_resource_window ON mahjooz.bookings ("ResourceId", "StartsAt", "EndsAt");
COMMIT;