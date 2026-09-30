using Npgsql;
using Microsoft.Extensions.Configuration;
using Mahjooz.Infrastructure.Persistence;

namespace Mahjooz.Infrastructure.Catalog;

// Read-only bridge for the pre-existing Drizzle catalog. The EF Core model is
// intentionally not used here: its venue/branch columns are not compatible.
public sealed class LegacyVenueCatalog(IConfiguration configuration)
{
    private string ConnectionString => PostgresConnection.GetConnectionString(configuration)
        ?? throw new InvalidOperationException("A PostgreSQL connection is required for discovery.");

    public async Task<IReadOnlyList<VenueSummary>> ListAsync(CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT v.id, v.name, v.city, v.address,
                   (SELECT count(*)::int FROM branches b
                    JOIN resources r ON r.branch_id = b.id
                    WHERE b.venue_id = v.id AND r.is_active) AS resource_count,
                   ARRAY(SELECT DISTINCT lower(feature.value)
                         FROM branches b
                         JOIN resources r ON r.branch_id = b.id
                         CROSS JOIN LATERAL jsonb_array_elements_text(
                             CASE WHEN jsonb_typeof(r.metadata->'amenities') = 'array'
                                  THEN r.metadata->'amenities' ELSE '[]'::jsonb END
                         ) AS feature(value)
                         WHERE b.venue_id = v.id AND r.is_active
                           AND lower(feature.value) IN ('wifi', 'coffee', 'parking', 'tv', 'starlink')
                         ORDER BY lower(feature.value)) AS amenities
            FROM venues v
            ORDER BY v.name, v.id
            LIMIT 100
            """;
        await using var connection = new NpgsqlConnection(ConnectionString);
        await connection.OpenAsync(cancellationToken);
        await using var command = new NpgsqlCommand(sql, connection);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var venues = new List<VenueSummary>();
        while (await reader.ReadAsync(cancellationToken))
            venues.Add(new VenueSummary(reader.GetGuid(0), reader.GetString(1),
                reader.IsDBNull(2) ? null : reader.GetString(2),
                reader.IsDBNull(3) ? null : reader.GetString(3), reader.GetInt32(4),
                reader.GetFieldValue<string[]>(5)));
        return venues;
    }

    public async Task<VenueDetail?> FindAsync(Guid id, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT v.name, v.description, v.address, v.city, v.country,
                   ARRAY(SELECT DISTINCT lower(feature.value)
                         FROM branches ab
                         JOIN resources ar ON ar.branch_id = ab.id
                         CROSS JOIN LATERAL jsonb_array_elements_text(
                             CASE WHEN jsonb_typeof(ar.metadata->'amenities') = 'array'
                                  THEN ar.metadata->'amenities' ELSE '[]'::jsonb END
                         ) AS feature(value)
                         WHERE ab.venue_id = v.id AND ar.is_active
                           AND lower(feature.value) IN ('wifi', 'coffee', 'parking', 'tv', 'starlink')
                         ORDER BY lower(feature.value)) AS amenities,
                   b.id, b.name, b.address, b.city,
                   r.id, r.name, r.type, r.description, r.capacity
            FROM venues v
            LEFT JOIN branches b ON b.venue_id = v.id
            LEFT JOIN resources r ON r.branch_id = b.id AND r.is_active
            WHERE v.id = @id
            ORDER BY b.name, b.id, r.name, r.id
            """;
        await using var connection = new NpgsqlConnection(ConnectionString);
        await connection.OpenAsync(cancellationToken);
        await using var command = new NpgsqlCommand(sql, connection);
        command.Parameters.AddWithValue("id", id);
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        VenueDetail? venue = null;
        var branches = new List<BranchDetail>();
        var resourcesByBranch = new Dictionary<Guid, List<ResourceDetail>>();
        while (await reader.ReadAsync(cancellationToken))
        {
            venue ??= new VenueDetail(id, reader.GetString(0), Text(reader, 1), Text(reader, 2),
                Text(reader, 3), Text(reader, 4), reader.GetFieldValue<string[]>(5), branches);
            if (reader.IsDBNull(6)) continue;
            var branchId = reader.GetGuid(6);
            if (!resourcesByBranch.TryGetValue(branchId, out var resources))
            {
                resources = [];
                resourcesByBranch.Add(branchId, resources);
                branches.Add(new BranchDetail(branchId, reader.GetString(7),
                    Text(reader, 8), Text(reader, 9), resources));
            }
            if (!reader.IsDBNull(10))
                resources.Add(new ResourceDetail(reader.GetGuid(10), reader.GetString(11),
                    reader.GetString(12), Text(reader, 13),
                    reader.IsDBNull(14) ? null : reader.GetInt32(14)));
        }
        return venue;
    }

    private static string? Text(NpgsqlDataReader reader, int index) =>
        reader.IsDBNull(index) ? null : reader.GetString(index);
}

public sealed record VenueSummary(Guid Id, string Name, string? City, string? Address,
    int ResourceCount, IReadOnlyList<string> Amenities);
public sealed record VenueDetail(Guid Id, string Name, string? Description, string? Address,
    string? City, string? Country, IReadOnlyList<string> Amenities, IReadOnlyList<BranchDetail> Branches);
public sealed record BranchDetail(Guid Id, string Name, string? Address, string? City,
    IReadOnlyList<ResourceDetail> Resources);
public sealed record ResourceDetail(Guid Id, string Name, string Type, string? Description, int? Capacity);