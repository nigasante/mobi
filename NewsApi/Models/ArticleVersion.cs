using System;
using System.ComponentModel.DataAnnotations;
namespace NewsApi.Models
{
     public class ArticleVersion
    {
        [Key]
        public int VersionID { get; set; }
        public int ArticleID { get; set; }
        public required string Title { get; set; }
        public required string Content { get; set; }
        public int EditorID { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsPublished { get; set; }
    }
}