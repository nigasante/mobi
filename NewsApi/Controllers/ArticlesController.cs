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
        [HttpPost("add")]
        public async Task<ActionResult> AddArticle(
            [FromQuery] string title,
            [FromQuery] string content,
            [FromQuery] int editorID,
            [FromQuery] string status,
            [FromQuery] DateTime? publishDate)
        {
            if (string.IsNullOrWhiteSpace(title) ||
                string.IsNullOrWhiteSpace(content) ||
                string.IsNullOrWhiteSpace(status))
            {
                return BadRequest("Title, Content, and Status are required.");
            }

            var article = new Article
            {
                Title = title,
                Content = content,
                EditorID = editorID,
                Status = status,
                PublishDate = publishDate,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            _context.Articles.Add(article);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Article created successfully",
                article.ArticleID,
                article.Title
            });
        }

        // PUT: api/articles/update
        [HttpPut("update")]
        public async Task<IActionResult> UpdateArticle(
            [FromQuery] int id,
            [FromQuery] string title,
            [FromQuery] string content,
            [FromQuery] int editorID,
            [FromQuery] string status,
            [FromQuery] DateTime? publishDate)
        {
            var article = await _context.Articles
                .FirstOrDefaultAsync(a => a.ArticleID == id && !a.IsDeleted);

            if (article == null)
                return NotFound("Article not found");

            article.Title = title;
            article.Content = content;
            article.EditorID = editorID;
            article.Status = status;
            article.PublishDate = publishDate;
            article.UpdatedAt = DateTime.UtcNow;

            _context.Entry(article).State = EntityState.Modified;
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
    }
}
