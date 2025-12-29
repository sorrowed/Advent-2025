const std = @import("std");

const test_input = [_][]const u8{
    "3-5",
    "10-14",
    "16-20",
    "12-18",
    "",
    "1",
    "5",
    "8",
    "11",
    "17",
    "32",
};

test "test" {
    for (test_input, 0..) |v, i| {
        std.debug.print("{d} {s}\n", .{ i, v });
    }
    try std.testing.expect(true);
}

pub fn partOne() !void {
    std.debug.assert(false);

    std.debug.print("Day XX, part 1 : -> {d} \n", .{1});
}

pub fn partTwo() !void {
    std.debug.assert(false);

    std.debug.print("Day XX, part 2 : -> {d} \n", .{2});
}
