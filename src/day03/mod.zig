const std = @import("std");

const test_input = "987654321111111\n811111111111119\n234234234234278\n818181911112111";

fn parse_bank(gpa: std.mem.Allocator, token: []const u8) !std.ArrayList(i32) {
    var item = std.ArrayList(i32).empty;

    for (token) |c| {
        try item.append(gpa, try std.fmt.charToDigit(c, 10));
    }

    return item;
}

fn parse_banks(gpa: std.mem.Allocator, input: []const u8) !std.ArrayList(std.ArrayList(i32)) {
    var list = std.ArrayList(std.ArrayList(i32)).empty;
    errdefer list.deinit(gpa);

    var it = std.mem.splitAny(u8, input, "\n");
    while (it.next()) |token| {
        const item = try parse_bank(gpa, token);

        try list.append(gpa, item);
    }

    return list;
}

const IndexAndValue = struct { index: usize, value: i32 };

fn max(items: []const i32) ?IndexAndValue {
    if (items.len < 1) return null;

    var result: IndexAndValue = .{ .index = 0, .value = items[0] };

    var index: usize = 1;
    while (index < items.len) {
        if (items[index] > result.value) {
            result = IndexAndValue{ .index = index, .value = items[index] };
        }
        index += 1;
    }

    return result;
}

const PairError = error{NotFound};

fn parse_highest_jolts(item: []const i32, len: usize) !i64 {
    var result: i64 = 0;
    var pos: usize = 0;

    for (0..len) |n| {
        const f = max(item[pos .. item.len - len + n + 1]) orelse return PairError.NotFound;

        result = result * 10 + f.value;
        pos += f.index + 1;
    }
    return result;
}

fn test_slice_and_free(gpa: std.mem.Allocator, expected: []const i32, actual: *std.ArrayList(i32)) !void {
    const s = try actual.toOwnedSlice(gpa);
    defer gpa.free(s);

    try std.testing.expectEqualSlices(i32, expected, s);
}

fn test_parse_highest_jolts_and_free(gpa: std.mem.Allocator, expected: i64, actual: *std.ArrayList(i32), len: usize, parse: fn ([]i32, usize) PairError!i64) !void {
    const s = try actual.toOwnedSlice(gpa);
    defer gpa.free(s);

    const p = try parse(s, len);

    try std.testing.expectEqual(expected, p);
}

test "iterate input into arraylist" {
    const gpa = std.heap.page_allocator;

    var list = try parse_banks(gpa, test_input);
    defer (list.deinit(gpa));

    try std.testing.expectEqual(4, list.items.len);

    try test_slice_and_free(gpa, &[_]i32{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1 }, &list.items[0]);
    try test_slice_and_free(gpa, &[_]i32{ 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9 }, &list.items[1]);
    try test_slice_and_free(gpa, &[_]i32{ 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8 }, &list.items[2]);
    try test_slice_and_free(gpa, &[_]i32{ 8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1 }, &list.items[3]);
}

test "determine highest jolts in test input" {
    const gpa = std.heap.page_allocator;

    var list = try parse_banks(gpa, test_input);
    defer (list.deinit(gpa));

    try test_parse_highest_jolts_and_free(gpa, 98, &list.items[0], 2, parse_highest_jolts);
    try test_parse_highest_jolts_and_free(gpa, 89, &list.items[1], 2, parse_highest_jolts);
    try test_parse_highest_jolts_and_free(gpa, 78, &list.items[2], 2, parse_highest_jolts);
    try test_parse_highest_jolts_and_free(gpa, 92, &list.items[3], 2, parse_highest_jolts);
}

test "validate example jolts for second part" {
    const gpa = std.heap.page_allocator;

    var list = try parse_banks(gpa, test_input);
    defer (list.deinit(gpa));

    try test_parse_highest_jolts_and_free(gpa, 987654321111, &list.items[0], 12, parse_highest_jolts);
    try test_parse_highest_jolts_and_free(gpa, 811111111119, &list.items[1], 12, parse_highest_jolts);
    try test_parse_highest_jolts_and_free(gpa, 434234234278, &list.items[2], 12, parse_highest_jolts);
    try test_parse_highest_jolts_and_free(gpa, 888911112111, &list.items[3], 12, parse_highest_jolts);
}

pub fn part1() !void {
    const file = try std.fs.cwd().openFile(
        "src/day03/input.txt",
        .{},
    );
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(std.testing.io, &read_buffer);

    const gpa = std.heap.page_allocator;

    var total: i64 = 0;
    while (true) {
        const line = try reader.interface.takeDelimiter('\n') orelse break;

        var bank = try parse_bank(gpa, line);

        total += try parse_highest_jolts(try bank.toOwnedSlice(gpa), 2);
    }

    std.debug.assert(total == 16812);

    std.debug.print("Day 03, part 1 : -> Total jolts {d} \n", .{total});
}

pub fn part2() !void {
    const file = try std.fs.cwd().openFile(
        "src/day03/input.txt",
        .{},
    );
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(std.testing.io, &read_buffer);

    const gpa = std.heap.page_allocator;

    var total: i64 = 0;
    while (true) {
        const line = try reader.interface.takeDelimiter('\n') orelse break;

        var bank = try parse_bank(gpa, line);

        total += try parse_highest_jolts(try bank.toOwnedSlice(gpa), 12);
    }

    std.debug.assert(total == 166345822896410);

    std.debug.print("Day 03, part 2 : -> Total jolts {d} \n", .{total});
}
