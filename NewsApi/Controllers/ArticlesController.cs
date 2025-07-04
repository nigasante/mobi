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

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Article>>> GetArticles([FromQuery] int? categoryId)
        {
            var query = _context.Articles
                .Where(a => !a.IsDeleted);

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




        // GET: api/articles/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Article>> GetArticle(int id)
        {
            var article = await _context.Articles
                .FirstOrDefaultAsync(a => a.ArticleID == id && !a.IsDeleted);

            if (article == null)
                return NotFound();

            return Ok(article);
        }

        // POST: api/articles/add
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
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            _context.Articles.Add(article);
            await _context.SaveChangesAsync(); // Save to get the ArticleID

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
                article.Title
            });
        }

        // PUT: api/articles/update
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
            article.UpdatedAt = DateTime.UtcNow;

            _context.Entry(article).State = EntityState.Modified;

            // Remove old category links
            var existingLinks = _context.ArticleCategories
                .Where(ac => ac.ArticleID == id);
            _context.ArticleCategories.RemoveRange(existingLinks);

            // Add new category links
            foreach (var categoryId in dto.CategoryIDs)
            {
                _context.ArticleCategories.Add(new ArticleCategory
                {
                    ArticleID = article.ArticleID,
                    CategoryID = categoryId
                });
            }

            await _context.SaveChangesAsync();

            return Ok(new { message = "Article updated successfully" });
        }

        // DELETE: api/articles/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteArticle(int id)
        {
            var article = await _context.Articles.FindAsync(id);

            if (article == null || article.IsDeleted)
                return NotFound("Article not found");

            article.IsDeleted = true;
            article.UpdatedAt = DateTime.UtcNow;

            _context.Entry(article).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Article deleted (soft delete)" });
        }

        public class ArticleDto
        {
            public string Title { get; set; } = null!;
            public string Content { get; set; } = null!;
            public int EditorID { get; set; }
            public string Status { get; set; } = null!;
            public DateTime? PublishDate { get; set; }
            public List<int> CategoryIDs { get; set; } = new(); // multiple category support
        }

    }
}
