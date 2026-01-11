const std = @import("std");

pub const Range = struct { begin: i64, end: i64 };

pub const FileLines = struct {
    gpa: std.mem.Allocator,
    data: []const u8,
    slices: std.ArrayList([]const u8),

    pub fn read(gpa: std.mem.Allocator, dir: std.fs.Dir, filename: []const u8) !FileLines {
        const data = try dir.readFileAlloc(filename, gpa, .unlimited);

        var slices: std.ArrayList([]const u8) = .empty;
        var itr = std.mem.tokenizeScalar(u8, data, '\n');
        while (itr.next()) |line| {
            // Note that 'line' is a slice/view into data
            try slices.append(gpa, line);
        }

        return .{
            .gpa = gpa,
            .data = data,
            .slices = slices,
        };
    }

    pub fn deinit(self: *FileLines) void {
        self.slices.deinit(self.gpa);
        self.gpa.free(self.data);
    }

    pub fn lines(self: *const FileLines) [][]const u8 {
        return self.slices.items;
    }
};

pub const Vector2 = struct {
    x: i32,
    y: i32,

    pub fn equals(self: *const Vector2, other: Vector2) bool {
        return self.x == other.x and self.y == other.y;
    }
};

pub const Extends = struct { tl: Vector2, br: Vector2 };

pub fn indexOf(comptime T: type, haystack: []const T, needle: T) ?usize {
    return for (haystack, 0..) |item, index| {
        if (item.equals(needle)) {
            break index;
        }
    } else null;
}
