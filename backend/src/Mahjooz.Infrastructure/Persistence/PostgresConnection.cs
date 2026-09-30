using Microsoft.Extensions.Configuration;
using Npgsql;

namespace Mahjooz.Infrastructure.Persistence;

internal static class PostgresConnection
{
    public static string? GetConnectionString(IConfiguration configuration)
    {
        var configured = configuration.GetConnectionString("Mahjooz");
        if (!string.IsNullOrWhiteSpace(configured))
            return configured;

        var host = configuration["PGHOST"];
        if (!string.IsNullOrWhiteSpace(host))
            return new NpgsqlConnectionStringBuilder
            {
                Host = host,
                Port = int.TryParse(configuration["PGPORT"], out var port) ? port : 5432,
                Database = configuration["PGDATABASE"] ?? throw new InvalidOperationException("PGDATABASE is required."),
                Username = configuration["PGUSER"] ?? throw new InvalidOperationException("PGUSER is required."),
                Password = configuration["PGPASSWORD"] ?? throw new InvalidOperationException("PGPASSWORD is required."),
            }.ConnectionString;

        return configuration["DATABASE_URL"];
    }
}