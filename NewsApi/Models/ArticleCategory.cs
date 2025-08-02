using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    public class ArticleCategory
    {
        public int ArticleID { get; set; }
        public int CategoryID { get; set; }

        [ForeignKey("ArticleID")]
        public Article Article { get; set; } = null!;

        [ForeignKey("CategoryID")]
        public Category Category { get; set; } = null!;
    }
}
