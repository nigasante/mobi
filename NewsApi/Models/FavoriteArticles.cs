using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    [Table("FavoriteArticles")]
    public class FavoriteArticle
    {
        [Key]
        [Column(Order = 0)]
        public int UserID { get; set; }

        [Key]
        [Column(Order = 1)]
        public int ArticleID { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime SavedAt { get; set; }

        [ForeignKey("UserID")]
        public required virtual User User { get; set; }

        [ForeignKey("ArticleID")]
        public required virtual Article Article { get; set; }
    }
}