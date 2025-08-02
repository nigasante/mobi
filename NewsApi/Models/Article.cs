using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    public class Article
    {
        [Key]
        public int ArticleID { get; set; }
        public required string Title { get; set; }
        public required string Content { get; set; }
        public int EditorID { get; set; }
        public required string Status { get; set; }
        public string? ImageUrl { get; set; }  // Added ImageUrl field
        public DateTime? PublishDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsDeleted { get; set; }

        [ForeignKey("EditorID")]
        public User? Editor { get; set; }
        public ICollection<ArticleCategory> ArticleCategories { get; set; } = new List<ArticleCategory>();
    }
}