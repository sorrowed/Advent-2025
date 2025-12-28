const std = @import("std");

const test_input = [_][]const u8{
    "..@@.@@@@.",
    "@@@.@.@.@@",
    "@@@@@.@.@@",
    "@.@@@@..@.",
    "@@.@@@@.@@",
    ".@@@@@@@.@",
    ".@.@.@.@@@",
    "@.@@@.@@@@",
    ".@@@@@@@@.",
    "@.@.@@@.@.",
};

test "test" {
    for (test_input, 0..) |v, i| {
        std.debug.print("{} {}\n", .{ i, v });
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
