const std = @import("std");
const expect = std.testing.expect;

pub fn part1() !void {
    const file = try std.fs.cwd().openFile(
        "src/day01/input.txt",
        .{},
    );
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(std.testing.io, &read_buffer);

    var zeroes: i32 = 0;
    var x: i32 = 50;
    while (true) {
        const line = try reader.interface.takeDelimiter('\n') orelse break;

        // std.debug.print("Line read: {s}\n", .{line});

        x = try rotate(x, parse(line));

        if (x == 0) {
            zeroes += 1;
        }
    }

    std.debug.print("Day 01, part 1 : Number of times we had zeroes -> {d} \n", .{zeroes});
}

const Error = error{InvalidOp};

pub fn part2() !void {}

const Direction = enum { None, Left, Right };

const Op = struct { dir: Direction, count: i32 };

fn parse(line: []const u8) Op {
    const d = if (line[0] == 'L') Direction.Left else if (line[0] == 'R') Direction.Right else Direction.None;
    const n = std.fmt.parseInt(i32, line[1..], 10) catch unreachable;

    return Op{ .dir = d, .count = n };
}

fn rotate_left(current: i32, count: i32) i32 {
    const r = current - @rem(count, 100);
    return if (r < 0) 100 + r else r;
}

fn rotate_right(current: i32, count: i32) i32 {
    return @rem(current + count, 100);
}

fn rotate(current: i32, op: Op) Error!i32 {
    return if (op.dir == Direction.Left)
        rotate_left(current, op.count)
    else if (op.dir == Direction.Right)
        rotate_right(current, op.count)
    else
        Error.InvalidOp;
}

test "parsing of left instruction" {
    const x = "L68";

    const op = parse(x);

    try expect(std.meta.eql(op, Op{ .dir = Direction.Left, .count = 68 }));
}

test "parsing of right instruction" {
    const x = "R48";

    const op = parse(x);

    try expect(std.meta.eql(op, Op{ .dir = Direction.Right, .count = 48 }));
}

test "turn left from 0" {
    var x: i32 = 0;
    x = rotate_left(x, 1);

    try expect(x == 99);
}

test "turn right from 99" {
    var x: i32 = 99;
    x = rotate_right(x, 1);

    try expect(x == 0);
}

test "test multiple ops" {
    var x: i32 = 50;

    x = try rotate(x, parse("L68"));
    try expect(x == 82);
    x = try rotate(x, parse("L30"));
    try expect(x == 52);
    x = try rotate(x, parse("R48"));
    try expect(x == 0);
    x = try rotate(x, parse("L5"));
    try expect(x == 95);
    x = try rotate(x, parse("R60"));
    try expect(x == 55);
    x = try rotate(x, parse("L55"));
    try expect(x == 0);
    x = try rotate(x, parse("L1"));
    try expect(x == 99);
    x = try rotate(x, parse("L99"));
    try expect(x == 0);
    x = try rotate(x, parse("R14"));
    try expect(x == 14);
    x = try rotate(x, parse("L82"));
    try expect(x == 32);
}
