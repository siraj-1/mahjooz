namespace Mahjooz.Domain.Catalog;

public sealed class OpeningHour
{
    private OpeningHour()
    {
    }

    public OpeningHour(Guid branchId, DayOfWeek dayOfWeek, TimeOnly opensAt, TimeOnly closesAt)
    {
        if (branchId == Guid.Empty)
            throw new ArgumentException("A branch is required.", nameof(branchId));
        if (!Enum.IsDefined(dayOfWeek))
            throw new ArgumentOutOfRangeException(nameof(dayOfWeek));
        if (closesAt <= opensAt)
            throw new ArgumentException("Closing must be after opening.", nameof(closesAt));

        Id = Guid.NewGuid();
        BranchId = branchId;
        DayOfWeek = dayOfWeek;
        OpensAt = opensAt;
        ClosesAt = closesAt;
    }

    public Guid Id { get; private set; }
    public Guid BranchId { get; private set; }
    public DayOfWeek DayOfWeek { get; private set; }
    public TimeOnly OpensAt { get; private set; }
    public TimeOnly ClosesAt { get; private set; }
}