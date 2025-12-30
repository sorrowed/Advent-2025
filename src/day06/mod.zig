const std = @import("std");
const util = @import("util.zig");

const test_input = [_][]const u8{
    "123 328  51 64 ",
    " 45 64  387 23 ",
    "  6 98  215 314",
    "*   +   *   +  ",
};

const Operator = enum(u8) {
    MUL = '*',
    ADD = '+',
    _,
};

const MathProblem = struct {
    input: std.ArrayList(i64),
    op: ?Operator,
    allocator: std.mem.Allocator,

    fn init(gpa: std.mem.Allocator) MathProblem {
        return .{
            .input = std.ArrayList(i64).empty,
            .op = null,
            .allocator = gpa,
        };
    }

    fn deinit(self: *MathProblem) void {
        self.input.deinit(self.allocator);
    }

    fn append(self: *MathProblem, value: i64) !void {
        try self.input.append(self.allocator, value);
    }

    fn calculate(self: *const MathProblem) i64 {
        return switch (self.op.?) {
            Operator.ADD => {
                var result: i64 = 0;
                for (self.input.items) |operand| {
                    result += operand;
                }
                return result;
            },
            Operator.MUL => {
                var result: i64 = 1;
                for (self.input.items) |operand| {
                    result *= operand;
                }
                return result;
            },
            _ => 0,
        };
    }
};

fn parseInput(gpa: std.mem.Allocator, input: []const []const u8) !std.AutoHashMap(usize, MathProblem) {
    var problems = std.AutoHashMap(usize, MathProblem).init(gpa);
    errdefer problems.deinit();

    for (input) |line| {
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        var index: usize = 0;
        while (tokens.next()) |token| : (index += 1) {
            var problem = problems.get(index) orelse MathProblem.init(gpa);
            const op: Operator = @enumFromInt(token[0]);
            switch (op) {
                .ADD => problem.op = op,
                .MUL => problem.op = op,
                else => {
                    const p = try std.fmt.parseInt(i64, token, 10);
                    try problem.append(p);
                },
            }
            try problems.put(index, problem);
        }
    }
    return problems;
}

fn parseInputTransposed(gpa: std.mem.Allocator, input: []const []const u8) !std.AutoHashMap(usize, MathProblem) {
    var problems = std.AutoHashMap(usize, MathProblem).init(gpa);
    errdefer problems.deinit();

    var lines = try gpa.alloc([]u8, input.len);
    defer gpa.free(lines);

    // Reverse each line (Can't Zig iterate revered?)
    for (input, 0..) |line, index| {
        lines[index] = try gpa.dupe(u8, line);
        std.mem.reverse(u8, lines[index]);
    }

    var index: usize = 0;
    for (0..lines[0].len) |x| { // Assume all lines have equal length

        // All spaces marks the next problem
        var is_separator = true;
        for (lines) |line| {
            is_separator = is_separator and line[x] == ' ';
        }

        if (is_separator) {
            index += 1;
        } else {
            var problem = problems.get(index) orelse MathProblem.init(gpa);
            errdefer problem.deinit();

            // Assume operator is on last row
            const op: Operator = @enumFromInt(lines[lines.len - 1][x]);
            switch (op) {
                .ADD => problem.op = op,
                .MUL => problem.op = op,
                _ => {},
            }

            // .. and the rest are the operands.
            var token = std.ArrayList(u8).empty;
            defer token.deinit(gpa);

            for (0..lines.len - 1) |y| {
                if (lines[y][x] != ' ') { // parseInt does not allow/ignore spaces, just '_'
                    try token.append(gpa, lines[y][x]);
                }
            }

            const p = try std.fmt.parseInt(i64, token.items, 10);
            try problem.append(p);

            try problems.put(index, problem);
        }
    }

    return problems;
}

test "parse input into problems and do some tests" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var problems = try parseInput(gpa, &test_input);
    defer problems.deinit();

    try std.testing.expectEqual(4, problems.count());
    const problemOne = problems.get(0);
    try std.testing.expect(problemOne != null);
    try std.testing.expectEqual(Operator.MUL, problemOne.?.op);
    const operands = problemOne.?.input;
    try std.testing.expectEqual(3, operands.items.len);
    try std.testing.expectEqual(123, operands.items[0]);
    try std.testing.expectEqual(45, operands.items[1]);
    try std.testing.expectEqual(6, operands.items[2]);

    try std.testing.expectEqual(33210, problemOne.?.calculate());

    try std.testing.expectEqual(490, problems.get(1).?.calculate());
    try std.testing.expectEqual(4243455, problems.get(2).?.calculate());
    try std.testing.expectEqual(401, problems.get(3).?.calculate());
}

test "parse input transposed" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var problems = try parseInputTransposed(gpa, &test_input);
    defer problems.deinit();

    try std.testing.expectEqual(4, problems.count());
    const problemOne = problems.get(0);
    try std.testing.expect(problemOne != null);
    try std.testing.expectEqual(Operator.ADD, problemOne.?.op);
    const operands = problemOne.?.input;
    try std.testing.expectEqual(3, operands.items.len);
    try std.testing.expectEqual(4, operands.items[0]);
    try std.testing.expectEqual(431, operands.items[1]);
    try std.testing.expectEqual(623, operands.items[2]);
    try std.testing.expectEqual(1058, problemOne.?.calculate());

    try std.testing.expectEqual(3253600, problems.get(1).?.calculate());
    try std.testing.expectEqual(625, problems.get(2).?.calculate());
    try std.testing.expectEqual(8544, problems.get(3).?.calculate());
}

pub fn partOne() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day06/input.txt");
    defer file.deinit();

    var problems = try parseInput(gpa, file.lines());
    defer problems.deinit();

    var grand_total: i64 = 0;
    var it = problems.valueIterator();
    while (it.next()) |problem| {
        grand_total += problem.calculate();
    }
    std.debug.assert(grand_total == 5060053676136);
    std.debug.print("Day 06, part 1 : Grand total for all math problems {d} \n", .{grand_total});
}

pub fn partTwo() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    var file = try util.FileLines.read(gpa, std.fs.cwd(), "src/day06/input.txt");
    defer file.deinit();

    var problems = try parseInputTransposed(gpa, file.lines());
    defer problems.deinit();

    var grand_total: i64 = 0;
    var it = problems.valueIterator();
    while (it.next()) |problem| {
        grand_total += problem.calculate();
    }
    std.debug.assert(grand_total == 9695042567249);
    std.debug.print("Day 06, part 2 : Grand total for all (transposed) math problems {d} \n", .{grand_total});
}
