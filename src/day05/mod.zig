const std = @import("std");
const util = @import("util.zig");

const test_input = [_][]const u8{
    "3-5",
    "10-14",
    "16-20",
    "12-18",
    "",
    "1",
    "5",
    "8",
    "11",
    "17",
    "32",
};

const IngredientInventory = struct {
    fresh: std.ArrayList(util.Range),
    ingredients: std.ArrayList(i64),

    fn compareRangeBegin(_: @TypeOf(.{}), left: util.Range, right: util.Range) bool {
        return left.begin < right.begin;
    }

    ///
    /// Merge ranges if start of next range is adjacent to or overlaps the current range
    /// Because the ranges are inclusive on both sides, we can merge if next starts at current.end + 1
    /// but make sure we take the greatest end as next might be entirely inside current.
    fn normalize(self: *IngredientInventory) void {
        std.mem.sort(util.Range, self.fresh.items, .{}, compareRangeBegin);

        var index: usize = 1;
        while (index < self.fresh.items.len - 1) {
            var current = &self.fresh.items[index];
            const next = &self.fresh.items[index + 1];

            std.debug.assert(current.begin <= next.begin);

            if (current.end + 1 >= next.begin) {
                current.end = @max(current.end, next.end);
                _ = self.fresh.orderedRemove(index + 1);
            } else {
                index += 1;
            }
        }
    }

    fn countFresh(self: *IngredientInventory) usize {
        var result: usize = 0;
        for (self.ingredients.items) |id| {
            for (self.fresh.items) |range| {
                if (id >= range.begin and id <= range.end) {
                    result += 1;
                    break;
                }
            }
        }
        return result;
    }

    fn countTotalFresh(self: *IngredientInventory) usize {
        var result: usize = 0;
        for (self.fresh.items) |range| {
            result += @as(usize, @intCast(range.end - range.begin + 1));
        }
        return result;
    }
};

fn parseIngredientInventory(gpa: std.mem.Allocator, input: []const []const u8) !IngredientInventory {
    var fresh = std.ArrayList(util.Range).empty;
    var ingredients = std.ArrayList(i64).empty;

    for (input) |line| {
        if (line.len == 0) continue;

        if (std.mem.find(u8, line, "-") != null) {
            var pair = std.mem.splitScalar(u8, line, '-');
            const range = util.Range{
                .begin = try std.fmt.parseInt(i64, pair.next().?, 10),
                .end = try std.fmt.parseInt(i64, pair.next().?, 10),
            };
            try fresh.append(gpa, range);
        } else {
            const id = try std.fmt.parseInt(i64, line, 10);
            try ingredients.append(gpa, id);
        }
    }
    return .{ .fresh = fresh, .ingredients = ingredients };
}

test "parse ranges and ingredients" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var inventory = try parseIngredientInventory(gpa, &test_input);
    defer {
        inventory.fresh.deinit(gpa);
        inventory.ingredients.deinit(gpa);
    }

    try std.testing.expectEqual(4, inventory.fresh.items.len);
    try std.testing.expectEqual(6, inventory.ingredients.items.len);
}

test "test fresh ingredients" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var inventory = try parseIngredientInventory(gpa, &test_input);
    defer {
        inventory.fresh.deinit(gpa);
        inventory.ingredients.deinit(gpa);
    }

    const fresh = inventory.countFresh();

    try std.testing.expectEqual(3, fresh);
}

test "test total fresh ingredients" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var inventory = try parseIngredientInventory(gpa, &test_input);
    defer {
        inventory.fresh.deinit(gpa);
        inventory.ingredients.deinit(gpa);
    }

    inventory.normalize();

    try std.testing.expectEqual(2, inventory.fresh.items.len);
    try std.testing.expectEqual(util.Range{ .begin = 3, .end = 5 }, inventory.fresh.items[0]);
    try std.testing.expectEqual(util.Range{ .begin = 10, .end = 20 }, inventory.fresh.items[1]);

    const fresh = inventory.countTotalFresh();

    try std.testing.expectEqual(14, fresh);
}

pub fn partOne() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day05/input.txt");
    defer file.deinit();

    var inventory = try parseIngredientInventory(gpa, file.lines());
    defer {
        inventory.fresh.deinit(gpa);
        inventory.ingredients.deinit(gpa);
    }

    const fresh = inventory.countFresh();

    std.debug.assert(fresh == 652);

    std.debug.print("Day 05, part 1 : Fresh ingredients {d} \n", .{fresh});
}

pub fn partTwo() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day05/input.txt");
    defer file.deinit();

    var inventory = try parseIngredientInventory(gpa, file.lines());
    defer {
        inventory.fresh.deinit(gpa);
        inventory.ingredients.deinit(gpa);
    }

    inventory.normalize();
    const fresh = inventory.countTotalFresh();

    std.debug.assert(fresh == 341753674214273);

    std.debug.print("Day 05, part 2 : Total fresh ingredients {d} \n", .{fresh});
}
