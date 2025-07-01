using System;
using System.ComponentModel.DataAnnotations;
namespace NewsApi.Models
{
   public class ArticleCategory
    {
        public int ArticleID { get; set; }
        public int CategoryID { get; set; }
    }
}