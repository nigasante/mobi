using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NewsApi.Data;
using NewsApi.Models;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ArticleVersionsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ArticleVersionsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ArticleVersion>> GetArticleVersion(int id)
        {
            var version = await _context.ArticleVersions
                .Include(v => v.Editor)
                .FirstOrDefaultAsync(v => v.VersionID == id);

            if (version == null)
                return NotFound();

            return Ok(version);
        }

        [HttpPost]
        public async Task<ActionResult<ArticleVersion>> CreateArticleVersion([FromBody] ArticleVersionDto dto)
        {
            var version = new ArticleVersion
            {
                ArticleID = dto.ArticleID,
                Title = dto.Title,
                Content = dto.Content,
                EditorID = dto.EditorID,
                ImageUrl = dto.ImageUrl, // Include ImageUrl
                CreatedAt = DateTime.UtcNow,
                IsPublished = false
            };

            _context.ArticleVersions.Add(version);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetArticleVersion), 
                new { id = version.VersionID }, version);
        }

        public class ArticleVersionDto
        {
            public int ArticleID { get; set; }
            public string Title { get; set; } = string.Empty;
            public string Content { get; set; } = string.Empty;
            public int EditorID { get; set; }
            public string? ImageUrl { get; set; }
        }
    }
}