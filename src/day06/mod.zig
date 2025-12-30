const std = @import("std");
const util = @import("util.zig");

const test_input = [_][]const u8{
    "123 328  51 64 ",
    " 45 64  387 23 ",
    "  6 98  215 314",
    "*   +   *   + ",
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
                    try problem.input.append(problem.allocator, p);
                },
            }
            try problems.put(index, problem);
        }
    }
    return problems;
}

test "parse input into" {
    var allocator = std.heap.GeneralPurposeAllocator(.{}).init;
    const gpa = allocator.allocator();

    const problems = try parseInput(gpa, &test_input);

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
    std.debug.print("Day 06, part 1 : Grand total for all math problems {d} \n", .{grand_total});
}

pub fn partTwo() !void {
    std.debug.assert(false);

    std.debug.print("Day 06, part 2 : Total fresh ingredients {d} \n", .{2});
}
