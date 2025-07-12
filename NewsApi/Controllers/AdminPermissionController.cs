using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NewsApi.Data;
using NewsApi.Models;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdminPermissionController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AdminPermissionController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<AdminPermission>>> GetAll()
        {
            var permissions = await _context.AdminPermissions
                .Include(p => p.Admin)
                .Include(p => p.Permission)
                .ToListAsync();
            return Ok(permissions);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AdminPermission>> Get(int id)
        {
            var permission = await _context.AdminPermissions
                .Include(p => p.Admin)
                .Include(p => p.Permission)
                .FirstOrDefaultAsync(p => p.AdminID == id);

            if (permission == null) 
                return NotFound();

            return Ok(permission);
        }

        [HttpPost]
        public async Task<ActionResult<AdminPermission>> Create(AdminPermission permission)
        {
            _context.AdminPermissions.Add(permission);
            await _context.SaveChangesAsync();
            
            return CreatedAtAction(nameof(Get), 
                new { id = permission.AdminID }, permission);
        }

        [HttpDelete("{adminId}/{permissionId}")]
        public async Task<IActionResult> Delete(int adminId, int permissionId)
        {
            var permission = await _context.AdminPermissions
                .FirstOrDefaultAsync(p => 
                    p.AdminID == adminId && 
                    p.PermissionID == permissionId);

            if (permission == null) 
                return NotFound();

            _context.AdminPermissions.Remove(permission);
            await _context.SaveChangesAsync();
            
            return NoContent();
        }
    }
}