namespace Mahjooz.Domain.Catalog;

public sealed class Branch
{
    private Branch()
    {
    }

    public Branch(Guid venueId, string name, string slug)
    {
        if (venueId == Guid.Empty)
        {
            throw new ArgumentException("A venue is required.", nameof(venueId));
        }

        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ArgumentException("A branch name is required.", nameof(name));
        }

        if (string.IsNullOrWhiteSpace(slug))
        {
            throw new ArgumentException("A branch slug is required.", nameof(slug));
        }

        Id = Guid.NewGuid();
        VenueId = venueId;
        Name = name.Trim();
        Slug = slug.Trim().ToLowerInvariant();
        CreatedAt = DateTimeOffset.UtcNow;
    }

    public Guid Id { get; private set; }

    public Guid VenueId { get; private set; }

    public string Name { get; private set; } = string.Empty;

    public string Slug { get; private set; } = string.Empty;

    public DateTimeOffset CreatedAt { get; private set; }

    public ICollection<BookableResource> Resources { get; private set; } = new List<BookableResource>();

    public ICollection<OpeningHour> OpeningHours { get; private set; } = new List<OpeningHour>();
}