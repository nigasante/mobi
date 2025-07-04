using System;
using System.ComponentModel.DataAnnotations;

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
    }
}
