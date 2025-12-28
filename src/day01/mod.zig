const std = @import("std");
const expect = std.testing.expect;

const Error = error{InvalidOp};

const Direction = enum { None, Left, Right };

const Op = struct { dir: Direction, count: i32 };

fn parse(line: []const u8) Op {
    const d = if (line[0] == 'L') Direction.Left else if (line[0] == 'R') Direction.Right else Direction.None;
    const n = std.fmt.parseInt(i32, line[1..], 10) catch unreachable;

    return Op{ .dir = d, .count = n };
}

const RotateResult = struct { current: i32, zeroes: i32 };

fn rotateLeft(rot: RotateResult, count: i32) RotateResult {
    var c = rot.current;
    var z = rot.zeroes;

    var i: i32 = 0;
    while (i < count) {
        c -= 1;
        if (c == 0) {
            z += 1;
        }
        if (c < 0)
            c = 99;
        i += 1;
    }
    return RotateResult{ .current = c, .zeroes = z };
}

fn rotateRight(rot: RotateResult, count: i32) RotateResult {
    var c = rot.current;
    var z = rot.zeroes;

    var i: i32 = 0;
    while (i < count) {
        c += 1;
        if (c >= 100)
            c = 0;
        if (c == 0) {
            z += 1;
        }
        i += 1;
    }
    return RotateResult{ .current = c, .zeroes = z };
}

fn rotate(rot: RotateResult, op: Op) Error!RotateResult {
    return if (op.dir == Direction.Left)
        rotateLeft(rot, op.count)
    else if (op.dir == Direction.Right)
        rotateRight(rot, op.count)
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
    var x = RotateResult{ .current = 0, .zeroes = 0 };
    x = rotateLeft(x, 1);

    try expect(x.current == 99);
}

test "turn right from 99" {
    var x = RotateResult{ .current = 99, .zeroes = 0 };
    x = rotateRight(x, 1);

    try expect(x.current == 0);
}

test "test multiple ops" {
    var x = RotateResult{ .current = 50, .zeroes = 0 };

    x = try rotate(x, parse("L68"));
    try expect(x.current == 82);
    x = try rotate(x, parse("L30"));
    try expect(x.current == 52);
    x = try rotate(x, parse("R48"));
    try expect(x.current == 0);
    x = try rotate(x, parse("L5"));
    try expect(x.current == 95);
    x = try rotate(x, parse("R60"));
    try expect(x.current == 55);
    x = try rotate(x, parse("L55"));
    try expect(x.current == 0);
    x = try rotate(x, parse("L1"));
    try expect(x.current == 99);
    x = try rotate(x, parse("L99"));
    try expect(x.current == 0);
    x = try rotate(x, parse("R14"));
    try expect(x.current == 14);
    x = try rotate(x, parse("L82"));
    try expect(x.current == 32);
}

test "turn right from 99, one rotation" {
    var x = RotateResult{ .current = 99, .zeroes = 0 };
    x = rotateRight(x, 1);

    try expect(x.current == 0);
    try expect(x.zeroes == 1);
}

test "turn several, multiple rotations, count zeroes" {
    var x = RotateResult{ .current = 50, .zeroes = 0 };

    x = rotateLeft(x, 68);
    try expect(x.current == 82);
    try expect(x.zeroes == 1);
    x = rotateLeft(x, 30);
    try expect(x.current == 52);
    x = rotateRight(x, 48);
    try expect(x.current == 0);
    try expect(x.zeroes == 2);
    x = rotateLeft(x, 5);
    try expect(x.current == 95);
    try expect(x.zeroes == 2);
    x = rotateRight(x, 60);
    // std.log.warn("{} {}", .{ x.current, x.zeroes });
    try expect(x.current == 55);
    try expect(x.zeroes == 3);
    x = rotateLeft(x, 55);
    try expect(x.current == 0);
    try expect(x.zeroes == 4);
    x = rotateLeft(x, 1);
    try expect(x.current == 99);
    try expect(x.zeroes == 4);
    x = rotateLeft(x, 99);
    try expect(x.current == 0);
    try expect(x.zeroes == 5);
    x = rotateRight(x, 14);
    try expect(x.current == 14);
    x = rotateLeft(x, 82);
    try expect(x.current == 32);
    try expect(x.zeroes == 6);
}

pub fn partOne() !void {
    const file = try std.fs.cwd().openFile(
        "src/day01/input.txt",
        .{},
    );
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(std.testing.io, &read_buffer);

    var zeroes: i32 = 0;
    var x: RotateResult = RotateResult{ .current = 50, .zeroes = 0 };
    while (true) {
        const line = try reader.interface.takeDelimiter('\n') orelse break;

        // std.debug.print("Line read: {s}\n", .{line});

        x = try rotate(x, parse(line));

        if (x.current == 0) {
            zeroes += 1;
        }
    }

    std.debug.assert(zeroes == 1180);

    std.debug.print("Day 01, part 1 : Number of times we had zeroes -> {d} \n", .{zeroes});
}

pub fn partTwo() !void {
    const file = try std.fs.cwd().openFile(
        "src/day01/input.txt",
        .{},
    );
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(std.testing.io, &read_buffer);

    var x: RotateResult = RotateResult{ .current = 50, .zeroes = 0 };
    while (true) {
        const line = try reader.interface.takeDelimiter('\n') orelse break;

        // std.debug.print("Line read: {s}\n", .{line});

        x = try rotate(x, parse(line));
    }

    std.debug.assert(x.zeroes == 6892);

    std.debug.print("Day 01, part 2 : Number of times we had zeroes -> {d} \n", .{x.zeroes});
}
