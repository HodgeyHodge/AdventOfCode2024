const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Data.init(input, allocator);

    try data.prepopulate(allocator);

    var i: u4 = 9;
    while (i > 0) {
        i -= 1;
        try data.build_trails(i, allocator);
    }

    return data.count_trailheads(allocator);
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Data.init(input, allocator);

    try data.prepopulate(allocator);

    var i: u4 = 9;
    while (i > 0) {
        i -= 1;
        try data.build_trails(i, allocator);
    }

    return data.count_distinct_trailheads();
}

const Trail = std.SinglyLinkedList([2]u8);

const Data = struct {
    field: [][]const u4,
    height: usize,
    width: usize,
    trails: std.AutoHashMap(Trail, void),

    fn init(input: []const u8, allocator: std.mem.Allocator) !Data {
        const line_count = std.mem.count(u8, input, "\n") + 1;
        const field = try allocator.alloc([]const u4, line_count);

        var lines = std.mem.splitSequence(u8, input, "\n");
        var i: usize = 0;
        while (lines.next()) |line| {
            const line_out = try allocator.alloc(u4, line.len);
            for (line, 0..) |c, j| {
                line_out[j] = @as(u4, @intCast(c - '0'));
            }
            field[i] = line_out;
            i += 1;
        }

        return Data{
            .field = field,
            .height = line_count,
            .width = field[0].len,
            .trails = std.AutoHashMap(Trail, void).init(allocator),
        };
    }

    fn prepopulate(self: *Data, allocator: std.mem.Allocator) !void {
        for (0..self.height) |i| {
            for (0..self.width) |j| {
                if (self.field[i][j] == 9) {
                    var node = try allocator.create(Trail.Node);
                    node.data = [2]u8{ @intCast(i), @intCast(j) };
                    var trail = Trail{};
                    trail.prepend(node);
                    try self.trails.put(trail, {});
                }
            }
        }
    }

    fn count_trailheads(self: *Data, allocator: std.mem.Allocator) !u64 {
        var starts_and_ends = std.AutoHashMap([4]u8, void).init(allocator);

        var iter = self.trails.iterator();
        while (iter.next()) |e| {
            try starts_and_ends.put([4]u8{
                e.key_ptr.first.?.data[0],
                e.key_ptr.first.?.data[1],
                e.key_ptr.first.?.findLast().data[0],
                e.key_ptr.first.?.findLast().data[1],
            }, {});
        }

        return starts_and_ends.count();
    }

    fn count_distinct_trailheads(self: *Data) !u64 {
        return self.trails.count();
    }

    fn build_trails(self: *Data, number: u4, allocator: std.mem.Allocator) !void {
        var new_trails = std.AutoHashMap(Trail, void).init(allocator);

        var iter = self.trails.iterator();
        while (iter.next()) |entry| {
            const trail = entry.key_ptr.*;
            const pre = try self.paths_in(number, trail.first.?.data[0], trail.first.?.data[1], allocator);
            for (pre.items) |p| {
                var new_trail = trail;

                var new_node = try allocator.create(Trail.Node);
                new_node.data = p;
                new_trail.prepend(new_node);

                try new_trails.put(new_trail, {});
            }
        }
        self.trails = new_trails;
    }

    fn paths_in(self: *Data, number: u4, i: u8, j: u8, allocator: std.mem.Allocator) !std.ArrayList([2]u8) {
        var output = std.ArrayList([2]u8).init(allocator);

        if (i > 0 and self.field[i - 1][j] == number) {
            try output.append([2]u8{ i - 1, j });
        }
        if (i + 1 < self.height and self.field[i + 1][j] == number) {
            try output.append([2]u8{ i + 1, j });
        }
        if (j > 0 and self.field[i][j - 1] == number) {
            try output.append([2]u8{ i, j - 1 });
        }
        if (j + 1 < self.width and self.field[i][j + 1] == number) {
            try output.append([2]u8{ i, j + 1 });
        }

        return output;
    }

    fn pretty_print(self: *Data) void {
        std.debug.print("pretty!\n", .{});
        var iter = self.trails.iterator();
        while (iter.next()) |entry| {
            var iterand = entry.key_ptr.first;
            while (iterand) |step| : (iterand = step.next) {
                std.debug.print(" -> {any}", .{step.data});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};
