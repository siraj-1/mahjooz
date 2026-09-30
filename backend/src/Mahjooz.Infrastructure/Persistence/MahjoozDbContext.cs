using Mahjooz.Domain.Booking;
using Mahjooz.Domain.Catalog;
using Microsoft.EntityFrameworkCore;

namespace Mahjooz.Infrastructure.Persistence;

public sealed class MahjoozDbContext(DbContextOptions<MahjoozDbContext> options) : DbContext(options)
{
    public DbSet<Venue> Venues => Set<Venue>();

    public DbSet<Branch> Branches => Set<Branch>();

    public DbSet<BookableResource> Resources => Set<BookableResource>();

    public DbSet<OpeningHour> OpeningHours => Set<OpeningHour>();

    public DbSet<Mahjooz.Domain.Booking.Booking> Bookings => Set<Mahjooz.Domain.Booking.Booking>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // The public schema contains a legacy Drizzle catalog with incompatible
        // columns. Never map the new EF model to those existing tables.
        modelBuilder.HasDefaultSchema("mahjooz");

        modelBuilder.Entity<Venue>(entity =>
        {
            entity.ToTable("venues");
            entity.HasKey(venue => venue.Id);
            entity.Property(venue => venue.Name).HasMaxLength(160).IsRequired();
            entity.Property(venue => venue.Slug).HasMaxLength(180).IsRequired();
            entity.Property(venue => venue.Description).HasMaxLength(4000);
            entity.Property(venue => venue.TimeZoneId).HasMaxLength(100).IsRequired();
            entity.HasIndex(venue => venue.Slug).IsUnique();
            entity.HasMany(venue => venue.Branches)
                .WithOne()
                .HasForeignKey(branch => branch.VenueId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Branch>(entity =>
        {
            entity.ToTable("branches");
            entity.HasKey(branch => branch.Id);
            entity.Property(branch => branch.Name).HasMaxLength(160).IsRequired();
            entity.Property(branch => branch.Slug).HasMaxLength(180).IsRequired();
            entity.HasIndex(branch => new { branch.VenueId, branch.Slug }).IsUnique();
            entity.HasMany(branch => branch.Resources)
                .WithOne()
                .HasForeignKey(resource => resource.BranchId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasMany(branch => branch.OpeningHours)
                .WithOne()
                .HasForeignKey(hour => hour.BranchId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<OpeningHour>(entity =>
        {
            entity.ToTable("opening_hours");
            entity.HasKey(hour => hour.Id);
            entity.Property(hour => hour.DayOfWeek).HasConversion<int>();
            entity.HasIndex(hour => new { hour.BranchId, hour.DayOfWeek }).IsUnique();
        });

        modelBuilder.Entity<BookableResource>(entity =>
        {
            entity.ToTable("bookable_resources");
            entity.HasKey(resource => resource.Id);
            entity.Property(resource => resource.Name).HasMaxLength(160).IsRequired();
            entity.Property(resource => resource.Slug).HasMaxLength(180).IsRequired();
            entity.Property(resource => resource.Kind).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(resource => resource.HourlyPrice).HasPrecision(18, 2);
            entity.Property(resource => resource.Currency).HasMaxLength(3).IsRequired();
            entity.HasIndex(resource => new { resource.BranchId, resource.Slug }).IsUnique();
        });

        modelBuilder.Entity<Mahjooz.Domain.Booking.Booking>(entity =>
        {
            entity.ToTable("bookings");
            entity.HasKey(booking => booking.Id);
            entity.Property(booking => booking.Currency).HasMaxLength(3).IsRequired();
            entity.Property(booking => booking.Status).HasConversion<string>().HasMaxLength(32).IsRequired();
            entity.Property(booking => booking.TotalAmount).HasPrecision(18, 2);
            entity.HasOne<BookableResource>()
                .WithMany()
                .HasForeignKey(booking => booking.ResourceId)
                .OnDelete(DeleteBehavior.Restrict);
            entity.HasIndex(booking => new { booking.ResourceId, booking.StartsAt, booking.EndsAt });
        });
    }
}