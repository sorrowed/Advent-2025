const std = @import("std");
const Advent_2025 = @import("Advent_2025");
const day1 = @import("day01");
const day2 = @import("day02");
const day3 = @import("day03");
const day4 = @import("day04");
const util = @import("util");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Advent 2025 in Zig\n", .{});
    try day1.partOne();
    try day1.partTwo();
    try day2.partOne();
    try day2.partTwo();
    try day3.partOne();
    try day3.partTwo();
    try day4.partOne();
    try day4.partTwo();
}

test {
    @import("std").testing.refAllDecls(@This());
}
