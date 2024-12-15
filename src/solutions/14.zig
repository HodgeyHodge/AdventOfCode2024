const std = @import("std");

pub fn solve_1(args: struct { width: u8, height: u8 }) (fn ([]const u8) anyerror!u64) {
    const CurriedSolver = struct {
        fn solve(input: []const u8) !u64 {
            return inner_solve_1(input, args.width, args.height);
        }
    };
    return CurriedSolver.solve;
}

fn inner_solve_1(input: []const u8, width: u8, height: u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const robots = try ingest_data(input, allocator);

    var quadrants = [4]u8{ 0, 0, 0, 0 };

    var iter = robots.iterator();
    while (iter.next()) |e| {
        const robot = e.key_ptr.*;
        const new_position = robot.evolve(width, height, 100);

        if (2 * (new_position[0] % width) + 1 < width) {
            if (2 * (new_position[1] % height) + 1 < height) {
                quadrants[0] += 1;
            } else if (2 * (new_position[1] % height) + 1 > height) {
                quadrants[1] += 1;
            }
        } else if (2 * (new_position[0] % width) + 1 > width) {
            if (2 * (new_position[1] % height) + 1 < height) {
                quadrants[2] += 1;
            } else if (2 * (new_position[1] % height) + 1 > height) {
                quadrants[3] += 1;
            }
        }
    }

    return @as(u64, quadrants[0]) * @as(u64, quadrants[1]) * @as(u64, quadrants[2]) * @as(u64, quadrants[3]);
}

pub fn solve_2(args: struct { width: u8, height: u8, frame: ?u16 }) (fn ([]const u8) anyerror!u64) {
    const CurriedSolver = struct {
        fn solve(input: []const u8) !u64 {
            return inner_solve_2(input, args.width, args.height, args.frame);
        }
    };
    return CurriedSolver.solve;
}

fn inner_solve_2(input: []const u8, comptime width: u8, comptime height: u8, comptime frame: ?u16) !u64 {
    //notes for part 2: pretty print the field at various times, and notice a pattern:
    //horizontal pattern at frames 23, 124 etc.
    //vertical pattern at frames 2, 105 etc.
    //by chinese remainder theorem, looking for frame 6285.

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const robots = try ingest_data(input, allocator);

    var t: u16 = if (frame == null) 0 else frame.?;
    while (true) : (t += 1) {
        var field: [height][width]u8 = [_][width]u8{[_]u8{' '} ** width} ** height;

        var iter = robots.iterator();
        while (iter.next()) |e| {
            const robot = e.key_ptr.*;
            const new_position = robot.evolve(width, height, t);
            field[new_position[1]][new_position[0]] = '*';
        }

        std.debug.print("DISPLAYING ARENA AT t = {d}\n", .{t});
        std.debug.print("======================================================================================================\n", .{});
        for (field) |row| {
            std.debug.print("{s}\n", .{row});
        }
        std.debug.print("------------------------------------------------------------------------------------------------------\n", .{});
        std.time.sleep(100000000);

        if (frame != null) return 0;
    }

    return frame.?;
}

const Robots = std.AutoHashMap(Robot, void);
const Robot = struct {
    px: u8,
    py: u8,
    vx: i8,
    vy: i8,

    fn evolve(self: *const Robot, width: u8, height: u8, duration: u16) [2]u8 {
        const px_new = @rem(@as(i32, self.px) + @as(i32, self.vx) * @as(i32, @intCast(duration)), width);
        const py_new = @rem(@as(i32, self.py) + @as(i32, self.vy) * @as(i32, @intCast(duration)), height);

        return [2]u8{
            @as(u8, @intCast(px_new + if (px_new < 0) width else 0)),
            @as(u8, @intCast(py_new + if (py_new < 0) height else 0)),
        };
    }
};

fn ingest_data(input: []const u8, allocator: std.mem.Allocator) !Robots {
    var robots = Robots.init(allocator);
    var input_iter = std.mem.split(u8, input, "\n");
    while (input_iter.next()) |line| {
        var robot = Robot{ .px = undefined, .py = undefined, .vx = undefined, .vy = undefined };

        var line_iter = std.mem.split(u8, line, " ");

        const p_section = line_iter.next() orelse unreachable;
        var p_secton_iter = std.mem.split(u8, p_section, ",");
        const px_raw = p_secton_iter.next() orelse unreachable;
        const py_raw = p_secton_iter.next() orelse unreachable;
        robot.px = try std.fmt.parseInt(u8, px_raw[2..], 10);
        robot.py = try std.fmt.parseInt(u8, py_raw, 10);

        const v_section = line_iter.next() orelse unreachable;
        var v_secton_iter = std.mem.split(u8, v_section, ",");
        const vx_raw = v_secton_iter.next() orelse unreachable;
        const vy_raw = v_secton_iter.next() orelse unreachable;
        robot.vx = try std.fmt.parseInt(i8, vx_raw[2..], 10);
        robot.vy = try std.fmt.parseInt(i8, vy_raw, 10);

        try robots.put(robot, {});
    }

    return robots;
}
