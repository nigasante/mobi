using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NewsApi.Data;
using NewsApi.Models;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ArticlesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ArticlesController(AppDbContext context)
        {
            _context = context;
        }

        // Updated to include imageUrl in response
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Article>>> GetArticles([FromQuery] int? categoryId)
        {
            var query = _context.Articles
                .Where(a => !a.IsDeleted)
                .Select(a => new
                {
                    a.ArticleID,
                    a.Title,
                    a.Content,
                    a.EditorID,
                    a.Status,
                    a.PublishDate,
                    a.CreatedAt,
                    a.UpdatedAt,
                    a.IsDeleted,
                    a.ImageUrl // Include ImageUrl in response
                });

            if (categoryId.HasValue)
            {
                query = query.Where(a =>
                    _context.ArticleCategories
                        .Any(ac => ac.ArticleID == a.ArticleID && ac.CategoryID == categoryId.Value)
                );
            }

            var articles = await query.ToListAsync();
            return Ok(articles);
        }

        // Updated POST endpoint to handle imageUrl
        [HttpPost]
        public async Task<ActionResult> AddArticle([FromBody] ArticleDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Title) ||
                string.IsNullOrWhiteSpace(dto.Content) ||
                string.IsNullOrWhiteSpace(dto.Status))
            {
                return BadRequest("Title, Content, and Status are required.");
            }

            var article = new Article
            {
                Title = dto.Title,
                Content = dto.Content,
                EditorID = dto.EditorID,
                Status = dto.Status,
                PublishDate = dto.PublishDate,
                ImageUrl = dto.ImageUrl, // Add ImageUrl
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            _context.Articles.Add(article);
            await _context.SaveChangesAsync();

            if (dto.CategoryIDs != null && dto.CategoryIDs.Any())
            {
                foreach (var categoryId in dto.CategoryIDs)
                {
                    _context.ArticleCategories.Add(new ArticleCategory
                    {
                        ArticleID = article.ArticleID,
                        CategoryID = categoryId
                    });
                }
                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                message = "Article created successfully",
                article.ArticleID,
                article.Title,
                article.ImageUrl // Include ImageUrl in response
            });
        }

        // Updated PUT endpoint to handle imageUrl
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateArticle(int id, [FromBody] ArticleDto dto)
        {
            var article = await _context.Articles
                .FirstOrDefaultAsync(a => a.ArticleID == id && !a.IsDeleted);

            if (article == null)
                return NotFound("Article not found");

            article.Title = dto.Title;
            article.Content = dto.Content;
            article.EditorID = dto.EditorID;
            article.Status = dto.Status;
            article.PublishDate = dto.PublishDate;
            article.ImageUrl = dto.ImageUrl; // Update ImageUrl
            article.UpdatedAt = DateTime.UtcNow;

            _context.Entry(article).State = EntityState.Modified;

            // Update categories
            var existingLinks = await _context.ArticleCategories
                .Where(ac => ac.ArticleID == id)
                .ToListAsync();
            _context.ArticleCategories.RemoveRange(existingLinks);

            if (dto.CategoryIDs != null)
            {
                foreach (var categoryId in dto.CategoryIDs)
                {
                    _context.ArticleCategories.Add(new ArticleCategory
                    {
                        ArticleID = article.ArticleID,
                        CategoryID = categoryId
                    });
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Article updated successfully",
                article.ArticleID,
                article.Title,
                article.ImageUrl // Include ImageUrl in response
            });
        }

        // Updated DTO to include ImageUrl
        public class ArticleDto
        {
            public string Title { get; set; } = null!;
            public string Content { get; set; } = null!;
            public int EditorID { get; set; }
            public string Status { get; set; } = null!;
            public DateTime? PublishDate { get; set; }
            public string? ImageUrl { get; set; } // Add ImageUrl property
            public List<int> CategoryIDs { get; set; } = new();
        }
    }
}