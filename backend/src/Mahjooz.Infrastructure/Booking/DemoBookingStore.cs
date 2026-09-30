using Npgsql;

namespace Mahjooz.Infrastructure.Booking;

/// <summary>Preview-only inventory, separate from the unconfirmed venue catalog.</summary>
public sealed class DemoBookingStore(NpgsqlDataSource dataSource)
{
    private static readonly HashSet<string> Resources =
    [
        "rukn-desk-1", "rukn-desk-2", "rukn-desk-3", "rukn-desk-4", "rukn-office-1",
        "hudoo-desk-1", "hudoo-office-1", "hudoo-office-2"
    ];

    private static readonly TimeZoneInfo VenueZone = TimeZoneInfo.FindSystemTimeZoneById("Asia/Damascus");

    public static bool TryWindow(string resourceId, DateOnly date, TimeOnly time,
        out DateTimeOffset start, out DateTimeOffset end, out string? error)
    {
        start = default;
        end = default;
        error = null;
        var today = DateOnly.FromDateTime(TimeZoneInfo.ConvertTime(DateTimeOffset.UtcNow, VenueZone).DateTime);
        if (!Resources.Contains(resourceId))
            error = "This resource is not part of the demo booking inventory.";
        else if (date < today || date > today.AddDays(60))
            error = "Choose a date within the next 60 days.";
        else if (time.Minute != 0 || time.Hour < 10 || time.Hour >= 18)
            error = "Choose a one-hour slot starting between 10:00 and 17:00.";
        else
        {
            var local = date.ToDateTime(time, DateTimeKind.Unspecified);
            if (VenueZone.IsInvalidTime(local) || VenueZone.IsAmbiguousTime(local))
                error = "This local time cannot be booked.";
            else
            {
                start = new DateTimeOffset(local, VenueZone.GetUtcOffset(local)).ToUniversalTime();
                end = start.AddHours(1);
                if (start <= DateTimeOffset.UtcNow)
                    error = "Choose a future slot.";
            }
        }
        return error is null;
    }

    public async Task<bool> IsAvailableAsync(string resourceId, DateTimeOffset start,
        DateTimeOffset end, CancellationToken cancellationToken)
    {
        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var command = new NpgsqlCommand(
            "SELECT NOT EXISTS (SELECT 1 FROM mahjooz.demo_bookings WHERE resource_id = @resource AND starts_at < @end AND ends_at > @start AND cancelled_at IS NULL)",
            connection);
        command.Parameters.AddWithValue("resource", resourceId);
        command.Parameters.AddWithValue("start", start);
        command.Parameters.AddWithValue("end", end);
        return (bool)(await command.ExecuteScalarAsync(cancellationToken))!;
    }

    public async Task<Guid?> ReserveAsync(string resourceId, DateTimeOffset start,
        DateTimeOffset end, CancellationToken cancellationToken)
    {
        var id = Guid.NewGuid();
        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var command = new NpgsqlCommand(
            "INSERT INTO mahjooz.demo_bookings (id, resource_id, starts_at, ends_at) VALUES (@id, @resource, @start, @end)",
            connection);
        command.Parameters.AddWithValue("id", id);
        command.Parameters.AddWithValue("resource", resourceId);
        command.Parameters.AddWithValue("start", start);
        command.Parameters.AddWithValue("end", end);
        try
        {
            await command.ExecuteNonQueryAsync(cancellationToken);
            return id;
        }
        catch (PostgresException exception) when (exception.SqlState == PostgresErrorCodes.ExclusionViolation)
        {
            return null;
        }
    }

    public async Task<DemoBookingRecord?> FindAsync(Guid id, CancellationToken cancellationToken)
    {
        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using var command = new NpgsqlCommand(
            "SELECT resource_id, starts_at, ends_at, cancelled_at FROM mahjooz.demo_bookings WHERE id = @id",
            connection);
        command.Parameters.AddWithValue("id", id);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
            return null;
        return new DemoBookingRecord(id, reader.GetString(0),
            reader.GetFieldValue<DateTime>(1), reader.GetFieldValue<DateTime>(2),
            reader.IsDBNull(3) ? null : reader.GetFieldValue<DateTime>(3));
    }

    public async Task<DemoCancelResult> CancelAsync(Guid id, CancellationToken cancellationToken)
    {
        await using var connection = await dataSource.OpenConnectionAsync(cancellationToken);
        await using (var command = new NpgsqlCommand(
            "UPDATE mahjooz.demo_bookings SET cancelled_at = now() WHERE id = @id AND cancelled_at IS NULL AND starts_at > now() RETURNING id",
            connection))
        {
            command.Parameters.AddWithValue("id", id);
            if (await command.ExecuteScalarAsync(cancellationToken) is not null)
                return DemoCancelResult.Cancelled;
        }

        var booking = await FindAsync(id, cancellationToken);
        if (booking is null) return DemoCancelResult.NotFound;
        return booking.CancelledAt is not null
            ? DemoCancelResult.AlreadyCancelled
            : DemoCancelResult.TooLate;
    }
}

public sealed record DemoBookingRecord(Guid Id, string ResourceId,
    DateTimeOffset StartsAt, DateTimeOffset EndsAt, DateTimeOffset? CancelledAt);

public enum DemoCancelResult { Cancelled, NotFound, AlreadyCancelled, TooLate }