using System.Reflection;
using Demo.Contracts;
using Microsoft.AspNetCore.Http.Json;

var builder = WebApplication.CreateBuilder(args);
builder.Services.Configure<JsonOptions>(o => o.SerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase);
var app = builder.Build();

// Version is stamped at publish time: dotnet publish -p:Version=<semver> -p:InformationalVersion=<semver>
var version = Assembly.GetEntryAssembly()?.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? "0.0.0-local";
var startedAt = DateTimeOffset.UtcNow;

app.MapGet("/", () => Results.Ok(new { service = "adlc-demo-api", version }));
// /health is probed directly on the API container; /api/health is what the frontend reaches through its /api proxy.
var health = () => Results.Ok(new HealthResponse("ok", version, startedAt));
app.MapGet("/health", health);
app.MapGet("/api/health", health);
app.MapGet("/api/greeting", (string? name) => Results.Ok(new { message = $"Hello, {(string.IsNullOrWhiteSpace(name) ? "slipway" : name.Trim())}!", version }));

app.Run();

public partial class Program { }
