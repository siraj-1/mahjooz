namespace Mahjooz.Domain.Catalog;

public sealed class Venue
{
    private Venue()
    {
    }

    public Venue(string name, string slug, string timeZoneId, string? description = null)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ArgumentException("A venue name is required.", nameof(name));
        }

        if (string.IsNullOrWhiteSpace(slug))
        {
            throw new ArgumentException("A venue slug is required.", nameof(slug));
        }

        if (string.IsNullOrWhiteSpace(timeZoneId))
        {
            throw new ArgumentException("A venue time zone is required.", nameof(timeZoneId));
        }

        Id = Guid.NewGuid();
        Name = name.Trim();
        Slug = slug.Trim().ToLowerInvariant();
        TimeZoneId = timeZoneId.Trim();
        Description = description?.Trim();
        IsPublished = false;
        CreatedAt = DateTimeOffset.UtcNow;
    }

    public Guid Id { get; private set; }

    public string Name { get; private set; } = string.Empty;

    public string Slug { get; private set; } = string.Empty;

    public string TimeZoneId { get; private set; } = string.Empty;

    public string? Description { get; private set; }

    public bool IsPublished { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public ICollection<Branch> Branches { get; private set; } = new List<Branch>();
}