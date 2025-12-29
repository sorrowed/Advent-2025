const std = @import("std");
const util = @import("util");
const day01 = @import("day01");
const day02 = @import("day02");
const day03 = @import("day03");
const day04 = @import("day04");
const day05 = @import("day05");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Advent 2025 in Zig\n", .{});
    try day01.partOne();
    try day01.partTwo();
    try day02.partOne();
    try day02.partTwo();
    try day03.partOne();
    try day03.partTwo();
    try day04.partOne();
    try day04.partTwo();
    try day05.partOne();
    try day05.partTwo();
}
