const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const problems = try ingest_data(input, allocator);

    var output: u64 = 0;
    var iter = problems.iterator();
    while (iter.next()) |e| {
        var problem = e.key_ptr.*;
        const solution = try problem.solve(false);

        if (solution.valid and (solution.n1 <= 100 and solution.n2 <= 100)) {
            output += 3 * solution.n1 + solution.n2;
        }
    }

    return output;
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const problems = try ingest_data(input, allocator);

    var output: u64 = 0;
    var iter = problems.iterator();
    while (iter.next()) |e| {
        var problem = e.key_ptr.*;
        const solution = try problem.solve(true);

        if (solution.valid) {
            output += 3 * solution.n1 + solution.n2;
        }
    }

    return output;
}

const Problems = std.AutoHashMap(Problem, void);
const Solution = struct { valid: bool, n1: u64, n2: u64 };
const Problem = struct {
    ax: i8,
    ay: i8,
    bx: i8,
    by: i8,
    px: u64,
    py: u64,

    fn solve(self: *Problem, part_2: bool) !Solution {
        if (part_2) {
            self.px += 10000000000000;
            self.py += 10000000000000;
        }

        const det = @as(i32, self.ax) * @as(i32, self.by) - @as(i32, self.ay) * @as(i32, self.bx);

        const det_x_n1 = @as(i32, self.by) * @as(i64, @intCast(self.px)) - @as(i32, self.bx) * @as(i64, @intCast(self.py));
        const det_x_n2 = @as(i32, self.ax) * @as(i64, @intCast(self.py)) - @as(i32, self.ay) * @as(i64, @intCast(self.px));

        if (det == 0) {
            return Solution{ .valid = false, .n1 = 0, .n2 = 0 };
        }

        const valid = (@rem(det_x_n1, det) == 0) and (@rem(det_x_n2, det) == 0);

        const n1 = @as(i64, @intCast(@divTrunc(det_x_n1, det)));
        const n2 = @as(i64, @intCast(@divTrunc(det_x_n2, det)));

        if (n1 < 0 or n2 < 0) {
            return Solution{ .valid = false, .n1 = 0, .n2 = 0 };
        }

        if (valid) {
            return Solution{ .valid = true, .n1 = @as(u64, @intCast(n1)), .n2 = @as(u64, @intCast(n2)) };
        } else {
            return Solution{ .valid = valid, .n1 = 0, .n2 = 0 };
        }
    }
};

fn ingest_data(input: []const u8, allocator: std.mem.Allocator) !Problems {
    var output = Problems.init(allocator);
    var problem_iter = std.mem.split(u8, input, "\n\n");
    while (problem_iter.next()) |raw_problem| {
        var problem = Problem{ .ax = undefined, .ay = undefined, .bx = undefined, .by = undefined, .px = undefined, .py = undefined };

        var iter = std.mem.split(u8, raw_problem, "\n");
        const section_a = iter.next() orelse unreachable;
        var iter_a = std.mem.split(u8, section_a, ", Y");
        const a_x = iter_a.next() orelse unreachable;
        const a_x_value = try std.fmt.parseInt(i8, a_x[11..], 10);
        problem.ax = a_x_value;
        const a_y = iter_a.next() orelse unreachable;
        const a_y_value = try std.fmt.parseInt(i8, a_y, 10);
        problem.ay = a_y_value;

        const section_b = iter.next() orelse unreachable;
        var iter_b = std.mem.split(u8, section_b, ", Y");
        const b_x = iter_b.next() orelse unreachable;
        const b_x_value = try std.fmt.parseInt(i8, b_x[11..], 10);
        problem.bx = b_x_value;
        const b_y = iter_b.next() orelse unreachable;
        const b_y_value = try std.fmt.parseInt(i8, b_y, 10);
        problem.by = b_y_value;

        const section_p = iter.next() orelse unreachable;
        var iter_p = std.mem.split(u8, section_p, ", Y=");
        const p_x = iter_p.next() orelse unreachable;
        const p_x_value = try std.fmt.parseInt(u16, p_x[9..], 10);
        problem.px = p_x_value;
        const p_y = iter_p.next() orelse unreachable;
        const p_y_value = try std.fmt.parseInt(u16, p_y, 10);
        problem.py = p_y_value;

        try output.put(problem, {});
    }

    return output;
}

fn pretty_print(problems: Problems) void {
    std.debug.print("Pretty:\n", .{});
    var iter = problems.iterator();
    while (iter.next()) |e| {
        std.debug.print("  {any}\n", .{e.key_ptr.*});
    }
}
