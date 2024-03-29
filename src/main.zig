const std = @import("std");

pub fn println(comptime fmt: []const u8, args: anytype) void {
  std.io.getStdOut().writer().print(fmt ++ "\n", args) catch {};
}

const Conversion = struct {
  decimal: []const u8,
  hexadecimal: []const u8,
  binary: []const u8,
}; 
  
pub fn convert(allocator: std.mem.Allocator, value: []const u8) !Conversion {
  var number = try std.fmt.parseInt(i128, value, 0);
  // We could allocate a little bit less but that's fine.
  var decimal: []u8 = try allocator.alloc(u8, 130);
  errdefer allocator.free(decimal);
  var sdecimal = try std.fmt.bufPrint(decimal, "{}", .{ number });
  
  var hexadecimal: []u8 = try allocator.alloc(u8, 130);
  errdefer allocator.free(hexadecimal);
  var shexadecimal = try std.fmt.bufPrint(hexadecimal, "0x{x}", .{ number });
  
  var binary: []u8 = try allocator.alloc(u8, 130);
  errdefer allocator.free(binary);
  var sbinary = try std.fmt.bufPrint(binary, "0b{b}", .{ number });
   
  return .{
   .decimal = sdecimal,
   .hexadecimal = shexadecimal,
   .binary = sbinary,
  };
}  
  
fn usage(name: []const u8) void {
  println("Usage: {s} <number>", .{ name });
  println("example:", .{});
  println(" {s} 123", .{ name });
  println(" {s} 0xDEADBEEF", .{ name });
  println(" {s} 0b10101010", .{ name });
}

pub fn main() !void {
  var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = general_purpose_allocator.allocator();

  const args: [][:0]u8 = try std.process.argsAlloc(allocator);
  defer std.process.argsFree(allocator, args);
  if (args.len != 2) {
    println("error: incorrect number of argument", .{});
    usage(args[0]);
    return;
  }

  const result = convert(allocator, args[1]) catch {
    println("error: invalid argument {s}", .{ args[1] });
    std.os.exit(1);
  };
  println("{s} {s} {s} ({} bits)", .{
    result.decimal,
    result.hexadecimal,
    result.binary,
    result.binary.len - 2,
  });
  // We don't deallocate result and that's fine...
}

test "conversion test" {
  var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = general_purpose_allocator.allocator();
  {
    const result = try convert(allocator, "0");
    try std.testing.expectEqual(std.mem.eql(u8, result.decimal, "0"), true);
    try std.testing.expectEqual(std.mem.eql(u8, result.hexadecimal, "0x0"), true);
    try std.testing.expectEqual(std.mem.eql(u8, result.binary, "0b0"), true);
  }
  {
    const result = try convert(allocator, "128");
    try std.testing.expectEqual(std.mem.eql(u8, result.decimal, "128"), true);
    try std.testing.expectEqual(std.mem.eql(u8, result.hexadecimal, "0x80"), true);
    try std.testing.expectEqual(std.mem.eql(u8, result.binary, "0b10000000"), true);
  }
}
