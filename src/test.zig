const std = @import("std");

comptime {
    _ = @import("util/mod.zig");
    _ = @import("day01/mod.zig");
    _ = @import("day02/mod.zig");
    _ = @import("day03/mod.zig");
    _ = @import("day04/mod.zig");
    _ = @import("day05/mod.zig");
    _ = @import("day06/mod.zig");
    _ = @import("day07/mod.zig");
}

test {
    std.testing.refAllDecls(@This());
}
