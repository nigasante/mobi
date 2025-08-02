using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    public class EditorCategory
    {
        public int EditorID { get; set; }
        public int CategoryID { get; set; }

        [ForeignKey("EditorID")]
        public User Editor { get; set; } = null!;
        [ForeignKey("CategoryID")]
        public Category Category { get; set; } = null!;
    }
}