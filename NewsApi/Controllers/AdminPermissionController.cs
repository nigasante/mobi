using Microsoft.AspNetCore.Mvc;
using NewsApi.Models;
using System.Collections.Generic;
using System.Linq;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdminPermissionController : ControllerBase
    {
        private static List<AdminPermission> _permissions = new List<AdminPermission>();

        [HttpGet]
        public ActionResult<IEnumerable<AdminPermission>> GetAll()
        {
            return Ok(_permissions);
        }

        [HttpGet("{id}")]
        public ActionResult<AdminPermission> Get(int id)
        {
            var item = _permissions.FirstOrDefault(x => x.AdminID == id);
            if (item == null) return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public ActionResult<AdminPermission> Create(AdminPermission permission)
        {
            _permissions.Add(permission);
            return CreatedAtAction(nameof(Get), new { id = permission.AdminID }, permission);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, AdminPermission permission)
        {
            var item = _permissions.FirstOrDefault(x => x.AdminID == id);
            if (item == null) return NotFound();
            item.PermissionID = permission.PermissionID;
            return NoContent();
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var item = _permissions.FirstOrDefault(x => x.AdminID == id);
            if (item == null) return NotFound();
            _permissions.Remove(item);
            return NoContent();
        }
    }
}