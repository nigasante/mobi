using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using System.IO;
using NewsApi.Models;

namespace NewsApi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Role> Roles { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<AdminPermission> AdminPermissions { get; set; }
        public DbSet<Article> Articles { get; set; }
        public DbSet<ArticleVersion> ArticleVersions { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<ArticleCategory> ArticleCategories { get; set; }
        public DbSet<EditorCategory> EditorCategories { get; set; }
        public DbSet<ActivityLog> ActivityLogs { get; set; }

        

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Composite keys
            modelBuilder.Entity<UserRole>().HasKey(ur => new { ur.UserID, ur.RoleID });
            modelBuilder.Entity<AdminPermission>().HasKey(ap => new { ap.AdminID, ap.PermissionID });
            modelBuilder.Entity<ArticleCategory>().HasKey(ac => new { ac.ArticleID, ac.CategoryID });
            modelBuilder.Entity<EditorCategory>().HasKey(ec => new { ec.EditorID, ec.CategoryID });

            // Table names (optional, if you want to match exactly)
            modelBuilder.Entity<Role>().ToTable("Roles");
            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<UserRole>().ToTable("UserRoles");
            modelBuilder.Entity<Permission>().ToTable("Permissions");
            modelBuilder.Entity<AdminPermission>().ToTable("AdminPermissions");
            modelBuilder.Entity<Article>().ToTable("Articles");
            modelBuilder.Entity<ArticleVersion>().ToTable("ArticleVersions");
            modelBuilder.Entity<Category>().ToTable("Categories");
            modelBuilder.Entity<ArticleCategory>().ToTable("ArticleCategories");
            modelBuilder.Entity<EditorCategory>().ToTable("EditorCategories");
            modelBuilder.Entity<ActivityLog>().ToTable("ActivityLogs");
        }
    }
}
