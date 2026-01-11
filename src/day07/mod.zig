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
        BLOCKED = '#',
    };
    type: Type,
};

const Map = struct {
    tiles: std.AutoHashMap(util.Vector2, Tile),

    pub fn deinit(self: *Map) void {
        self.tiles.deinit();
    }

    fn count(self: *Map) usize {
        return self.tiles.count();
    }

    fn get(self: *const Map, key: util.Vector2) ?Tile {
        return self.tiles.get(key);
    }

    fn extends(self: *const Map) util.Extends {
        var it = self.tiles.keyIterator();
        var tl = util.Vector2{ .x = 0, .y = 0 };
        var br = util.Vector2{ .x = 0, .y = 0 };

        while (it.next()) |v| {
            tl.x = @min(tl.x, v.x);
            tl.y = @min(tl.y, v.y);
            br.x = @max(br.x, v.x);
            br.y = @max(br.y, v.y);
        }

        return util.Extends{ .tl = tl, .br = br };
    }

    fn updateSplitting(self: *Map) i32 {
        var splits: i32 = 0;

        const ext = self.extends();

        var y: i32 = ext.tl.y;
        while (y <= ext.br.y - 1) : (y += 1) {
            var x: i32 = ext.tl.x;
            while (x <= ext.br.x) : (x += 1) {
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
                        if (x < ext.br.x) {
                            const right = self.tiles.getPtr(.{ .x = x + 1, .y = y + 1 });
                            if (right.?.type == Tile.Type.EMPTY) {
                                right.?.type = Tile.Type.TACHYON;
                                splitted = true;
                            }
                        }

                        if (splitted) {
                            splits += 1;
                        }
                    }
                }
            }
        }
        return splits;
    }

    const SearchError = error{StartNotFound};
    fn startPosition(self: *const Map) !util.Vector2 {
        var it = self.tiles.iterator();
        return try while (it.next()) |entry| {
            if (entry.value_ptr.type == Tile.Type.START) {
                break entry.key_ptr.*;
            }
        } else SearchError.StartNotFound;
    }

    fn updateTimelines(self: *const Map) !i32 {
        const gpa = std.heap.page_allocator;
        var start_positions = std.ArrayList(util.Vector2).empty;
        defer start_positions.deinit(gpa);

        const ext = self.extends();

        try start_positions.append(gpa, try self.startPosition());
        var timelines: i32 = 1;

        while (start_positions.items.len > 0) {
            const start = start_positions.pop().?;

            var y: i32 = start.y;
            while (y < ext.br.y) : (y += 1) {
                const below = self.tiles.getPtr(.{ .x = start.x, .y = y + 1 });
                if (below.?.type == Tile.Type.SPLITTER) {
                    const left = util.Vector2{ .x = start.x - 1, .y = y + 1 };
                    if (self.tiles.getPtr(left).?.type == Tile.Type.EMPTY) {
                        if (util.indexOf(util.Vector2, start_positions.items, left) == null) {
                            try start_positions.append(gpa, left);
                        }
                    }

                    const right = util.Vector2{ .x = start.x + 1, .y = y + 1 };
                    if (self.tiles.getPtr(right).?.type == Tile.Type.EMPTY) {
                        if (util.indexOf(util.Vector2, start_positions.items, right) == null) {
                            try start_positions.append(gpa, right);
                        }
                    }

                    // Assume both of them are valid timelines, but we only count one *new* timeline
                    timelines += 1;
                    break;
                }
            }
        }

        return timelines;
    }

    fn print(self: *const Map) void {
        const ext = self.extends();

        var y: i32 = ext.tl.y;
        while (y <= ext.br.y) : (y += 1) {
            var x: i32 = ext.tl.x;
            while (x <= ext.br.x) : (x += 1) {
                const c = self.tiles.get(.{ .x = x, .y = y });
                std.debug.print("{c}", .{@intFromEnum(c.?.type)});
            }
            std.debug.print("\n", .{});
        }
    }
};

fn parseMap(gpa: std.mem.Allocator, input: []const []const u8) !Map {
    var tiles = std.AutoHashMap(util.Vector2, Tile).init(gpa);

    for (input, 0..) |v, yu| {
        const y = @as(i32, @intCast(yu));

        for (v, 0..) |c, xu| {
            const x = @as(i32, @intCast(xu));

            try tiles.put(.{ .x = x, .y = y }, .{ .type = @enumFromInt(c) });
        }
    }
    return .{ .tiles = tiles };
}

test "parse map, test extends and extract some items" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer map.deinit();

    try std.testing.expectEqual(15 * 16, map.count());

    const expectedExtends: util.Extends = .{ .tl = .{ .x = 0, .y = 0 }, .br = .{ .x = 14, .y = 15 } };
    try std.testing.expectEqual(expectedExtends, map.extends());
}

test "parse and update map, check total splits" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer map.deinit();

    const splits = map.updateSplitting();
    //map.print();
    try std.testing.expectEqual(21, splits);
}

test "parse and update map, check total timelines" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer map.deinit();

    const timelines = try map.updateTimelines();
    //map.print();
    try std.testing.expectEqual(40, timelines);
}

pub fn partOne() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day07/input.txt");
    defer file.deinit();

    var map = try parseMap(gpa, file.lines());
    defer map.deinit();

    const splits = map.updateSplitting();

    std.debug.assert(splits == 1581);
    std.debug.print("Day 07, part 1 : {d} \n", .{splits});
}

pub fn partTwo() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day07/input.txt");
    defer file.deinit();

    var map = try parseMap(gpa, file.lines());
    defer map.deinit();

    const timelines = try map.updateTimelines();

    //std.debug.assert(timelines == 1581);
    std.debug.print("Day 07, part 2 : {d} \n", .{timelines});
}
