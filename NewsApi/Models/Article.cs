using System;
using System.ComponentModel.DataAnnotations;
namespace NewsApi.Models
{
    public class Article
    {
        internal int CategoryID;

        [Key]
        public int ArticleID { get; set; }
        public required string Title { get; set; }
        public required string Content { get; set; }
        public int EditorID { get; set; }
        public required string Status { get; set; }
        public DateTime? PublishDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsDeleted { get; set; }
    }
}