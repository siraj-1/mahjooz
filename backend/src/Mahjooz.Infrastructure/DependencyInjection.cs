using Mahjooz.Infrastructure.Booking;
using Mahjooz.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Mahjooz.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddMahjoozInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = PostgresConnection.GetConnectionString(configuration);

        if (!string.IsNullOrWhiteSpace(connectionString))
        {
            services.AddDbContext<MahjoozDbContext>(options =>
                options.UseNpgsql(connectionString));
            services.AddSingleton(Npgsql.NpgsqlDataSource.Create(connectionString));
            services.AddScoped<DemoBookingStore>();
        }

        return services;
    }
}