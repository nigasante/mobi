using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NewsApi.Data;
using NewsApi.Models;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ActivityLogsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ActivityLogsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ActivityLog>>> GetActivityLogs(
            [FromQuery] int? userId = null,
            [FromQuery] string? action = null,
            [FromQuery] string? tableName = null,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            var query = _context.ActivityLogs
                .Include(l => l.User)
                .AsQueryable();

            if (userId.HasValue)
                query = query.Where(l => l.UserID == userId);
            
            if (!string.IsNullOrEmpty(action))
                query = query.Where(l => l.Action == action);
            
            if (!string.IsNullOrEmpty(tableName))
                query = query.Where(l => l.TableName == tableName);
            
            if (fromDate.HasValue)
                query = query.Where(l => l.Timestamp >= fromDate);
            
            if (toDate.HasValue)
                query = query.Where(l => l.Timestamp <= toDate);

            var totalCount = await query.CountAsync();
            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            var logs = await query
                .OrderByDescending(l => l.Timestamp)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(new {
                logs,
                currentPage = page,
                totalPages,
                totalCount,
                pageSize
            });
        }

        [HttpPost]
        public async Task<ActionResult<ActivityLog>> CreateActivityLog([FromBody] ActivityLogDto dto)
        {
            var log = new ActivityLog
            {
                UserID = dto.UserID,
                Action = dto.Action,
                TableName = dto.TableName,
                Timestamp = DateTime.UtcNow
            };

            _context.ActivityLogs.Add(log);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetActivityLog), 
                new { id = log.LogID }, log);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ActivityLog>> GetActivityLog(int id)
        {
            var log = await _context.ActivityLogs
                .Include(l => l.User)
                .FirstOrDefaultAsync(l => l.LogID == id);

            if (log == null)
                return NotFound();

            return Ok(log);
        }

        public class ActivityLogDto
        {
            public int UserID { get; set; }
            public string Action { get; set; } = string.Empty;
            public string TableName { get; set; } = string.Empty;
        }
    }
}