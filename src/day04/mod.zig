const std = @import("std");
const util = @import("util");

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

const Vector2 = struct {
    x: i32,
    y: i32,

    fn isEqual(self: *const Vector2, other: Vector2) bool {
        return self.x == other.x and self.y == other.y;
    }
};
const Tile = struct {
    const Type = enum(u8) {
        Empty = '.',
        Paper = '@',
    };
    type: Type,
};
const Extends = struct { tl: Vector2, br: Vector2 };

const Map = struct {
    tiles: std.AutoHashMap(Vector2, Tile),
    extends: Extends,

    pub fn deinit(self: *Map) void {
        self.tiles.deinit();
    }

    fn count(self: *Map) usize {
        return self.tiles.count();
    }

    fn get(self: *const Map, key: Vector2) ?Tile {
        return self.tiles.get(key);
    }
};

fn parseMap(gpa: std.mem.Allocator, input: []const []const u8) !Map {
    var result = std.AutoHashMap(Vector2, Tile).init(gpa);

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

fn countNeighboringPaperTiles(map: Map, current: Vector2) i32 {
    var paperTiles: i32 = 0;

    const offsets = [_]i32{ -1, 0, 1 };
    for (offsets) |xo| {
        for (offsets) |yo| {
            const neighbor = Vector2{ .x = current.x + xo, .y = current.y + yo };

            if (!current.isEqual(neighbor)) {
                if (map.get(neighbor)) |n| {
                    if (n.type == Tile.Type.Paper) {
                        paperTiles += 1;
                    }
                }
            }
        }
    }
    return paperTiles;
}

test "parse map, test extends and extract some items" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer {
        map.deinit();
    }

    try std.testing.expectEqual(10 * 10, map.count());

    const expectedExtends: Extends = .{ .tl = .{ .x = 0, .y = 0 }, .br = .{ .x = 9, .y = 9 } };
    try std.testing.expectEqual(expectedExtends, map.extends);

    const tileX0Y0 = map.get(.{ .x = 0, .y = 0 });
    try std.testing.expect(tileX0Y0 != null);
    try std.testing.expectEqual(Tile{ .type = Tile.Type.Empty }, tileX0Y0);

    const tileX8Y9 = map.get(.{ .x = 8, .y = 9 });
    try std.testing.expect(tileX8Y9 != null);
    try std.testing.expectEqual(Tile{ .type = Tile.Type.Paper }, tileX8Y9);
}

test "count accessable tiles" {
    const gpa = std.heap.page_allocator;

    var map = try parseMap(gpa, &test_input);
    defer {
        map.deinit();
    }

    var accessible: usize = 0;

    var items = map.tiles.iterator();
    while (items.next()) |tile| {
        const current = tile.key_ptr.*;

        if (tile.value_ptr.type == Tile.Type.Paper) {
            const paperTiles = countNeighboringPaperTiles(map, current);

            if (paperTiles < 4) {
                accessible += 1;
            }
        }
    }

    try std.testing.expectEqual(13, accessible);
}

pub fn partOne() !void {
    const gpa = std.heap.page_allocator;

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day04/input.txt");
    defer file.deinit();

    var map = try parseMap(gpa, file.lines());
    defer map.deinit();

    std.debug.assert(map.count() == 140 * 140);

    var accessible_tiles: usize = 0;

    var items = map.tiles.iterator();
    while (items.next()) |tile| {
        if (tile.value_ptr.type == Tile.Type.Paper) {
            const rollsOfPaper = countNeighboringPaperTiles(map, tile.key_ptr.*);

            if (rollsOfPaper < 4) {
                accessible_tiles += 1;
            }
        }
    }

    std.debug.assert(accessible_tiles == 1493);
    std.debug.print("Day 04, part 1 : Accessible paper tiles {d} \n", .{accessible_tiles});
}

pub fn partTwo() !void {
    const gpa = std.heap.page_allocator;

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day04/input.txt");
    defer file.deinit();

    var map = try parseMap(gpa, file.lines());
    defer map.deinit();

    std.debug.assert(map.count() == 140 * 140);

    var tiles_removed: usize = 0;

    while (true) {
        var to_be_removed = std.ArrayList(Vector2).empty;
        defer to_be_removed.deinit(gpa);

        var items = map.tiles.iterator();
        while (items.next()) |tile| {
            if (tile.value_ptr.type == Tile.Type.Paper) {
                const rollsOfPaper = countNeighboringPaperTiles(map, tile.key_ptr.*);

                if (rollsOfPaper < 4) {
                    try to_be_removed.append(gpa, tile.key_ptr.*);
                }
            }
        }

        if (to_be_removed.items.len == 0) break;

        tiles_removed += to_be_removed.items.len;
        for (to_be_removed.items) |position| {
            try map.tiles.put(position, .{ .type = Tile.Type.Empty });
        }
    }

    std.debug.assert(tiles_removed == 9194);
    std.debug.print("Day 04, part 2 : Total paper tiles removed {d} \n", .{tiles_removed});
}
