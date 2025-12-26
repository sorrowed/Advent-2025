const std = @import("std");
const Advent_2025 = @import("Advent_2025");
const day1 = @import("day01");
const day2 = @import("day02");
const day3 = @import("day03");
const util = @import("util");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Advent 2025 in Zig\n", .{});
    try day1.part1();
    try day1.part2();
    try day2.part1();
    try day2.part2();
    try day3.part1();
    try day3.part2();
}

test {
    @import("std").testing.refAllDecls(@This());
}
