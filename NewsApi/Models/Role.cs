using System;
using System.ComponentModel.DataAnnotations;

namespace NewsApi.Models
{
    public class Role
    {
        [Key]
        public int RoleID { get; set; }
        public required string RoleName { get; set; }
    }
}