using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NewsApi.Data;
using NewsApi.Models;

namespace NewsApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetAllUsers()
        {
            var users = await _context.Users
                .Where(u => !u.IsDeleted)
                .ToListAsync();

            return Ok(users);
        }


        // POST: api/users/add?name=...&email=...&password=...&roleID=1&preferences=...
        [HttpPost("add")]
        public async Task<ActionResult> AddUser(
            [FromQuery] string name,
            [FromQuery] string email,
            [FromQuery] string password,
            [FromQuery] int roleID,
            [FromQuery] string? preferences)
        {
            if (string.IsNullOrWhiteSpace(name) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password))
            {
                return BadRequest("Name, Email, and Password are required.");
            }

            bool emailExists = await _context.Users
                .AnyAsync(u => u.Email == email && !u.IsDeleted);

            if (emailExists)
            {
                return Conflict("A user with this email already exists.");
            }

            var newUser = new User
            {
                Name = name,
                Email = email,
                Password = password,
                RoleID = roleID,
                Preferences = preferences ?? "{}",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "User created successfully",
                newUser.UserID,
                newUser.Name,
                newUser.Email
            });
        }

        // PUT: api/users/update?id=1&name=...&email=...&password=...&roleID=...&preferences=...
        [HttpPut("update")]
        public async Task<IActionResult> UpdateUser(
            [FromQuery] int id,
            [FromQuery] string name,
            [FromQuery] string email,
            [FromQuery] string password,
            [FromQuery] int roleID,
            [FromQuery] string? preferences)
        {
            if (string.IsNullOrWhiteSpace(name) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password))
            {
                return BadRequest("Name, Email, and Password are required.");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserID == id && !u.IsDeleted);
            if (user == null)
            {
                return NotFound("User not found");
            }

            // Optional: prevent email duplication
            bool emailInUse = await _context.Users
                .AnyAsync(u => u.Email == email && u.UserID != id && !u.IsDeleted);
            if (emailInUse)
            {
                return Conflict("Email is already used by another user.");
            }

            user.Name = name;
            user.Email = email;
            user.Password = password;
            user.RoleID = roleID;
            user.Preferences = preferences ?? user.Preferences;
            user.UpdatedAt = DateTime.UtcNow;

            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "User updated successfully",
                user.UserID,
                user.Name,
                user.Email,
                user.RoleID,
                user.Preferences
            });
        }



        // DELETE: api/users/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);

            if (user == null || user.IsDeleted)
                return NotFound("User not found");

            user.IsDeleted = true;
            user.UpdatedAt = DateTime.UtcNow;

            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            return Ok(new { message = "User deleted (soft delete)" });
        }

        // POST: api/users/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] User loginUser)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Email == loginUser.Email &&
                u.Password == loginUser.Password &&
                !u.IsDeleted);

            if (user == null)
                return Unauthorized(new { message = "Invalid credentials" });

            return Ok(new
            {
                user.UserID,
                user.Name,
                user.Email,
                user.RoleID
            });
        }

        // POST: api/users/signup?name=...&email=...&password=...
        [HttpPost("signup")]
        public async Task<ActionResult> SignUp(
            [FromQuery] string name,
            [FromQuery] string email,
            [FromQuery] string password)
        {
            if (string.IsNullOrWhiteSpace(name) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrWhiteSpace(password))
            {
                return BadRequest("Name, Email, and Password are required.");
            }

            bool emailExists = await _context.Users
                .AnyAsync(u => u.Email == email && !u.IsDeleted);

            if (emailExists)
            {
                return Conflict("A user with this email already exists.");
            }

            var newUser = new User
            {
                Name = name,
                Email = email,
                Password = password,
                RoleID = 3, // Default role
                Preferences = "{}",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "User signed up successfully",
                newUser.UserID,
                newUser.Name,
                newUser.Email
            });
        }

    }

    // DTO for AddUser
    public class AddUserRequest
    {
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
        public int RoleID { get; set; }
        public string? Preferences { get; set; }
    }
}
