const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Arena.init(input, allocator);

    var locations = std.AutoHashMap([2]u8, void).init(allocator);

    var iter = data.beacons.iterator();
    while (iter.next()) |entry| {
        const beacon_locations = entry.value_ptr.*;
        for (beacon_locations.items, 0..) |location_1, i| {
            for (beacon_locations.items[i + 1 ..]) |location_2| {
                const x1: i32 = 2 * @as(i32, location_1[0]) - @as(i32, location_2[0]);
                const y1: i32 = 2 * @as(i32, location_1[1]) - @as(i32, location_2[1]);
                const x2: i32 = 2 * @as(i32, location_2[0]) - @as(i32, location_1[0]);
                const y2: i32 = 2 * @as(i32, location_2[1]) - @as(i32, location_1[1]);
                if (x1 >= 0 and x1 < data.height and y1 >= 0 and y1 < data.height) {
                    try locations.put([2]u8{ @as(u8, @intCast(x1)), @as(u8, @intCast(y1)) }, {});
                }
                if (x2 >= 0 and x2 < data.height and y2 >= 0 and y2 < data.height) {
                    try locations.put([2]u8{ @as(u8, @intCast(x2)), @as(u8, @intCast(y2)) }, {});
                }
            }
        }
    }

    return locations.count();
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data = try Arena.init(input, allocator);

    var locations = std.AutoHashMap([2]u8, void).init(allocator);

    var iter = data.beacons.iterator();
    while (iter.next()) |entry| {
        const beacon_locations = entry.value_ptr.*;
        for (beacon_locations.items, 0..) |location_1, i| {
            for (beacon_locations.items[i + 1 ..]) |location_2| {
                const dx: i32 = @as(i32, location_1[0]) - @as(i32, location_2[0]);
                const dy: i32 = @as(i32, location_1[1]) - @as(i32, location_2[1]);
                var candidate_1_x = @as(i32, location_1[0]);
                var candidate_1_y = @as(i32, location_1[1]);
                var candidate_2_x = @as(i32, location_2[0]);
                var candidate_2_y = @as(i32, location_2[1]);
                while (true) {
                    if (candidate_1_x < 0 or candidate_1_x >= data.height or candidate_1_y < 0 or candidate_1_y >= data.height) {
                        break;
                    }

                    try locations.put([2]u8{ @as(u8, @intCast(candidate_1_x)), @as(u8, @intCast(candidate_1_y)) }, {});

                    candidate_1_x += dx;
                    candidate_1_y += dy;
                }

                while (true) {
                    if (candidate_2_x < 0 or candidate_2_x >= data.height or candidate_2_y < 0 or candidate_2_y >= data.height) {
                        break;
                    }

                    try locations.put([2]u8{ @as(u8, @intCast(candidate_2_x)), @as(u8, @intCast(candidate_2_y)) }, {});

                    candidate_2_x -= dx;
                    candidate_2_y -= dy;
                }
            }
        }
    }

    return locations.count();
}

const Arena = struct {
    height: usize,
    width: usize,
    beacons: std.AutoHashMap(u8, std.ArrayList([2]u8)),

    pub fn init(input: []const u8, allocator: std.mem.Allocator) !Arena {
        var input_iterator = std.mem.splitSequence(u8, input, "\n");

        const height: usize = std.mem.count(u8, input, "\n") + 1;
        var width: usize = 0;
        var beacons = std.AutoHashMap(u8, std.ArrayList([2]u8)).init(allocator);

        var i: usize = 0;
        while (input_iterator.next()) |line| {
            for (line, 0..) |char, j| {
                if (char == '.') continue;

                const value_item = [2]u8{ @as(u8, @intCast(i)), @as(u8, @intCast(j)) };

                const outer_result = try beacons.getOrPut(char);
                if (!outer_result.found_existing) {
                    var inner = std.ArrayList([2]u8).init(allocator);

                    try inner.append(value_item);
                    outer_result.value_ptr.* = inner;
                } else {
                    try outer_result.value_ptr.*.append(value_item);
                }

                width = line.len;
            }
            i += 1;
        }

        return Arena{
            .height = height,
            .width = width,
            .beacons = beacons,
        };
    }

    pub fn pretty_print(self: *Arena) !void {
        std.debug.print("Printing dict:\n", .{});
        var iter = self.beacons.iterator();
        while (iter.next()) |entry| {
            std.debug.print("  {c}\n", .{entry.key_ptr.*});
            const inner_items = entry.value_ptr.*.items;
            for (inner_items) |entry_inner| {
                std.debug.print("    {any}\n", .{entry_inner});
            }
        }
    }
};
