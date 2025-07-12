using System.ComponentModel.DataAnnotations.Schema;

namespace NewsApi.Models
{
    public class AdminPermission
    {
        public int AdminID { get; set; }
        public int PermissionID { get; set; }

        [ForeignKey("AdminID")]
        public User Admin { get; set; } = null!;
        [ForeignKey("PermissionID")]
        public Permission Permission { get; set; } = null!;
    }
}