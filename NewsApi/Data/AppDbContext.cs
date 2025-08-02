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
        public DbSet<Category> Categories { get; set; }
        public DbSet<ArticleCategory> ArticleCategories { get; set; }
        public DbSet<EditorCategory> EditorCategories { get; set; }
        public DbSet<FavoriteArticle> FavoriteArticles { get; set; }

        

        protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Composite keys
    modelBuilder.Entity<UserRole>().HasKey(ur => new { ur.UserID, ur.RoleID });
    modelBuilder.Entity<AdminPermission>().HasKey(ap => new { ap.AdminID, ap.PermissionID });
    modelBuilder.Entity<ArticleCategory>().HasKey(ac => new { ac.ArticleID, ac.CategoryID });
    modelBuilder.Entity<EditorCategory>().HasKey(ec => new { ec.EditorID, ec.CategoryID });

    // Configure ArticleCategory relationships explicitly
    modelBuilder.Entity<ArticleCategory>()
        .HasOne(ac => ac.Article)
        .WithMany(a => a.ArticleCategories)
        .HasForeignKey(ac => ac.ArticleID)
        .OnDelete(DeleteBehavior.Cascade);

    modelBuilder.Entity<ArticleCategory>()
        .HasOne(ac => ac.Category)
        .WithMany(c => c.ArticleCategories)
        .HasForeignKey(ac => ac.CategoryID)
        .OnDelete(DeleteBehavior.Cascade);

    // Configure FavoriteArticles
    modelBuilder.Entity<FavoriteArticle>()
        .HasKey(fa => new { fa.UserID, fa.ArticleID });

    modelBuilder.Entity<FavoriteArticle>()
        .HasOne(fa => fa.User)
        .WithMany()
        .HasForeignKey(fa => fa.UserID)
        .OnDelete(DeleteBehavior.Cascade);

    modelBuilder.Entity<FavoriteArticle>()
        .HasOne(fa => fa.Article)
        .WithMany()
        .HasForeignKey(fa => fa.ArticleID)
        .OnDelete(DeleteBehavior.Cascade);

    // Configure other relationships
    modelBuilder.Entity<User>()
        .HasOne(u => u.Role)
        .WithMany()
        .HasForeignKey(u => u.RoleID);

    modelBuilder.Entity<Article>()
        .HasOne(a => a.Editor)
        .WithMany(u => u.Articles)
        .HasForeignKey(a => a.EditorID);

    // Table names (optional, if you want to match exactly)
    modelBuilder.Entity<Role>().ToTable("Roles");
    modelBuilder.Entity<User>().ToTable("Users");
    modelBuilder.Entity<UserRole>().ToTable("UserRoles");
    modelBuilder.Entity<Permission>().ToTable("Permissions");
    modelBuilder.Entity<AdminPermission>().ToTable("AdminPermissions");
    modelBuilder.Entity<Article>().ToTable("Articles");
    modelBuilder.Entity<Category>().ToTable("Categories");
    modelBuilder.Entity<ArticleCategory>().ToTable("ArticleCategories");
    modelBuilder.Entity<EditorCategory>().ToTable("EditorCategories");
}
    }
}
