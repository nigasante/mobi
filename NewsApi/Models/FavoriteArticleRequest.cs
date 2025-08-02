using System.ComponentModel.DataAnnotations;

namespace NewsApi.Models
{
    public class FavoriteArticleRequest
    {
        [Required]
        public int UserID { get; set; }

        [Required]
        public int ArticleID { get; set; }
    }
}
