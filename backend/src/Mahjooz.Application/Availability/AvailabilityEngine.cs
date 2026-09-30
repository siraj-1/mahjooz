using Mahjooz.Domain.Booking;
using Mahjooz.Domain.Catalog;

namespace Mahjooz.Application.Availability;

public sealed class AvailabilityEngine : IAvailabilityEngine
{
    private static readonly BookingStatus[] OccupyingStatuses =
    [
        BookingStatus.Confirmed,
        BookingStatus.CheckedIn,
    ];

    public AvailabilityDecision Check(
        AvailabilityRequest request,
        ResourceSnapshot resource,
        IReadOnlyCollection<BookingInterval> bookings)
    {
        if (request.ResourceId == Guid.Empty || request.ResourceId != resource.Id)
        {
            return Unavailable("The requested resource was not found.");
        }

        if (request.EndsAt <= request.StartsAt)
        {
            return Unavailable("The requested time window is invalid.");
        }

        if (request.Quantity < 1)
        {
            return Unavailable("The requested quantity must be at least one.");
        }

        if (!resource.IsActive)
        {
            return Unavailable("The resource is inactive.");
        }

        if (resource.IsBlocked)
        {
            return Unavailable("The resource is blocked for this time window.");
        }

        if (resource.Capacity < 1)
        {
            return Unavailable("The resource has no capacity configured.");
        }

        var overlappingBookings = bookings
            .Where(booking =>
                OccupyingStatuses.Contains(booking.Status) &&
                booking.StartsAt < request.EndsAt &&
                request.StartsAt < booking.EndsAt)
            .ToArray();

        if (resource.Kind == ResourceKind.Specific && overlappingBookings.Length > 0)
        {
            return Unavailable("The specific resource is already reserved.", 0);
        }

        var usedCapacity = overlappingBookings.Sum(booking => booking.Quantity);
        var remainingCapacity = Math.Max(resource.Capacity - usedCapacity, 0);

        return request.Quantity <= remainingCapacity
            ? new AvailabilityDecision(true, remainingCapacity, null)
            : Unavailable("There is not enough remaining capacity.", remainingCapacity);
    }

    private static AvailabilityDecision Unavailable(string reason, int remainingCapacity = 0) =>
        new(false, remainingCapacity, reason);
}