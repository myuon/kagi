const std = @import("std");
const compiler = @import("compiler.zig");

pub fn main() !void {
    var gpallocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        switch (gpallocator.deinit()) {
            .leak => {
                std.debug.print("**Leaked memory**", .{});
            },
            else => {},
        }
    }

    var c = compiler.Compiler.init(gpallocator.allocator());
    defer c.deinit();

    const result = try c.evalModule(
        \\fun main() do
        \\  let a = 1;
        \\  let b = 1;
        \\  let n = 0;
        \\
        \\  while (n < 40) do
        \\    let c = a + b;
        \\    a = b;
        \\    b = c;
        \\    n = n + 1;
        \\  end
        \\
        \\  return a;
        \\end
    );

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Result: {any}\n", .{result});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test {
    _ = @import("utils.zig");
    _ = @import("ast.zig");
    _ = @import("compiler.zig");
}
