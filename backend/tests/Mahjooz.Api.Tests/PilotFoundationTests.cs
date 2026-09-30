using Mahjooz.Domain.Booking;
using Mahjooz.Domain.Catalog;
using Mahjooz.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace Mahjooz.Api.Tests;

public sealed class PilotFoundationTests
{
    [Fact]
    public void Booking_is_confirmed_immediately_even_when_payment_is_due()
    {
        var start = new DateTimeOffset(2026, 10, 4, 10, 0, 0, TimeSpan.FromHours(3));
        var booking = new Booking(Guid.NewGuid(), Guid.NewGuid(), start,
            start.AddHours(1), 1, 100m, "syp");

        Assert.Equal(BookingStatus.Confirmed, booking.Status);
        Assert.Equal(100m, booking.TotalAmount);
        Assert.Equal("SYP", booking.Currency);
    }

    [Fact]
    public void Ef_catalog_and_bookings_do_not_target_legacy_public_tables()
    {
        var options = new DbContextOptionsBuilder<MahjoozDbContext>()
            .UseNpgsql("Host=localhost;Database=metadata_only;Username=test;Password=test")
            .Options;
        using var db = new MahjoozDbContext(options);

        foreach (var entity in db.Model.GetEntityTypes())
            Assert.Equal("mahjooz", entity.GetSchema());
    }

    [Fact]
    public void Development_only_myway_example_has_six_specific_spaces_and_weekday_hours()
    {
        // No fixture is inserted into discovery or a customer-facing database.
        var venue = new Venue("Myway", "myway", "Asia/Damascus");
        var branch = new Branch(venue.Id, "Main", "main");
        var hours = new[] { DayOfWeek.Sunday, DayOfWeek.Monday, DayOfWeek.Tuesday,
            DayOfWeek.Wednesday, DayOfWeek.Thursday }
            .Select(day => new OpeningHour(branch.Id, day, new TimeOnly(10, 0), new TimeOnly(18, 0)))
            .ToArray();
        var desks = Enumerable.Range(1, 3)
            .Select(number => new BookableResource(branch.Id, $"Desk {number}", $"desk-{number}",
                ResourceKind.Specific, 100m, "SYP"))
            .ToArray();
        var offices = Enumerable.Range(1, 3)
            .Select(number => new BookableResource(branch.Id, $"Office {number}", $"office-{number}",
                ResourceKind.Specific, 500m, "SYP"))
            .ToArray();

        Assert.False(venue.IsPublished);
        Assert.Equal(5, hours.Length);
        Assert.All(desks.Concat(offices), resource => Assert.Equal(1, resource.Capacity));
        Assert.All(desks, desk => Assert.Equal(100m, desk.HourlyPrice));
        Assert.All(offices, office => Assert.Equal(500m, office.HourlyPrice));
    }
}