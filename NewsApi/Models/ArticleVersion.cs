using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

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
        public string? ImageUrl { get; set; }  // Added ImageUrl field
        public DateTime CreatedAt { get; set; }
        public bool IsPublished { get; set; }

        [ForeignKey("ArticleID")]
        public Article? Article { get; set; }
        [ForeignKey("EditorID")]
        public User? Editor { get; set; }
    }
}