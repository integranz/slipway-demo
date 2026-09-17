namespace Demo.Contracts;

/// <summary>Body of the health endpoints (<c>/health</c>, <c>/api/health</c>). Serialised camelCase.</summary>
public sealed record HealthResponse(string Status, string Version, DateTimeOffset StartedAt);
