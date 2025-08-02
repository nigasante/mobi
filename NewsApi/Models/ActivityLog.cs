using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    public class ActivityLog
    {
        [Key]
        public int LogID { get; set; }
        public int UserID { get; set; }
        public required string Action { get; set; }
        public required string TableName { get; set; }
        public DateTime Timestamp { get; set; }

        [ForeignKey("UserID")]
        public User? User { get; set; }
    }
}