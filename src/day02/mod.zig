const std = @import("std");
const expect = std.testing.expect;

const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
const puzzle_input = "269194394-269335492,62371645-62509655,958929250-958994165,1336-3155,723925-849457,4416182-4470506,1775759815-1775887457,44422705-44477011,7612653647-7612728309,235784-396818,751-1236,20-36,4-14,9971242-10046246,8796089-8943190,34266-99164,2931385381-2931511480,277-640,894249-1083306,648255-713763,19167863-19202443,62-92,534463-598755,93-196,2276873-2559254,123712-212673,31261442-31408224,421375-503954,8383763979-8383947043,17194-32288,941928989-941964298,3416-9716";

const Range = struct { begin: u64, end: u64 };

fn parse_pairs(gpa: std.mem.Allocator, input: []const u8) !std.ArrayList(Range) {
    var ranges = std.ArrayList(Range).empty;

    var it = std.mem.splitScalar(u8, input, ',');
    while (it.next()) |line| {
        var pair = std.mem.splitScalar(u8, line, '-');

        const p = Range{
            .begin = try std.fmt.parseInt(u64, pair.next().?, 10),
            .end = try std.fmt.parseInt(u64, pair.next().?, 10),
        };

        try ranges.append(gpa, p);
    }
    return ranges;
}

fn is_invalid(number: u64) bool {
    const ord = @divTrunc(std.math.log10(number) + 1, 2);

    const fr = std.math.pow(u64, 10, ord);
    const f = @divTrunc(number, fr);
    const s = @mod(number, fr);

    return f == s;
}

fn count_if(comptime T: type, arr: []T, predicate: fn (T) bool) usize {
    var count: usize = 0;
    for (arr) |item| {
        if (predicate(item)) {
            count += 1;
        }
    }
    return count;
}

fn count_if_range(r: Range) usize {
    var result: usize = 0;

    for (r.begin..r.end + 1) |i| {
        if (is_invalid(@intCast(i))) {
            result += 1;
        }
    }

    return result;
}

fn add_if_range(r: Range) u64 {
    var result: u64 = 0;

    for (r.begin..r.end + 1) |i| {
        if (is_invalid(@intCast(i))) {
            result += @intCast(i);
        }
    }

    return result;
}

test "parsing of ranges" {
    const gpa = std.heap.page_allocator;

    var pairs = try parse_pairs(gpa, test_input);
    defer {
        pairs.deinit(gpa);
    }

    try expect(pairs.items.len == 11);
}

test "determine invalid numbers" {
    try expect(is_invalid(11));
    try expect(is_invalid(1010));
    try expect(is_invalid(100100));
    try expect(is_invalid(10001000));

    try expect(is_invalid(55));
    try expect(is_invalid(6464));
    try expect(is_invalid(123123));
    try expect(!is_invalid(101));
}

test "invalid numbers in test input" {
    const gpa = std.heap.page_allocator;

    var pairs = try parse_pairs(gpa, test_input);
    defer {
        pairs.deinit(gpa);
    }

    try expect(count_if_range(pairs.items[0]) == 2);
    try expect(count_if_range(pairs.items[1]) == 1);
    try expect(count_if_range(pairs.items[2]) == 1);
    try expect(count_if_range(pairs.items[3]) == 1);
    try expect(count_if_range(pairs.items[4]) == 1);
    try expect(count_if_range(pairs.items[5]) == 0);
    try expect(count_if_range(pairs.items[6]) == 1);
    try expect(count_if_range(pairs.items[7]) == 1);
    try expect(count_if_range(pairs.items[8]) == 0);
    try expect(count_if_range(pairs.items[9]) == 0);
    try expect(count_if_range(pairs.items[10]) == 0);
}

pub fn part1() !void {
    const gpa = std.heap.page_allocator;

    var pairs = try parse_pairs(gpa, puzzle_input);
    defer {
        pairs.deinit(gpa);
    }

    var count: u64 = 0;
    for (pairs.items) |r| {
        count += add_if_range(r);
    }

    std.debug.print("Day 02, part 1 : Number of invalid range ids -> {d} \n", .{count});
}

pub fn part2() !void {
    std.debug.print("Day 02, part 2 : Number of times we had zeroes -> {d} \n", .{0});
}
