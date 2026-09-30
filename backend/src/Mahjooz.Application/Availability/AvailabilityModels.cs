using Mahjooz.Domain.Booking;
using Mahjooz.Domain.Catalog;

namespace Mahjooz.Application.Availability;

public sealed record AvailabilityRequest(
    Guid ResourceId,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    int Quantity = 1);

public sealed record ResourceSnapshot(
    Guid Id,
    ResourceKind Kind,
    int Capacity,
    bool IsActive,
    bool IsBlocked);

public sealed record BookingInterval(
    Guid BookingId,
    DateTimeOffset StartsAt,
    DateTimeOffset EndsAt,
    int Quantity,
    BookingStatus Status);

public sealed record AvailabilityDecision(
    bool IsAvailable,
    int RemainingCapacity,
    string? Reason);

public interface IAvailabilityEngine
{
    AvailabilityDecision Check(
        AvailabilityRequest request,
        ResourceSnapshot resource,
        IReadOnlyCollection<BookingInterval> bookings);
}