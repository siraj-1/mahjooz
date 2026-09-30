using Mahjooz.Application.Availability;
using Microsoft.Extensions.DependencyInjection;

namespace Mahjooz.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddMahjoozApplication(this IServiceCollection services)
    {
        services.AddSingleton<IAvailabilityEngine, AvailabilityEngine>();
        return services;
    }
}