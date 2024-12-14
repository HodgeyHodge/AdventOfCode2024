const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    std.mem.sort(u32, data.first.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, data.second.items, {}, comptime std.sort.asc(u32));

    var sum: u64 = 0;
    for (data.first.items, 0..) |v, i| {
        sum += if (v > data.second.items[i]) v - data.second.items[i] else data.second.items[i] - v;
    }
    return sum;
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    var occurences_first = try occurences(data.first, allocator);
    var occurences_second = try occurences(data.second, allocator);

    var similarity: u32 = 0;
    var iter = occurences_first.iterator();
    while (iter.next()) |entry| {
        similarity += entry.key_ptr.* * entry.value_ptr.* * (occurences_second.get(entry.key_ptr.*) orelse 0);
    }
    return similarity;
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) !struct {
    first: std.ArrayList(u32),
    second: std.ArrayList(u32),
} {
    var first = std.ArrayList(u32).init(allocator);
    var second = std.ArrayList(u32).init(allocator);

    var split_input = std.mem.split(u8, input, "\n");
    while (split_input.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var split_line = std.mem.split(u8, line, "   ");
        const first_part = split_line.next() orelse return error.InvalidData;
        const second_part = split_line.next() orelse return error.InvalidData;
        try first.append(try std.fmt.parseInt(u32, first_part, 10));
        try second.append(try std.fmt.parseInt(u32, second_part, 10));
    }

    return .{ .first = first, .second = second };
}

fn occurences(array: std.ArrayList(u32), allocator: std.mem.Allocator) !std.AutoHashMap(u32, u32) {
    var map = std.AutoHashMap(u32, u32).init(allocator);
    for (array.items) |v| {
        const entry = map.get(v);
        if (entry) |count| {
            try map.put(v, count + 1);
        } else {
            try map.put(v, 1);
        }
    }
    return map;
}
