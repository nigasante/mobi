using System;
using System.ComponentModel.DataAnnotations;
namespace NewsApi.Models
{
      public class Permission
    {
        [Key]
        public int PermissionID { get; set; }
        public required string PermissionName { get; set; }
    }
}