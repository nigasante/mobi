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

        // GET: api/articles
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetArticles([FromQuery] int? categoryId)
        {
            try
            {
                IQueryable<Article> articlesQuery = _context.Articles.Where(a => !a.IsDeleted);

                if (categoryId.HasValue)
                {
                    // Get article IDs that belong to the specified category
                    var articleIdsInCategory = _context.ArticleCategories
                        .Where(ac => ac.CategoryID == categoryId.Value)
                        .Select(ac => ac.ArticleID);

                    articlesQuery = articlesQuery.Where(a => articleIdsInCategory.Contains(a.ArticleID));
                }

                var articles = await articlesQuery.ToListAsync();

                // Build result with category information
                var result = new List<object>();
                
                foreach (var article in articles)
                {
                    var categoryIds = await _context.ArticleCategories
                        .Where(ac => ac.ArticleID == article.ArticleID)
                        .Select(ac => ac.CategoryID)
                        .ToListAsync();

                    result.Add(new
                    {
                        article.ArticleID,
                        article.Title,
                        article.Content,
                        article.EditorID,
                        article.Status,
                        article.PublishDate,
                        article.CreatedAt,
                        article.UpdatedAt,
                        article.IsDeleted,
                        article.ImageUrl,
                        CategoryID = categoryIds
                    });
                }

                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error retrieving articles: {ex.Message}");
            }
        }

        // GET: api/articles/5
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetArticle(int id)
        {
            try
            {
                var article = await _context.Articles
                    .FirstOrDefaultAsync(a => a.ArticleID == id && !a.IsDeleted);

                if (article == null)
                    return NotFound("Article not found");

                var categoryIds = await _context.ArticleCategories
                    .Where(ac => ac.ArticleID == id)
                    .Select(ac => ac.CategoryID)
                    .ToListAsync();

                var result = new
                {
                    article.ArticleID,
                    article.Title,
                    article.Content,
                    article.EditorID,
                    article.Status,
                    article.PublishDate,
                    article.CreatedAt,
                    article.UpdatedAt,
                    article.IsDeleted,
                    article.ImageUrl,
                    CategoryID = categoryIds
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error retrieving article: {ex.Message}");
            }
        }

        // POST: api/articles
        [HttpPost]
        public async Task<ActionResult> AddArticle([FromBody] ArticleDto dto)
        {
            try
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
                    ImageUrl = dto.ImageUrl,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };

                _context.Articles.Add(article);
                await _context.SaveChangesAsync();

                // Add category relationships
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
                    article.ImageUrl
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Error creating article: {ex.Message}");
            }
        }

        // PUT: api/articles/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateArticle(int id, [FromBody] ArticleDto dto)
        {
            try
            {
                var article = await _context.Articles
                    .FirstOrDefaultAsync(a => a.ArticleID == id && !a.IsDeleted);

                if (article == null)
                    return NotFound("Article not found");

                // Update article properties
                article.Title = dto.Title;
                article.Content = dto.Content;
                article.EditorID = dto.EditorID;
                article.Status = dto.Status;
                article.PublishDate = dto.PublishDate;
                article.ImageUrl = dto.ImageUrl;
                article.UpdatedAt = DateTime.UtcNow;

                _context.Entry(article).State = EntityState.Modified;

                // Update categories - remove existing and add new ones
                var existingCategories = await _context.ArticleCategories
                    .Where(ac => ac.ArticleID == id)
                    .ToListAsync();
                
                _context.ArticleCategories.RemoveRange(existingCategories);

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
                }

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Article updated successfully",
                    article.ArticleID,
                    article.Title,
                    article.ImageUrl
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Error updating article: {ex.Message}");
            }
        }

        // DELETE: api/articles/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteArticle(int id)
        {
            try
            {
                var article = await _context.Articles
                    .FirstOrDefaultAsync(a => a.ArticleID == id && !a.IsDeleted);

                if (article == null)
                    return NotFound("Article not found");

                // Soft delete
                article.IsDeleted = true;
                article.UpdatedAt = DateTime.UtcNow;

                _context.Entry(article).State = EntityState.Modified;
                await _context.SaveChangesAsync();

                return Ok(new { message = "Article deleted successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest($"Error deleting article: {ex.Message}");
            }
        }

        public class ArticleDto
        {
            public string Title { get; set; } = null!;
            public string Content { get; set; } = null!;
            public int EditorID { get; set; }
            public string Status { get; set; } = null!;
            public DateTime? PublishDate { get; set; }
            public string? ImageUrl { get; set; }
            public List<int> CategoryIDs { get; set; } = new();
        }
    }
}