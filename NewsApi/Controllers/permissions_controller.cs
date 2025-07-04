using Microsoft.AspNetCore.Mvc;
using NewsApi.Models;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PermissionsController : ControllerBase
    {
        // GET: api/permissions
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Permission>>> GetPermissions()
        {
            // Implementation here
            return Ok();
        }

        // GET: api/permissions/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Permission>> GetPermission(int id)
        {
            // Implementation here
            return Ok();
        }

        // POST: api/permissions
        [HttpPost]
        public async Task<ActionResult<Permission>> CreatePermission(Permission permission)
        {
            // Implementation here
            return CreatedAtAction(nameof(GetPermission), new { id = permission.PermissionID }, permission);
        }

        // PUT: api/permissions/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdatePermission(int id, Permission permission)
        {
            // Implementation here
            return NoContent();
        }

        // DELETE: api/permissions/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePermission(int id)
        {
            // Implementation here
            return NoContent();
        }
    }
}