using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    public class User
    {
        [Key]
        public int UserID { get; set; }
        public string? Name { get; set; }
        public string? Email { get; set; }
        public string? Password { get; set; }
        public int RoleID { get; set; }
        public string? Preferences { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsDeleted { get; set; }

        [ForeignKey("RoleID")]
        public Role? Role { get; set; }
        public ICollection<Article> Articles { get; set; } = new List<Article>();
        public ICollection<ArticleVersion> ArticleVersions { get; set; } = new List<ArticleVersion>();
        public ICollection<EditorCategory> EditorCategories { get; set; } = new List<EditorCategory>();
    }
}