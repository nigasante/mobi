using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using NewsApi.Data;

var builder = WebApplication.CreateBuilder(args);

// Enable controllers (required for APIs)
builder.Services.AddControllers();

// Add Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "News API", Version = "v1" });
});

// Register AppDbContext with SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
);

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod();
    });
});

var app = builder.Build();

// Enable Swagger UI
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "News API v1");
    c.RoutePrefix = string.Empty; // Serve Swagger UI at root
});

// Use CORS
app.UseCors("AllowAll");

// Enable routing and controller endpoints
app.UseAuthorization();
app.MapControllers();

app.Run();
