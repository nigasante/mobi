using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NewsApi.Data;
using NewsApi.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FavoriteArticlesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FavoriteArticlesController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/FavoriteArticles/user/5
        [HttpGet("user/{userId}")]
        public async Task<ActionResult<IEnumerable<object>>> GetUserFavorites(int userId)
        {
            var favorites = await _context.FavoriteArticles
                .Where(f => f.UserID == userId)
                .Include(f => f.Article)
                .Select(f => new
                {
                    f.Article.ArticleID,
                    f.Article.Title,
                    f.Article.Content,
                    f.Article.Status,
                    f.Article.PublishDate,
                    f.Article.ImageUrl,
                    f.SavedAt
                })
                .ToListAsync();

            if (!favorites.Any())
                return NotFound($"No favorite articles found for user {userId}");

            return Ok(favorites);
        }

        // POST: api/FavoriteArticles
        [HttpPost]
        public async Task<ActionResult> AddFavorite([FromBody] FavoriteArticleRequest request)
        {
            // Verify that both user and article exist
            var user = await _context.Users.FindAsync(request.UserID);
            if (user == null)
                return NotFound($"User with ID {request.UserID} not found");

            var article = await _context.Articles.FindAsync(request.ArticleID);
            if (article == null)
                return NotFound($"Article with ID {request.ArticleID} not found");

            var existing = await _context.FavoriteArticles
                .FindAsync(request.UserID, request.ArticleID);
            
            if (existing != null)
                return Conflict($"Article {request.ArticleID} is already in user {request.UserID}'s favorites");

            var favorite = new FavoriteArticle
            {
                UserID = request.UserID,
                ArticleID = request.ArticleID,
                User = user,
                Article = article
            };

            _context.FavoriteArticles.Add(favorite);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUserFavorites), new { userId = request.UserID }, favorite);
        }

        // DELETE: api/FavoriteArticles/5/3
        [HttpDelete("{userId}/{articleId}")]
        public async Task<ActionResult> RemoveFavorite(int userId, int articleId)
        {
            var favorite = await _context.FavoriteArticles
                .FindAsync(userId, articleId);

            if (favorite == null)
                return NotFound($"Article {articleId} is not in user {userId}'s favorites");

            _context.FavoriteArticles.Remove(favorite);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // GET: api/FavoriteArticles/count/5
        [HttpGet("count/{userId}")]
        public async Task<ActionResult<int>> GetUserFavoriteCount(int userId)
        {
            var count = await _context.FavoriteArticles
                .CountAsync(f => f.UserID == userId);

            return Ok(count);
        }
    }
}