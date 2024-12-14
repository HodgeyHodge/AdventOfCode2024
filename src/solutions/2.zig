const std = @import("std");

pub fn solve_1(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    var safe_count: u32 = 0;
    for (data.items) |report| {
        if (safe(report)) {
            safe_count += 1;
        }
    }
    return safe_count;
}

fn safe(report: []u32) bool {
    var safe_asc = true;
    var safe_desc = true;
    for (report[1..], 0..) |current, i| {
        const prev = report[i];
        if (prev != current + 1 and prev != current + 2 and prev != current + 3) {
            safe_desc = false;
        }
        if (current != prev + 1 and current != prev + 2 and current != prev + 3) {
            safe_asc = false;
        }
    }

    return safe_asc != safe_desc;
}

pub fn solve_2(input: []const u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try ingest_input(input, allocator);

    var safe_count: u32 = 0;
    for (data.items) |report| {
        if (safe(report)) {
            safe_count += 1;
        } else {
            for (report[0..], 0..) |_, i| {
                const report_less_one_element = try remove_one_element(report, i, allocator);
                if (safe(report_less_one_element)) {
                    safe_count += 1;
                    break;
                }
            }
        }
    }
    return safe_count;
}

fn remove_one_element(slice: []const u32, index: usize, allocator: std.mem.Allocator) ![]u32 {
    if (index >= slice.len) return error.IndexOutOfBounds;
    const left = slice[0..index];
    const right = slice[index + 1 ..];
    const result = try allocator.alloc(u32, left.len + right.len);

    std.mem.copyForwards(u32, result[0..index], slice[0..index]);
    std.mem.copyForwards(u32, result[index..], slice[index + 1 ..]);

    return result;
}

fn ingest_input(input: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]u32) {
    var output = std.ArrayList([]u32).init(allocator);

    var split_input = std.mem.split(u8, input, "\n");
    while (split_input.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var split_line = std.mem.split(u8, line, " ");
        var numbers = std.ArrayList(u32).init(allocator);
        defer numbers.deinit();
        while (split_line.next()) |next_number| {
            const number = try std.fmt.parseInt(u32, next_number, 10);
            try numbers.append(number);
        }
        try output.append(try numbers.toOwnedSlice());
    }

    return output;
}
