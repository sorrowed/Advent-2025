const std = @import("std");
const Advent_2025 = @import("Advent_2025");
const day1 = @import("day01");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Advent 2025 in Zig\n", .{});
    try day1.part1();
    try day1.part2();
}

test {
    @import("std").testing.refAllDecls(@This());
}
