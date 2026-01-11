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
        TACHYON = '|',
    };
    type: Type,
};

const Map = struct {
    tiles: std.AutoHashMap(util.Vector2, Tile),
    extends: util.Extends,
    splits: i32,
    timelines: i32,

    pub fn deinit(self: *Map) void {
        self.tiles.deinit();
    }

    fn count(self: *Map) usize {
        return self.tiles.count();
    }

    fn get(self: *const Map, key: util.Vector2) ?Tile {
        return self.tiles.get(key);
    }

    fn update(self: *Map) void {
        self.timelines = 1;
        var y: i32 = self.extends.tl.y;
        while (y <= self.extends.br.y - 1) : (y += 1) {
            var x: i32 = self.extends.tl.x;
            while (x <= self.extends.br.x) : (x += 1) {
                const c = self.tiles.getPtr(.{ .x = x, .y = y });

                if (c.?.type == Tile.Type.START or c.?.type == Tile.Type.TACHYON) {
                    c.?.type = Tile.Type.TACHYON;

                    const below = self.tiles.getPtr(.{ .x = x, .y = y + 1 });
                    if (below.?.type == Tile.Type.EMPTY) {
                        below.?.type = Tile.Type.TACHYON;
                    } else if (below.?.type == Tile.Type.SPLITTER) {
                        var splitted = false;
                        if (x > 0) {
                            const left = self.tiles.getPtr(.{ .x = x - 1, .y = y + 1 });
                            if (left.?.type == Tile.Type.EMPTY) {
                                left.?.type = Tile.Type.TACHYON;
                                splitted = true;
                            }
                        }
                        if (x < self.extends.br.x) {
                            const right = self.tiles.getPtr(.{ .x = x + 1, .y = y + 1 });
                            if (right.?.type == Tile.Type.EMPTY) {
                                right.?.type = Tile.Type.TACHYON;
                                splitted = true;
                            }
                        }

                        if (splitted) {
                            self.splits += 1;
                        }
                    }
                }
            }
        }
    }

    fn print(self: *const Map) void {
        var y: i32 = self.extends.tl.y;
        while (y <= self.extends.br.y) : (y += 1) {
            var x: i32 = self.extends.tl.x;
            while (x <= self.extends.br.x) : (x += 1) {
                const c = self.tiles.get(.{ .x = x, .y = y });
                std.debug.print("{c}", .{@intFromEnum(c.?.type)});
            }
            std.debug.print("\n", .{});
        }
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
    return .{ .tiles = result, .extends = .{ .tl = .{ .x = 0, .y = 0 }, .br = .{ .x = x_max, .y = y_max } }, .splits = 0, .timelines = 0 };
}

test "parse map, test extends and extract some items" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer map.deinit();

    try std.testing.expectEqual(15 * 16, map.count());

    const expectedExtends: util.Extends = .{ .tl = .{ .x = 0, .y = 0 }, .br = .{ .x = 14, .y = 15 } };
    try std.testing.expectEqual(expectedExtends, map.extends);
}

test "parse and update map, check total splits" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer map.deinit();

    map.update();
    //map.print();
    try std.testing.expectEqual(21, map.splits);
}

test "parse and update map, check total timelines" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer map.deinit();

    map.update();
    //map.print();
    try std.testing.expectEqual(40, map.timelines);
}

pub fn partOne() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day07/input.txt");
    defer file.deinit();

    var map = try parseMap(gpa, file.lines());
    defer map.deinit();

    map.update();

    std.debug.assert(map.splits == 1581);
    std.debug.print("Day 07, part 1 : {d} \n", .{map.splits});
}

pub fn partTwo() !void {
    // std.debug.assert(grand_total == 5060053676136);
    std.debug.print("Day 07, part 2 : {d} \n", .{2});
}
