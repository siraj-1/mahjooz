namespace Mahjooz.Domain.Booking;

public sealed class Booking
{
    private Booking()
    {
    }

    public Booking(
        Guid resourceId,
        Guid customerId,
        DateTimeOffset startsAt,
        DateTimeOffset endsAt,
        int quantity,
        decimal totalAmount,
        string currency)
    {
        if (resourceId == Guid.Empty)
        {
            throw new ArgumentException("A resource is required.", nameof(resourceId));
        }

        if (customerId == Guid.Empty)
        {
            throw new ArgumentException("A customer is required.", nameof(customerId));
        }

        if (endsAt <= startsAt)
        {
            throw new ArgumentException("The booking must end after it starts.", nameof(endsAt));
        }

        if (quantity < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(quantity), "Quantity must be at least one.");
        }

        if (totalAmount < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(totalAmount), "The total amount cannot be negative.");
        }

        Id = Guid.NewGuid();
        ResourceId = resourceId;
        CustomerId = customerId;
        StartsAt = startsAt;
        EndsAt = endsAt;
        Quantity = quantity;
        TotalAmount = totalAmount;
        Currency = currency.Trim().ToUpperInvariant();
        Status = BookingStatus.Confirmed;
        CreatedAt = DateTimeOffset.UtcNow;
    }

    public Guid Id { get; private set; }

    public Guid ResourceId { get; private set; }

    public Guid CustomerId { get; private set; }

    public DateTimeOffset StartsAt { get; private set; }

    public DateTimeOffset EndsAt { get; private set; }

    public int Quantity { get; private set; }

    public decimal TotalAmount { get; private set; }

    public string Currency { get; private set; } = string.Empty;

    public BookingStatus Status { get; private set; }

    public DateTimeOffset CreatedAt { get; private set; }

    public bool Overlaps(DateTimeOffset startsAt, DateTimeOffset endsAt) =>
        StartsAt < endsAt && startsAt < EndsAt;
}