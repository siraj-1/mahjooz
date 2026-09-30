using Mahjooz.Application.Availability;
using Mahjooz.Domain.Booking;
using Mahjooz.Domain.Catalog;

namespace Mahjooz.Api.Tests;

public sealed class AvailabilityEngineTests
{
    private readonly AvailabilityEngine _engine = new();

    [Fact]
    public void Pooled_resource_keeps_remaining_capacity()
    {
        var resourceId = Guid.NewGuid();
        var start = new DateTimeOffset(2026, 9, 21, 10, 0, 0, TimeSpan.Zero);
        var result = _engine.Check(
            new AvailabilityRequest(resourceId, start, start.AddHours(2), 2),
            new ResourceSnapshot(resourceId, ResourceKind.Pooled, 5, true, false),
            [
                new BookingInterval(
                    Guid.NewGuid(),
                    start.AddMinutes(30),
                    start.AddHours(1),
                    2,
                    BookingStatus.Confirmed),
            ]);

        Assert.True(result.IsAvailable);
        Assert.Equal(3, result.RemainingCapacity);
    }

    [Fact]
    public void Specific_resource_is_unavailable_when_an_active_booking_overlaps()
    {
        var resourceId = Guid.NewGuid();
        var start = new DateTimeOffset(2026, 9, 21, 14, 0, 0, TimeSpan.Zero);
        var result = _engine.Check(
            new AvailabilityRequest(resourceId, start, start.AddHours(1)),
            new ResourceSnapshot(resourceId, ResourceKind.Specific, 1, true, false),
            [
                new BookingInterval(
                    Guid.NewGuid(),
                    start.AddMinutes(15),
                    start.AddHours(2),
                    1,
                    BookingStatus.Confirmed),
            ]);

        Assert.False(result.IsAvailable);
        Assert.Equal("The specific resource is already reserved.", result.Reason);
    }
}