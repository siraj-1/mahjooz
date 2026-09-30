namespace Mahjooz.Domain.Catalog;

public sealed class BookableResource
{
    private BookableResource()
    {
    }

    public BookableResource(
        Guid branchId,
        string name,
        string slug,
        ResourceKind kind,
        decimal hourlyPrice,
        string currency,
        int capacity = 1)
    {
        if (branchId == Guid.Empty)
        {
            throw new ArgumentException("A branch is required.", nameof(branchId));
        }

        if (string.IsNullOrWhiteSpace(name))
        {
            throw new ArgumentException("A resource name is required.", nameof(name));
        }

        if (string.IsNullOrWhiteSpace(slug))
        {
            throw new ArgumentException("A resource slug is required.", nameof(slug));
        }

        if (capacity < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(capacity), "Capacity must be at least one.");
        }

        if (hourlyPrice <= 0)
            throw new ArgumentOutOfRangeException(nameof(hourlyPrice), "The hourly price must be positive.");
        if (string.IsNullOrWhiteSpace(currency) || currency.Trim().Length != 3)
            throw new ArgumentException("A three-letter currency code is required.", nameof(currency));

        Id = Guid.NewGuid();
        BranchId = branchId;
        Name = name.Trim();
        Slug = slug.Trim().ToLowerInvariant();
        Kind = kind;
        Capacity = kind == ResourceKind.Specific ? 1 : capacity;
        HourlyPrice = hourlyPrice;
        Currency = currency.Trim().ToUpperInvariant();
        IsActive = true;
        CreatedAt = DateTimeOffset.UtcNow;
    }

    public Guid Id { get; private set; }

    public Guid BranchId { get; private set; }

    public string Name { get; private set; } = string.Empty;

    public string Slug { get; private set; } = string.Empty;

    public ResourceKind Kind { get; private set; }

    public int Capacity { get; private set; }

    public decimal HourlyPrice { get; private set; }

    public string Currency { get; private set; } = string.Empty;

    public bool IsActive { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }
}