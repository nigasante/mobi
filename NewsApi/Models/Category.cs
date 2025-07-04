using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace NewsApi.Models
{
    public class Category
    {
        [Key]
        public int CategoryID { get; set; }
        public required string Name { get; set; }
        public required string Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsDeleted { get; set; }

        public ICollection<ArticleCategory> ArticleCategories { get; set; } = new List<ArticleCategory>();
    }
}
