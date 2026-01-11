const std = @import("std");
const util = @import("util.zig");

const test_input = [_][]const u8{
    ".......S.......",
    "...............",
    ".......^.......",
    "...............",
    "......^.^......",
    "...............",
    ".....^.^.^.....",
    "...............",
    "....^.^...^....",
    "...............",
    "...^.^...^.^...",
    "...............",
    "..^...^.....^..",
    "...............",
    ".^.^.^.^.^...^.",
    "...............",
};

const Tile = struct {
    const Type = enum(u8) {
        EMPTY = '.',
        START = 'S',
        SPLITTER = '^',
    };
    type: Type,
};

const Map = struct {
    tiles: std.AutoHashMap(util.Vector2, Tile),
    extends: util.Extends,

    pub fn deinit(self: *Map) void {
        self.tiles.deinit();
    }

    fn count(self: *Map) usize {
        return self.tiles.count();
    }

    fn get(self: *const Map, key: util.Vector2) ?Tile {
        return self.tiles.get(key);
    }
};

fn parseMap(gpa: std.mem.Allocator, input: []const []const u8) !Map {
    var result = std.AutoHashMap(util.Vector2, Tile).init(gpa);

    var x_max: i32 = 0;
    var y_max: i32 = 0;

    for (input, 0..) |v, yu| {
        const y = @as(i32, @intCast(yu));

        for (v, 0..) |c, xu| {
            const x = @as(i32, @intCast(xu));

            try result.put(.{ .x = x, .y = y }, .{ .type = @enumFromInt(c) });

            x_max = @max(x_max, x);
        }
        y_max = @max(y_max, y);
    }
    return .{ .tiles = result, .extends = .{ .tl = .{ .x = 0, .y = 0 }, .br = .{ .x = x_max, .y = y_max } } };
}

test "parse map, test extends and extract some items" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer {
        map.deinit();
    }

    try std.testing.expectEqual(15 * 16, map.count());

    const expectedExtends: util.Extends = .{ .tl = .{ .x = 0, .y = 0 }, .br = .{ .x = 14, .y = 15 } };
    try std.testing.expectEqual(expectedExtends, map.extends);
}

pub fn partOne() !void {
    // std.debug.assert(grand_total == 5060053676136);
    std.debug.print("Day 07, part 1 : {d} \n", .{1});
}

pub fn partTwo() !void {
    // std.debug.assert(grand_total == 5060053676136);
    std.debug.print("Day 07, part 2 : {d} \n", .{2});
}
