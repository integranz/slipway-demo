using Demo.Contracts;
using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Api.Tests;

public class HealthTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    public HealthTests(WebApplicationFactory<Program> factory) => _client = factory.CreateClient();

    [Fact]
    public async Task Health_returns_ok_with_a_version()
    {
        var response = await _client.GetAsync("/health");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<HealthResponse>();
        Assert.NotNull(body);
        Assert.Equal("ok", body!.Status);
        Assert.False(string.IsNullOrWhiteSpace(body.Version));
    }

    [Fact]
    public async Task Health_is_also_served_under_the_api_prefix_for_the_frontend_proxy()
    {
        var direct = await _client.GetFromJsonAsync<HealthResponse>("/health");
        var proxied = await _client.GetFromJsonAsync<HealthResponse>("/api/health");
        Assert.Equal(direct!.Version, proxied!.Version);
    }

    [Fact]
    public async Task Greeting_uses_the_name_parameter()
    {
        var body = await _client.GetFromJsonAsync<GreetingResponse>("/api/greeting?name=Zima");
        Assert.Equal("Hello, Zima!", body!.Message);
    }

    private sealed record GreetingResponse(string Message, string Version);
}
