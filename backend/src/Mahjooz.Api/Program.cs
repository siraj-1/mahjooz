using Mahjooz.Application;
using Mahjooz.Application.Availability;
using Mahjooz.Domain.Booking;
using Mahjooz.Domain.Catalog;
using Mahjooz.Infrastructure;
using Mahjooz.Infrastructure.Catalog;
using Mahjooz.Infrastructure.Booking;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddProblemDetails();
builder.Services.AddMahjoozApplication();
builder.Services.AddMahjoozInfrastructure(builder.Configuration);
builder.Services.AddScoped<LegacyVenueCatalog>();

var app = builder.Build();

app.UseExceptionHandler();

app.MapGet("/healthz", () => Results.Ok(new
{
    status = "ok",
    service = "mahjooz-backend",
    timestamp = DateTimeOffset.UtcNow,
}));

app.MapGet("/api/v1/modules", () => Results.Ok(new
{
    modules = new[]
    {
        "identity",
        "catalog",
        "availability",
        "booking",
        "payments",
        "commission",
        "reviews",
        "notifications",
        "admin",
    },
}));

app.MapGet("/api/v1/discovery/venues", async (LegacyVenueCatalog catalog, CancellationToken cancellationToken) => Results.Ok(new
{
    items = await catalog.ListAsync(cancellationToken),
    nextCursor = (string?)null,
}));

app.MapGet("/api/v1/discovery/venues/{id:guid}", async (Guid id, LegacyVenueCatalog catalog, CancellationToken cancellationToken) =>
{
    var venue = await catalog.FindAsync(id, cancellationToken);
    return venue is null ? Results.NotFound() : Results.Ok(venue);
});

// The sample inventory is deliberately not a live venue listing. Availability
// is read from server-owned reservations, never from a caller-supplied list.
app.MapGet("/api/v1/demo/availability", async (
    string resourceId, DateOnly date, TimeOnly time, DemoBookingStore store,
    CancellationToken cancellationToken) =>
{
    if (!DemoBookingStore.TryWindow(resourceId, date, time, out var start, out var end, out var error))
        return Results.BadRequest(new { error });
    var available = await store.IsAvailableAsync(resourceId, start, end, cancellationToken);
    return Results.Ok(new { isAvailable = available, startsAt = start, endsAt = end,
        reason = available ? (string?)null : "This desk or office is already reserved.", isDemo = true });
});

app.MapPost("/api/v1/demo/bookings", async (
    DemoReserveRequest request, DemoBookingStore store, CancellationToken cancellationToken) =>
{
    if (!DemoBookingStore.TryWindow(request.ResourceId, request.Date, request.Time,
        out var start, out var end, out var error))
        return Results.BadRequest(new { error });
    var id = await store.ReserveAsync(request.ResourceId, start, end, cancellationToken);
    return id is null
        ? Results.Conflict(new { error = "This desk or office was just reserved. Choose another slot." })
        : Results.Created($"/api/v1/demo/bookings/{id}", new
        {
            id, request.ResourceId, startsAt = start, endsAt = end, status = "Confirmed", isDemo = true
        });
});

// The preview has no user accounts yet. An unguessable booking ID is kept on
// the user's device and looked up individually; never expose a global list.
app.MapGet("/api/v1/demo/bookings/{id:guid}", async (
    Guid id, DemoBookingStore store, CancellationToken cancellationToken) =>
{
    var booking = await store.FindAsync(id, cancellationToken);
    if (booking is null) return Results.NotFound();
    var local = TimeZoneInfo.ConvertTime(booking.StartsAt,
        TimeZoneInfo.FindSystemTimeZoneById("Asia/Damascus"));
    return Results.Ok(new
    {
        booking.Id, booking.ResourceId, booking.StartsAt, booking.EndsAt,
        date = local.ToString("yyyy-MM-dd"),
        time = local.ToString("HH:mm"),
        status = booking.CancelledAt is null ? "Confirmed" : "Cancelled",
        isDemo = true
    });
});

app.MapDelete("/api/v1/demo/bookings/{id:guid}", async (
    Guid id, DemoBookingStore store, CancellationToken cancellationToken) =>
    await store.CancelAsync(id, cancellationToken) switch
    {
        DemoCancelResult.Cancelled => Results.Ok(new { id, status = "Cancelled", isDemo = true }),
        DemoCancelResult.NotFound => Results.NotFound(),
        DemoCancelResult.AlreadyCancelled => Results.Conflict(new { error = "This booking is already cancelled." }),
        _ => Results.Conflict(new { error = "A booking cannot be cancelled after its start time." })
    });

app.MapPost("/api/v1/availability/check", (
    AvailabilityCheckRequest request,
    IAvailabilityEngine availabilityEngine) =>
{
    if (!Enum.TryParse<ResourceKind>(request.ResourceKind, true, out var resourceKind))
    {
        return Results.BadRequest(new { error = "resourceKind must be Pooled or Specific." });
    }

    var bookings = new List<BookingInterval>();
    foreach (var booking in request.ExistingBookings ?? [])
    {
        if (!Enum.TryParse<BookingStatus>(booking.Status, true, out var status))
        {
            return Results.BadRequest(new { error = $"Unknown booking status: {booking.Status}." });
        }

        bookings.Add(new BookingInterval(
            booking.Id,
            booking.StartsAt,
            booking.EndsAt,
            booking.Quantity,
            status));
    }

    var decision = availabilityEngine.Check(
        new AvailabilityRequest(
            request.ResourceId,
            request.StartsAt,
            request.EndsAt,
            request.Quantity),
        new ResourceSnapshot(
            request.ResourceId,
            resourceKind,
            request.Capacity,
            request.IsActive,
            request.IsBlocked),
        bookings);

    return Results.Ok(decision);
});

app.Run();

public sealed record AvailabilityCheckRequest(
    Guid ResourceId,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    string ResourceKind,
    int Capacity = 1,
    int Quantity = 1,
    bool IsActive = true,
    bool IsBlocked = false,
    IReadOnlyCollection<ExistingBookingRequest>? ExistingBookings = null);

public sealed record ExistingBookingRequest(
    Guid Id,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    int Quantity,
    string Status);

public sealed record DemoReserveRequest(string ResourceId, DateOnly Date, TimeOnly Time);